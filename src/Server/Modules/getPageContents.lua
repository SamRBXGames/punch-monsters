local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Array = require(ReplicatedStorage.Packages.Array)

return function(pageManager: Pages): typeof(Array)
	local contents = Array.new()
	while not pageManager.IsFinished do
		local page = pageManager:GetCurrentPage()
		for _, item in page do
			contents:Push(item)
			pageManager:AdvanceToNextPageAsync();
		end
	end

	return contents
end