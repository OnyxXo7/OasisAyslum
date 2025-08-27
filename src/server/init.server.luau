--//serivces
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local serverScriptService = game:GetService("ServerScriptService")
local rs = game:GetService("ReplicatedStorage")
--//modules
local DataInitilizer = require(script.DataInitializer)
local DataManager = require(script.DataManager)
local TeamSelect = require(rs.Shared.TeamSelect)
local VentHandler = require(rs.Shared.VentHandler)
local SearchableHandler = require(rs.Shared.SearchableHandler)
local PlayerHandler = require(rs.Shared.PlayerHandler)
local KeyreaderHandler = require(rs.Shared.KeyreaderHandler)
local ragdollHandler = require(rs.Shared.RagdollHandler)


local function onCharacterAdded(plr) --/ profile may be used for 
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

local function onCharacterRemoved(plr)
	if not plr or not plr.Character then return end
	warn("CHARACTER REMOVED: " .. plr.Character)
end

local function onPlayerAdded(plr)
	--warn("plr added")
	--// init playerdata
	DataInitilizer.playerInit(plr)
	local profile = DataManager.Profiles[plr]
	warn("----------------- PLAYER ADDED -----------------------")
	-- STIM LOCAL DATA (just stimulates local & server data,UI and items immediately show ) --
	
	--movment tracker has a event that keeps creating things, must clean
	PlayerHandler.MovementTracker(plr)
	PlayerHandler.MovementHandler(plr)
	-- if statement below, is so that the code still runs, EVEN IF the charcter is added BEFORE the event that runs the code is added :)
	if plr.Character then
		onCharacterAdded(plr)
	end
	-------------
	
	-- connect characterAdded event
	plr.CharacterAdded:Connect(function()
		onCharacterAdded(plr)
	end)
	
	plr.CharacterRemoving:Connect(function()
		onCharacterRemoved(plr)
	end)
	--

end
local function onPlayerRemoved(plr)
		warn("REMOVING:" .. plr.DisplayName)
		local profile = DataManager.Profiles[plr]
		if not profile then	return end
		profile:EndSession()
		DataManager.Profiles[plr] = nil
end

--//OnServerStart



local function initialize()
	--//SERVER INITIALIZER
	VentHandler.setup()
	SearchableHandler.ServInit()
	KeyreaderHandler.ServInit()




	--//PLAYER INITIALIZER
	for _, plr in Players:GetPlayers() do
		--task.spawn(DataInitilizer.playerInit,plr) -- i don't think i need this? not sure
		onPlayerAdded(plr)
	end
	Players.PlayerAdded:Connect(function(plr)
		onPlayerAdded(plr)
		plr.CharacterAdded:Connect(function()
			onCharacterAdded(plr)
		end)
	end)
	Players.PlayerRemoving:Connect(function(plr)
		onPlayerRemoved(plr)
	end)


	task.wait(3)

	for _,Decendant in pairs(game.Workspace:GetDescendants()) do

		--/for every current Rig 
		if Decendant:IsA("Model") and Decendant:FindFirstChildWhichIsA("Humanoid") then
			--setup all current rigs with ragdollHandler
			ragdollHandler.Set(Decendant)
		end
	end
end

initialize()
