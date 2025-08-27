--//serivces
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local serverScriptService = game:GetService("ServerScriptService")
local rs = game:GetService("ReplicatedStorage")
local soundSerice = game:GetService("SoundService")
--//modules
local profileStore = require(script.ProfileStore)
local TeamSelect = require(rs.Shared.TeamSelect)
local VentHandler = require(rs.Shared.VentHandler)
local SearchableHandler = require(rs.Shared.SearchableHandler)
local PlayerHandler = require(rs.Shared.PlayerHandler)
local KeyreaderHandler = require(rs.Shared.KeyreaderHandler)
local ragdollHandler = require(rs.Shared.RagdollHandler)
local ToolHandler = require(rs.Shared.ToolHandler)
--/ 

local function GetStoreName()
	return "GAME_DATABASE"
end

local Template = require(script.Template)
local DataManager = require(script.DataManager)
--access profileStore
local PlayerStore = profileStore.New(GetStoreName(),Template)
-- add leaderstats and sync playerdata
local function initialize(plr : Player,profile: typeof(PlayerStore:StartSessionAsync()))
	warn("init...")
end

local function playerInit(plr: Player)
	local profile = PlayerStore:StartSessionAsync("Player_" .. plr.UserId, {
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



local function onCharcterAdded(plr,profile)
	warn("----------------- CHAR ADDED-----------------------")
	
	--MISC
	TeamSelect.HandleJoinRq()
	PlayerHandler.LoadAnimationTracks(plr)
	ragdollHandler.Set(plr.Character)
	--display data
	--stimulate data
	
	DataManager.addcoin(plr,0)
	DataManager.addMinute(plr,0)
	local plrHu : Humanoid = plr.Character:WaitForChild("Humanoid")
	plrHu.Died:Connect(function() -- bec humanoid is destoryed on death, died Disconnects itself after being called... lame
		warn(plr.DisplayName .. " Died.")
		ragdollHandler.Ragdoll(plr.Character)
	end)	
	

end

local function onPlayerAdded(plr)
	--warn("plr added")
	playerInit(plr)
	local profile = DataManager.Profiles[plr]
	warn("----------------- PLAYER ADDED -----------------------")
	-- STIM LOCAL DATA (just stimulates local & server data,UI and items immediately show ) --
	
	--movment tracker has a event that keeps creating things, must clean
	PlayerHandler.MovementTracker(plr)
	PlayerHandler.MovementHandler(plr)
	-- if statement below, is so that the code still runs, EVEN IF the charcter is added BEFORE the event that runs the code is added :)
	if plr.Character then
		onCharcterAdded(plr,profile)
	end
	-------------
	
	-- connect characterAdded event
	plr.CharacterAdded:Connect(function()
		onCharcterAdded(plr,profile)
	end)
	
	plr.CharacterRemoving:Connect(function()
		warn("CHARCTER REMOVED")
	end)
	--

end
--//OnServerStart

VentHandler.setup()
SearchableHandler.ServInit()
KeyreaderHandler.ServInit()




--// EVENTS
Players.PlayerAdded:Connect(function(plr)
	onPlayerAdded(plr)
end)




for _, plr in Players:GetPlayers() do
	task.spawn(playerInit,plr)
end

--
Players.PlayerRemoving:Connect(function(plr)
	warn("REMOVING:" .. plr.DisplayName)
	local profile = DataManager.Profiles[plr]
	if not profile then	return end
	profile:EndSession()
	DataManager.Profiles[plr] = nil
end)

--/for every current Rig
task.wait(3)
for _,Decendant in pairs(game.Workspace:GetDescendants()) do

	if Decendant:IsA("Model") and Decendant:FindFirstChildWhichIsA("Humanoid") then
		warn("GOT A RIG TO SET:" .. tostring(Decendant))
		ragdollHandler.Set(Decendant)
	end
end