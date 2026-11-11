--!strict
-- Construit une créature voxel (export compact de outils/voxels/studio_export.py)
-- en MeshParts colorés via EditableMesh : faces visibles, arrondi léger,
-- une couleur par voxel. Un MeshPart par membre (corps, tête, pattes…),
-- avec attributs Role / Joint / Cote / Phase / Parent pour les animations.

local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")

local Constructeur = {}

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local DEC: { [number]: number } = {}
for i = 1, 64 do
	DEC[string.byte(B64, i)] = i - 1
end

local function base64(s: string): buffer
	s = string.gsub(s, "[^%w%+/]", "")
	local n = #s
	local out = buffer.create(math.floor(n * 3 / 4))
	local o = 0
	for i = 1, n, 4 do
		local a = DEC[string.byte(s, i)] or 0
		local b = DEC[string.byte(s, i + 1)] or 0
		local c = DEC[string.byte(s, i + 2)]
		local d = DEC[string.byte(s, i + 3)]
		local v = bit32.bor(bit32.lshift(a, 18), bit32.lshift(b, 12), bit32.lshift(c or 0, 6), d or 0)
		buffer.writeu8(out, o, bit32.rshift(v, 16))
		o += 1
		if c then
			buffer.writeu8(out, o, bit32.band(bit32.rshift(v, 8), 255))
			o += 1
		end
		if d then
			buffer.writeu8(out, o, bit32.band(v, 255))
			o += 1
		end
	end
	return out
end

-- Coins unitaires de chaque face, mêmes ordres que sculpteur.py.
local FACES = {
	{ 0, -1, 0, { { 0, 0, 0 }, { 0, 0, 1 }, { 0, 1, 1 }, { 0, 1, 0 } } },
	{ 0, 1, 0, { { 1, 0, 0 }, { 1, 1, 0 }, { 1, 1, 1 }, { 1, 0, 1 } } },
	{ 1, -1, 0, { { 0, 0, 0 }, { 1, 0, 0 }, { 1, 0, 1 }, { 0, 0, 1 } } },
	{ 1, 1, 0, { { 0, 1, 0 }, { 0, 1, 1 }, { 1, 1, 1 }, { 1, 1, 0 } } },
	{ 2, -1, 0, { { 0, 0, 0 }, { 0, 1, 0 }, { 1, 1, 0 }, { 1, 0, 0 } } },
	{ 2, 1, 0, { { 0, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 0, 1, 1 } } },
}

-- tete : JSON de l'en-tête ; runs64 / couleurs64 : flux base64.
-- taille : taille du cube 1 x 1 x 1 en studs ; inverser : sens des triangles.
function Constructeur.construire(tete: string, runs64: string, couleurs64: string, taille: number, inverser: boolean?): Model
	local h = HttpService:JSONDecode(tete)
	local res = h.res
	local vox = 1 / res
	local runs = base64(runs64)
	local cols = base64(couleurs64)
	local pr, pc = 0, 0
	local pal = {}
	for i = 1, #h.pal, 3 do
		table.insert(pal, Color3.fromRGB(h.pal[i], h.pal[i + 1], h.pal[i + 2]))
	end
	local modele = Instance.new("Model")
	modele.Name = h.nom
	for _, m in h.membres do
		local b0, b1 = m.b0, m.b1
		local dx, dy, dz = b1[1] - b0[1] + 1, b1[2] - b0[2] + 1, b1[3] - b0[3] + 1
		local occ = buffer.create(dx * dy * dz)
		local function idx(x: number, y: number, z: number): number
			return (x * dy + y) * dz + z
		end
		for x = 0, dx - 1 do
			for y = 0, dy - 1 do
				local nr = buffer.readu8(runs, pr)
				pr += 1
				for _ = 1, nr do
					local a = buffer.readu8(runs, pr)
					local l = buffer.readu8(runs, pr + 1)
					pr += 2
					for z = a, a + l - 1 do
						buffer.writeu8(occ, idx(x, y, z), 1)
					end
				end
			end
		end
		local function plein(x: number, y: number, z: number): boolean
			if x < 0 or y < 0 or z < 0 or x >= dx or y >= dy or z >= dz then
				return false
			end
			return buffer.readu8(occ, idx(x, y, z)) == 1
		end
		-- Sommets partagés sur la grille, quads colorés.
		local ids: { [number]: number } = {}
		local px, py, pz = {}, {}, {}
		local quads: { { number } } = {}
		local quadCol: { number } = {}
		local function sommet(x: number, y: number, z: number): number
			local k = (x * 512 + y) * 512 + z
			local id = ids[k]
			if not id then
				table.insert(px, x)
				table.insert(py, y)
				table.insert(pz, z)
				id = #px
				ids[k] = id
			end
			return id
		end
		for x = 0, dx - 1 do
			for y = 0, dy - 1 do
				for z = 0, dz - 1 do
					if plein(x, y, z) then
						local vis = false
						local faces = {}
						for _, f in FACES do
							local nx, ny, nz = x, y, z
							if f[1] == 0 then
								nx += f[2]
							elseif f[1] == 1 then
								ny += f[2]
							else
								nz += f[2]
							end
							if not plein(nx, ny, nz) then
								vis = true
								table.insert(faces, f[4])
							end
						end
						if vis then
							local ci = buffer.readu8(cols, pc) + 1
							pc += 1
							for _, coins in faces do
								local q = {}
								for i, c in coins do
									q[i] = sommet(x + c[1], y + c[2], z + c[3])
								end
								table.insert(quads, q)
								table.insert(quadCol, ci)
							end
						end
					end
				end
			end
			if x % 8 == 0 then
				task.wait()
			end
		end
		-- Arrondi léger : 2 passes, chaque sommet glisse vers ses voisins.
		local n = #px
		for _ = 1, 2 do
			local sx, sy, sz, nb = table.create(n, 0), table.create(n, 0), table.create(n, 0), table.create(n, 0)
			for _, q in quads do
				for i = 1, 4 do
					local a, b = q[i], q[i % 4 + 1]
					sx[a] += px[b]; sy[a] += py[b]; sz[a] += pz[b]; nb[a] += 1
					sx[b] += px[a]; sy[b] += py[a]; sz[b] += pz[a]; nb[b] += 1
				end
			end
			for i = 1, n do
				px[i] += 0.55 * (sx[i] / nb[i] - px[i])
				py[i] += 0.55 * (sy[i] / nb[i] - py[i])
				pz[i] += 0.55 * (sz[i] / nb[i] - pz[i])
			end
		end
		-- Positions en studs (repère de la créature), centre du membre.
		local mn, mx = Vector3.one * math.huge, -Vector3.one * math.huge
		local pos = table.create(n)
		for i = 1, n do
			local p = Vector3.new(
				((px[i] + b0[1]) * vox - 0.5) * taille,
				((py[i] + b0[2]) * vox - 0.5) * taille,
				((pz[i] + b0[3]) * vox - 0.5) * taille
			)
			pos[i] = p
			mn = mn:Min(p)
			mx = mx:Max(p)
		end
		local centre = (mn + mx) / 2
		local em = AssetService:CreateEditableMesh()
		local vid = table.create(n)
		for i = 1, n do
			vid[i] = em:AddVertex(pos[i] - centre)
		end
		local colId: { [number]: number } = {}
		for qi, q in quads do
			local ci = quadCol[qi]
			local c = colId[ci]
			if not c then
				c = em:AddColor(pal[ci], 1)
				colId[ci] = c
			end
			local a, b, cc, d = vid[q[1]], vid[q[2]], vid[q[3]], vid[q[4]]
			local t1, t2
			if inverser then
				t1 = em:AddTriangle(a, cc, b)
				t2 = em:AddTriangle(a, d, cc)
			else
				t1 = em:AddTriangle(a, b, cc)
				t2 = em:AddTriangle(a, cc, d)
			end
			em:SetFaceColors(t1, { c, c, c })
			em:SetFaceColors(t2, { c, c, c })
			if qi % 3000 == 0 then
				task.wait()
			end
		end
		local part = AssetService:CreateMeshPartAsync(Content.fromObject(em))
		part.Name = m.n
		part.Anchored = true
		part.CanCollide = false
		part.Size = mx - mn
		part.CFrame = CFrame.new(centre)
		part:SetAttribute("Role", m.r)
		part:SetAttribute("Joint", Vector3.new(m.j[1], m.j[2], m.j[3]) * taille)
		part:SetAttribute("Cote", m.c)
		part:SetAttribute("Phase", m.ph)
		part:SetAttribute("Parent", m.p)
		part.Parent = modele
		task.wait()
	end
	return modele
end

return Constructeur
