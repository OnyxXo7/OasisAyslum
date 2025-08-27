local KeyreaderHandler = {}
local collectionService = game:GetService("CollectionService")

local OpenPeriod = 3



--this feels reduant? almost unessaraym, maybe the keycard should handle opening the door itself?
function KeyreaderHandler.ServInit()
	for _,KeyReader in pairs(collectionService:GetTagged("KeyReader")) do
		local KeyReaderHitbox = KeyReader.KeyReaderHitbox
		local door = KeyReaderHitbox.Door.Value
		local DoorLocked = door.Parent.Locked
		local Clearance = KeyReaderHitbox.Clearance
		DoorLocked.Value = true
		
		Clearance.Changed:Connect(function()
			if DoorLocked.Value == true then
				--Play Clearance Sound
				DoorLocked.Value = false
				task.wait(OpenPeriod)
				DoorLocked.Value = true
				Clearance.Value = false
			end
			
		end)
	end
end


return KeyreaderHandler
