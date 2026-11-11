--!nocheck
-- (Content et Enum.CreateContentResult sont plus récents que les types de la CI.)
-- Construit les créatures sculptées en voxels (outils/voxels) à partir des
-- données de Shared.Voxels : faces visibles, arrondi léger, une couleur par
-- voxel, via EditableMesh. Un MeshPart par membre (corps, tête, pattes…),
-- avec les attributs Anim / Joint / Phase / Cote lus par Animations.
-- Les modèles sont construits une fois par espèce (taille 1 : un stud pour
-- le cube de sculpture), puis clonés et mis à l'échelle.
-- Ne marche que si « Enable Mesh / Image APIs » est activé pour le jeu ;
-- sinon construire() renvoie nil et le jeu garde les anciens blocs.
local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ConstructeurVoxels = {}

local dossier = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Voxels")

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local DEC = {}
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
		local v =
			bit32.bor(bit32.lshift(a, 18), bit32.lshift(b, 12), bit32.lshift(c or 0, 6), d or 0)
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

-- Coins unitaires de chaque face (mêmes ordres que sculpteur.py).
local FACES = {
	{ 0, -1, { { 0, 0, 0 }, { 0, 0, 1 }, { 0, 1, 1 }, { 0, 1, 0 } } },
	{ 0, 1, { { 1, 0, 0 }, { 1, 1, 0 }, { 1, 1, 1 }, { 1, 0, 1 } } },
	{ 1, -1, { { 0, 0, 0 }, { 1, 0, 0 }, { 1, 0, 1 }, { 0, 0, 1 } } },
	{ 1, 1, { { 0, 1, 0 }, { 0, 1, 1 }, { 1, 1, 1 }, { 1, 1, 0 } } },
	{ 2, -1, { { 0, 0, 0 }, { 0, 1, 0 }, { 1, 1, 0 }, { 1, 0, 0 } } },
	{ 2, 1, { { 0, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 0, 1, 1 } } },
}

-- Construit un membre : renvoie un MeshPart centré sur son volume.
local function membre(m, runs, cols, curseurs, res, pal): MeshPart
	local vox = 1 / res
	local b0, b1 = m.b0, m.b1
	local dx, dy, dz = b1[1] - b0[1] + 1, b1[2] - b0[2] + 1, b1[3] - b0[3] + 1
	local occ = buffer.create(dx * dy * dz)
	for x = 0, dx - 1 do
		for y = 0, dy - 1 do
			local nr = buffer.readu8(runs, curseurs.r)
			curseurs.r += 1
			for _ = 1, nr do
				local a = buffer.readu8(runs, curseurs.r)
				local l = buffer.readu8(runs, curseurs.r + 1)
				curseurs.r += 2
				for z = a, a + l - 1 do
					buffer.writeu8(occ, (x * dy + y) * dz + z, 1)
				end
			end
		end
	end
	local function plein(x: number, y: number, z: number): boolean
		if x < 0 or y < 0 or z < 0 or x >= dx or y >= dy or z >= dz then
			return false
		end
		return buffer.readu8(occ, (x * dy + y) * dz + z) == 1
	end
	-- Sommets partagés sur la grille, quads colorés.
	local ids = {}
	local px, py, pz = {}, {}, {}
	local quads, quadCol = {}, {}
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
							table.insert(faces, f[3])
						end
					end
					if #faces > 0 then
						local ci = buffer.readu8(cols, curseurs.c) + 1
						curseurs.c += 1
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
		if x % 6 == 0 then
			task.wait()
		end
	end
	-- Arrondi léger : 2 passes, chaque sommet glisse vers ses voisins.
	local n = #px
	for _ = 1, 2 do
		local sx, sy, sz = table.create(n, 0), table.create(n, 0), table.create(n, 0)
		local nb = table.create(n, 0)
		for _, q in quads do
			for i = 1, 4 do
				local a, b = q[i], q[i % 4 + 1]
				sx[a] += px[b]
				sy[a] += py[b]
				sz[a] += pz[b]
				nb[a] += 1
				sx[b] += px[a]
				sy[b] += py[a]
				sz[b] += pz[a]
				nb[b] += 1
			end
		end
		for i = 1, n do
			px[i] += 0.55 * (sx[i] / nb[i] - px[i])
			py[i] += 0.55 * (sy[i] / nb[i] - py[i])
			pz[i] += 0.55 * (sz[i] / nb[i] - pz[i])
		end
	end
	local mn, mx = Vector3.one * math.huge, -Vector3.one * math.huge
	local pos = table.create(n)
	for i = 1, n do
		local p = Vector3.new(
			(px[i] + b0[1]) * vox - 0.5,
			(py[i] + b0[2]) * vox - 0.5,
			(pz[i] + b0[3]) * vox - 0.5
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
	local colId = {}
	for qi, q in quads do
		local ci = quadCol[qi]
		local c = colId[ci]
		if not c then
			c = em:AddColor(pal[ci], 1)
			colId[ci] = c
		end
		local a, b, cc, d = vid[q[1]], vid[q[2]], vid[q[3]], vid[q[4]]
		local t1 = em:AddTriangle(a, b, cc)
		local t2 = em:AddTriangle(a, cc, d)
		em:SetFaceColors(t1, { c, c, c })
		em:SetFaceColors(t2, { c, c, c })
		if qi % 3000 == 0 then
			task.wait()
		end
	end
	-- Le maillage ne change plus : on le fige en contenu opaque et on libère
	-- l'EditableMesh (le budget mémoire client est très serré).
	-- selene: allow(undefined_variable)
	local contenu = Content.fromObject(em)
	local okFige, resultat, fige = pcall(function()
		return AssetService:CreateDataModelContentAsync(contenu)
	end)
	local part
	if okFige and resultat == Enum.CreateContentResult.Success then
		part = AssetService:CreateMeshPartAsync(fige)
		em:Destroy()
	else
		part = AssetService:CreateMeshPartAsync(contenu)
	end
	part.Name = m.n
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Size = mx - mn
	part.CFrame = CFrame.new(centre)
	part:SetAttribute("Voxel", true)
	if m.r then
		part:SetAttribute("Anim", m.r)
		part:SetAttribute("Joint", Vector3.new(m.j[1], m.j[2], m.j[3]))
		part:SetAttribute("Phase", m.ph or 0)
		part:SetAttribute("Cote", m.c or 0)
	end
	return part
end

local modeles: { [string]: Model | false } = {}
local enCours: { [string]: boolean } = {}

-- Vrai si l'espèce a un modèle sculpté en voxels.
function ConstructeurVoxels.existe(nom: string?): boolean
	return type(nom) == "string" and dossier:FindFirstChild(nom) ~= nil
end

-- Modèle de l'espèce à la taille 1 (construit une seule fois, peut attendre
-- quelques images). Renvoie nil si l'espèce n'existe pas ou si EditableMesh
-- est indisponible.
function ConstructeurVoxels.modele(nom: string): Model?
	while enCours[nom] do
		task.wait()
	end
	local deja = modeles[nom]
	if deja ~= nil then
		return if deja then deja else nil
	end
	local source = dossier:FindFirstChild(nom)
	if source == nil or not source:IsA("ModuleScript") then
		return nil
	end
	enCours[nom] = true
	local ok, resultat = pcall(function()
		local donnees = (require :: any)(source)
		local h = HttpService:JSONDecode(donnees.tete)
		local runs = base64(donnees.runs)
		local cols = base64(donnees.cols)
		local pal = {}
		for i = 1, #h.pal, 3 do
			table.insert(pal, Color3.fromRGB(h.pal[i], h.pal[i + 1], h.pal[i + 2]))
		end
		local m = Instance.new("Model")
		m.Name = nom
		local curseurs = { r = 0, c = 0 }
		for _, infos in h.membres do
			membre(infos, runs, cols, curseurs, h.res, pal).Parent = m
		end
		return m
	end)
	if not ok then
		warn("ConstructeurVoxels", nom, resultat)
	end
	modeles[nom] = if ok then resultat else false
	enCours[nom] = nil
	return if ok then resultat else nil
end

-- Vrai si le modèle de l'espèce est déjà prêt (aucune attente).
function ConstructeurVoxels.pret(nom: string): boolean
	return modeles[nom] ~= nil and not enCours[nom]
end

return ConstructeurVoxels
