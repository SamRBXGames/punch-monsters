local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage.Packages

local AssertPlayer = require(ServerScriptService.Server.Modules.AssertPlayer)
local Knit = require(Packages.Knit)

local WEBHOOK_URL = require(script.Webhook)
script.Webhook:Destroy()

local PurchaseLogService = Knit.CreateService {
	Name = "PurchaseLogService"
}

function PurchaseLogService:KnitStart(): nil
	self._data = Knit.GetService("DataService")
	return
end

function PurchaseLogService:Log(player: Player, productID: number, isGamepass: boolean): nil
	AssertPlayer(player)
	local infoType = Enum.InfoType[if isGamepass  then "GamePass" else "Product"]
	local productInfo = MarketplaceService:GetProductInfo(productID, infoType)

	HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode({
		username = "Purchase Logger",
		embeds = {
			{
				title = `{if isGamepass then "Gamepass" else "Dev Product"} Purchased!`,
				author = {
					name = player.Name,
					url = `https://www.roblox.com/users/{player.UserId}/profile`
				},
				fields = {
					{
						name = "Product Name",
						value = productInfo.Name,
						inline = true
					}, {
						name = "Robux Earned",
						value = `R${math.floor(productInfo.PriceInRobux * 0.70)}`,
						inline = true
					}
				},
				timestamp = DateTime.fromIsoDate(productInfo.Updated),
				color = 0x00ff7f
			}
		}
	}))

	task.spawn(function()
		local productLog = self._data:GetValue(player, "ProductsLog")
		table.insert(productLog, {
			ID = productID,
			PurchaseTime = tick()
		})
		self._data:SetValue(player, "ProductsLog", productLog)
	end)

	return
end

return PurchaseLogService