local SearchableHandler = {}
local collectionService = game:GetService("CollectionService")
local rs = game:GetService("ReplicatedStorage")
local ToolHandler = require(rs.Shared.ToolHandler)
local searchableItems = rs.Resources.Tools:GetChildren()
function SearchableHandler.ServInit()
	for _,Searchable in pairs(collectionService:GetTagged("Searchable")) do
		local SearchableModel : Part =  Searchable.TrashModels.Searchable
		local SearchedModel : Part = Searchable.TrashModels.Searched
		local SearchPart = Searchable.SearchPart
		local Search : ProximityPrompt = SearchPart.ProximityPrompt
		local OpenTrashSound : Sound = SearchPart.OpenTrash

		Search.Triggered:Connect(function(plr)
			SearchableModel.Transparency = 1
			SearchedModel.Transparency = 0
			OpenTrashSound:Play()
			local index = math.random(1,#searchableItems)
			local Tool = searchableItems[index]:Clone()
			warn("Searched, Got " .. Tool.Name .. ".")
			
			ToolHandler.addLogic(Tool)
			Tool.Parent = plr.Backpack
		end)
	end
end
--
return SearchableHandler
