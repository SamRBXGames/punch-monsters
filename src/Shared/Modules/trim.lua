-- trims whitespaces
local function trim(s: string): string
	local i1,i2 = s:find("^%s*")
	if i2 >= i1 then
		s = s:sub(i2 + 1)
	end
	local i1,i2 = s:find("%s*$")
	if i2 >= i1 then
		s = s:sub(1, i1 - 1)
	end
	return s
end

return trim