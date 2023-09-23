--!native
--!strict

-- trims whitespaces
local function trim(s: string): string
	local i1: number?, i2: number? = s:find("^%s*")
	if i1 and i2 then
		if i2 >= i1 then
			s = s:sub(i2 + 1)
		end
	end

	i1, i2 = s:find("%s*$")
	if i1 and i2 then
		if i2 >= i1 then
			s = s:sub(1, i1 - 1)
		end
	end
	return s
end

return trim