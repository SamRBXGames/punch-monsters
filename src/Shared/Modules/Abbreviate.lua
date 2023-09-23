--!native
--!strict
local Abbreviations = {
	["K"] = 4,
	["M"] = 7,
	["B"] = 10,
	["T"] = 13,
	["Qd"] = 16,
	["Qi"] = 19,
	["Se"] = 22,
	["Sp"] = 25,
	["O"] = 28,
	["No"] = 31,
	["D"] = 34,
	["Un"] = 37,
}

return function(n: number)
	if not n then return end
	local text = ("%.f"):format(math.floor(n))
	local chosenAbbreviation
	
	for abbreviation, digit in pairs(Abbreviations) do
		if #text >= digit and #text < (digit + 3) then
			chosenAbbreviation = abbreviation
			break
		end
	end

	if chosenAbbreviation then
		local digits = Abbreviations[chosenAbbreviation]
		local rounded = math.floor(n / 10 ^  (digits - 2)) * 10 ^  (digits - 2)
		text = ("%.1f"):format(rounded / 10 ^ (digits - 1)) .. chosenAbbreviation
	end

	return if chosenAbbreviation then text else tostring(n)
end