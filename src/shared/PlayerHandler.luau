local PlayerHandler = {}
-- sanity, player states, etc.
local AnimIds = {
	["UseScrewDriver"] =  { 
		ID ="76056621378751",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action
	} ,
	["ScrewDriverIdle"] = { 
		ID = "129357933421302",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action
	} ,
	["UseKeycard"] = { 
		ID = "106426491375521",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action
	} ,
	["IdleKeycard"] = { 
		ID = "81365979300704",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action
	} ,
	["CrouchIdle"] = { 
		ID = "134350729619136",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action
	} ,
	["CrouchWalk"] = { 
		ID = "116894855803075",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action
	} ,
	["StandIdle"] ={ 
		ID = "102371670280569",
		Speed = 1,
		Priority = Enum.AnimationPriority.Idle
	} ,
	["StandWalk"] = { 
		ID = "134592967058819",
		Speed = 2,
		Priority = Enum.AnimationPriority.Action
	} ,
	["StandRun"] = {
		ID = "140225189234928",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action
	} ,
	["KnifeIdle"] = {
		ID = "94794742348120",
		Speed = 1,
		Priority = Enum.AnimationPriority.Idle
	},
	["KnifeStab"] = {
		--quickjab 113756979406227
		--chargestab 123857460779686
		ID = "113756979406227",
		Speed = 2,
		Priority = Enum.AnimationPriority.Action2	
	},
	["KnifeHeavyStab"] = { --Higher chance of ragdoll? higher bleed?
		ID = "123857460779686",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action2
	},
	["KnifeEquip"] = {
		ID = "126072690832871",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action
	},
	["TazerEquip"] ={ 
		ID = "101669828026601",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action
	},
	["TazerIdle"] ={ 
		ID = "93041147253369",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action
	},
	["TazerFire"] = {
		ID = "74503836601898",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action
	},
	["TazerReload"] = {
		ID = "136746765385103",
		Speed = 1,
		Priority = Enum.AnimationPriority.Action
	}
	
	
}
local allTracks = {}
local rs = game:GetService("ReplicatedStorage")
local InputEv = rs.ClientLibs.InputHandler.InputEv
warn("PlayerHandler")

function PlayerHandler.MovementTracker(plr:Player) --< On Plr added, (bec things should only be created once ever)
	local function resetMovement()
		plr:SetAttribute("Crouching", false)
		plr:SetAttribute("Walking", false)
		plr:SetAttribute("Sprinting", false)
	end
	--// the tracker works as the CONTEXT, it allows state changes, IF the context is met
	--//no context implemented yet
	local function TrackCharWalking()
		local hu : Humanoid = plr.Character:WaitForChild("Humanoid")
		--requires character, to check walking
		hu:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			plr:SetAttribute("Walking",hu.MoveDirection.Magnitude > 0)
		end)
	end
	
	if plr.Character then
		--RESETING MOVEMENT & tracking walking
		resetMovement()
		TrackCharWalking()
	end
	plr.CharacterAdded:Connect(function()
		--RESETING MOVEMENT & tracking walking
		resetMovement()
		TrackCharWalking()
	end)

	-- this is ONLY OK because it is not dependant on ANYTHING OUTSIDE THIS SCIRPT, (and its called before char dependancy's bec its called on server)
	
	local InputEvConnection
	warn("// HEY IM BOUTA CONNECT A EVENT")
	InputEvConnection = InputEv.OnServerEvent:Connect(function(TriggeringPlr,actionName,State)
			if TriggeringPlr ~=  plr then return end
			if actionName == "CrouchKEY" then
				plr:SetAttribute("Crouching",State)
			elseif	actionName == "SprintKEY" then
				plr:SetAttribute("Sprinting",State)
			end

		end)
	

	plr.AncestryChanged:Connect(function(_,parent)
		if not parent and InputEvConnection then
			InputEvConnection:Disconnect()
			InputEvConnection = nil
		end
	end)

end

function PlayerHandler.MovementHandler(plr: Player) --< requires Movement Tracker to have ran (RUN ONCE FOR THE PLAYER)
	
	local function HandleMovment()--<call me when ALL and EVERY attribute changeSingnal
		--this is just so that the Anim tracks only get called after the CHARCTER has been added
		local hu : Humanoid = plr.Character:WaitForChild("Humanoid")
		--get your anim tracks
		local CrouchWalk : AnimationTrack = PlayerHandler.getTrack(plr,"CrouchWalk")
		local StandIdle : AnimationTrack = PlayerHandler.getTrack(plr,"StandIdle")
		local CrouchIdle : AnimationTrack = PlayerHandler.getTrack(plr,"CrouchIdle")
		local StandWalk : AnimationTrack = PlayerHandler.getTrack(plr,"StandWalk")
		local StandRun : AnimationTrack = PlayerHandler.getTrack(plr,"StandRun")
		--extra logic that doesnt let you stand if something is above you?
		
		--run your logic
		--stop all anims
		StandIdle:Stop()
		CrouchIdle:Stop()
		StandWalk:Stop()
		StandRun:Stop()
		CrouchWalk:Stop()
		if hu.Health > 0 then
		if plr:GetAttribute("Walking") == true then
				if plr:GetAttribute("Crouching") == true then -- if walking and holding crouch, only play this
				warn("*PLAY: crouchwalk")
				hu.WalkSpeed = 6
				CrouchWalk:Play()
				
				elseif plr:GetAttribute("Sprinting") == true then -- not crouching, but holding run
				warn("*PLAY: sprint")
				hu.WalkSpeed = 22
				StandRun:Play()
				elseif plr:GetAttribute("Sprinting") == false then
				warn("*PLAY: walk")
				hu.WalkSpeed = 10
				
				StandWalk:Play()
			end
			
			
		else

				if plr:GetAttribute("Crouching") == true then -- if walking and holding crouch, only play this
				warn("*PLAY: crouchidle")
				CrouchIdle:Play()
			else
				warn("*PLAY: standidle")
				StandIdle:Play()
			end

		end
		end

		
	end
	

	
	plr:GetAttributeChangedSignal("Walking"):Connect(function()
		warn("DETECTED WALKING")
		HandleMovment()
	end)

	plr:GetAttributeChangedSignal("Crouching"):Connect(function()
		warn("DETECTED CROUCHING")
		HandleMovment()
	end)
	plr:GetAttributeChangedSignal("Sprinting"):Connect(function()
		warn("DETECTED Sprinting")
		HandleMovment()
	end)
end

-- this updates whenver the character is added!! 
function PlayerHandler.LoadAnimationTracks(plr : Player)
	local hu  :Humanoid= plr.Character:WaitForChild("Humanoid")
	local Animator : Animator = hu:WaitForChild("Animator")
	local AnimationsFolder = Instance.new("Folder")
	AnimationsFolder.Name = "AnimationsFolder"
	AnimationsFolder.Parent = plr.Character
	
	allTracks[plr] = {}

	for AnimName,AnimTbl in pairs(AnimIds) do
		local anim : Animation = Instance.new("Animation")
		anim.Name = AnimName
		anim.Parent = AnimationsFolder
		anim.AnimationId = "rbxassetid://" .. AnimIds[AnimName].ID
		local track : AnimationTrack = Animator:LoadAnimation(anim)
		track:AdjustSpeed(AnimIds[AnimName].Speed)
		track.Priority = AnimIds[AnimName].Priority
		warn(tostring(track) .. tostring(track.Speed) )
		allTracks[plr][AnimName] = track
	end
	hu.Died:Connect(function()
		warn("*--STOPPING ALL Playing TRACKS--")
		for _,Track in pairs(Animator:GetPlayingAnimationTracks()) do
			warn("*" .. tostring(Track) .. ":Stop()" )
			Track:Stop()
		end
		allTracks[plr] = nil
		warn("*tracks removed")
	end)

	plr.CharacterRemoving:Connect(function()
		warn("CLEANING UP PLAYER TRACKS FOR " .. plr.DisplayName)
		allTracks[plr] = nil
		warn(allTracks)
	end)

	

end

function PlayerHandler.getTrack(plr: Player,AnimName)
	return allTracks[plr][AnimName]
end

--when player leaves, remove their tracks
function PlayerHandler.cleanTracks()
	
end

function PlayerHandler.LocalPlrInit()

end

return PlayerHandler
