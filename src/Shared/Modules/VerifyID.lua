--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Array = require(ReplicatedStorage.Packages.Array)

local validFormat = {8, 4, 4, 4, 12} -- XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
local uuidLength = 38
local function IsValidID(id: string?): boolean
	if not id then return false end

	local firstChar = id:sub(1, 1)
	local lastChar = id:sub(uuidLength, uuidLength)
	local idParts = Array.new("string", id:sub(2, uuidLength - 1):split("-"))

	return #id == uuidLength
		and firstChar == "{"
		and lastChar == "}"
		and id:match("[-][0-9A-Z]") ~= nil
		and #idParts == #validFormat
		and idParts:Reduce(function(isValidFormat, part)
			local validPartLength = validFormat[idParts:IndexOf(part) :: number]
			return (isValidFormat and #part == validPartLength) :: any
		end, true :: any) :: any
end

local function VerifyID(player: Player, id: string?): nil
	-- make sure this is never asynchronous to assure no data is modified if they're kicked
	local valid = IsValidID(id)
	if valid then return end

	player:Kick("Exploiting | Fired signal with an invalid UUID")
	return
end

return VerifyID