local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")

local getPageContents = require(ServerScriptService.Server.Modules.getPageContents)
local Array = require(ReplicatedStorage.Packages.Array)
local PurchaseHistory = DataStoreService:GetDataStore("PurchaseHistory")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local TransactionService = Knit.CreateService {
	Name = "TransactionService"
}

function TransactionService:KnitStart()
	local DataService = Knit.GetService("DataService")
	local BoostService = Knit.GetService("BoostService")
	local PurchaseLogger = Knit.GetService("PurchaseLogService")
	
	local ProductFunctions = {
		[1631383839] = function(player: Player) -- win1
			DataService:IncrementValue(player, "Wins", 2_500)
		end,
		[1631383838] = function(player: Player) -- win2
			DataService:IncrementValue(player, "Wins", 15_000)
		end,
		[1631385713] = function(player: Player) -- win3
			DataService:IncrementValue(player, "Wins", 55_000)
		end,
		[1631385717] = function(player: Player) -- win4
			DataService:IncrementValue(player, "Wins", 200_000)
		end,
		[1631385715] = function(player: Player) -- win5
			DataService:IncrementValue(player, "Wins", 1_000_000)
		end,
		[1631385718] = function(player: Player) -- win6
			DataService:IncrementValue(player, "Wins", 5_000_000)
		end,
		[1631385716] = function(player: Player)
			BoostService:Activate10xLuckBoost(player)
		end,
		[1631387042] = function(player: Player)
			BoostService:Activate100xLuckBoost(player)
		end,
		[1631387040] = function(player: Player)
			BoostService:ActivateDoubleWinsBoost(player)
		end,
		[1631387043] = function(player: Player)
			BoostService:ActivateDoubleStrengthBoost(player)
		end
	}
	
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passID, wasPurchased)
		if not wasPurchased then return end
		PurchaseLogger:Log(player, passID, true)
	end)
	
	function MarketplaceService.ProcessReceipt(receipt)
		local playerProductKey = receipt.PlayerId .. "_" .. receipt.PurchaseId
		local purchased = false

		local success, errorMessage = pcall(function()
			purchased = PurchaseHistory:GetAsync(playerProductKey)
		end)

		if success and purchased then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		elseif not success then
			error("Data store error:" .. errorMessage)
		end

		local success, isPurchaseRecorded = pcall(function()
			return PurchaseHistory:UpdateAsync(playerProductKey, function(alreadyPurchased)
				if alreadyPurchased then return true end
				
				local player = Players:GetPlayerByUserId(receipt.PlayerId)
				if not player then return nil end

				local handleProduct = ProductFunctions[receipt.ProductId]
				if not handleProduct then
					return error("Missing dev product handler function in TransactionService")
				end

				local success, err = pcall(function()
					task.spawn(handleProduct, player)
				end)
				if not success then
					error(`Failed to process a product purchase for {player.Name}, ProductId: {receipt.ProductId}.  Error: {err}`)
					return nil
				end
				
				task.spawn(function()
					local player = Players:GetPlayerByUserId(receipt.PlayerId)
					local devProductIDs = Array.new("table", getPageContents(MarketplaceService:GetDeveloperProductsAsync()):ToTable())
						:Map(function(product)
							return product.ProductId
						end)

					PurchaseLogger:Log(player, receipt.ProductId, devProductIDs:Has(receipt.ProductId))
				end)
				
				return true
			end)
		end)


		if not success then
			error(isPurchaseRecorded)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		elseif isPurchaseRecorded == nil then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		else	
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
end

return TransactionService