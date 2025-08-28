local DataInitializer = {}

local ProfileStore = require(script.Parent.ProfileStore)
local DataManager = require(script.Parent.DataManager)
local Template = require(script.Parent.Template)
local Players = game:GetService("Players")

--access profileStores
local PlayerStores = ProfileStore.New("GAME_DATABASE",Template)

function DataInitializer.PlayerInit(plr : Player)

--/is type of important?


--[[ may be important
local function initialize(plr : Player,profile: typeof(PlayerStore:StartSessionAsync()))
	warn("init...")
end
]]
	local profile = PlayerStores:StartSessionAsync("Player_" .. plr.UserId, {
		Cancel = function()
			return plr.Parent ~= Players
		end,
	})
	
	-- Get Proflile Singleton --
	if profile ~= nil then
		profile:AddUserId(plr.UserId)
		profile:Reconcile()

		--handles session locking --
		profile.OnSessionEnd:Connect(function()
			DataManager.Profiles[plr] = nil
			print("session end")
			plr:Kick("Data err occured, session ended")
		end)

		if plr.Parent == Players then
			DataManager.Profiles[plr] = profile
		else
			profile:EndSession()
		end

	else
		plr:Kick("Data error occured")
	end
end

return DataInitializer