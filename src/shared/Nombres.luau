--!strict
-- Grands nombres lisibles (logique pure, testable avec Lune) :
-- 999 -> « 999 », 1 234 -> « 1 234 », 1 234 567 -> « 1,23 M », 4,5e12 -> « 4,5 T ».
local Nombres = {}

local SUFFIXES = {
	"M",
	"Md",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"Dc",
	"UDc",
	"DDc",
	"TDc",
	"QaDc",
	"QiDc",
	"SxDc",
	"SpDc",
	"OcDc",
	"NoDc",
	"Vg",
}

local function separer(n: number): string
	local brut = string.format("%d", math.floor(n))
	local resultat = string.gsub(string.reverse(brut), "(%d%d%d)", "%1 ")
	return (string.gsub(string.reverse(resultat), "^ ", ""))
end

function Nombres.abreger(n: any): string
	if type(n) ~= "number" or n ~= n then
		return "0"
	end
	if n < 0 then
		return "-" .. Nombres.abreger(-n)
	end
	if n < 1e6 then
		return separer(n)
	end
	if n == math.huge then
		return "∞"
	end
	local rang = math.floor(math.log10(n) / 3) - 1
	if rang > #SUFFIXES then
		-- Au-delà des suffixes : notation scientifique « 1,23e75 ».
		local exposant = math.floor(math.log10(n))
		local mantisse = string.format("%.2f", n / 10 ^ exposant)
		return (string.gsub(mantisse, "%.", ",")) .. "e" .. exposant
	end
	local valeur = n / 10 ^ (3 * (rang + 1))
	local texte = string.format(
		if valeur < 10 then "%.2f" elseif valeur < 100 then "%.1f" else "%.0f",
		valeur
	)
	if string.find(texte, "%.") then
		texte = string.gsub(texte, "0+$", "")
		texte = string.gsub(texte, "%.$", "")
	end
	return (string.gsub(texte, "%.", ",")) .. " " .. SUFFIXES[rang]
end

return Nombres
