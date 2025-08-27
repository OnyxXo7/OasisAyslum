local Restrictions = RaycastParams.new()
Restrictions.FilterType = Enum.RaycastFilterType.Exclude
Restrictions.IgnoreWater = true

local RAGDOLLONDEATH = true

local RagdollHandler = {}

function RagdollHandler.Set(Character: Model)
	local Hum = Character:FindFirstChildWhichIsA("Humanoid")
	if not Hum then
		warn("didn't get rig Humnaoid :<  |"..Character.Name )
		return 
	end
	Hum.RequiresNeck = false
	Hum.BreakJointsOnDeath = false
	if RAGDOLLONDEATH then
		warn(Character.Name)
		Hum.Died:Once(function()
			RagdollHandler.Ragdoll(Character)
		end)
	end
end
--//ragdolls will only run if their NOT already ragdolled (tracked using attributes)

--//passed value should check if its a RIG itself
function RagdollHandler.Ragdoll(Character: Model)
	if Character:GetAttribute("ragdolled") then return end
	Character:GetAttribute("ragdolled",true)
	
	local HRP: BasePart = Character.HumanoidRootPart
	local Torso: BasePart = Character.Torso
	local Hum = Character:FindFirstChildWhichIsA("Humanoid")
	local RootJoint: Motor6D = HRP.RootJoint
	if not HRP:FindFirstChild("TorsoWeld") then
		local TorsoWeld = Instance.new("Weld")
		TorsoWeld.Part0 = HRP
		TorsoWeld.Part1 = Torso
		TorsoWeld.Name = "TorsoWeld"
		TorsoWeld:AddTag("RagdollStuff")
		TorsoWeld.Parent = HRP
	end
	RootJoint.Enabled = false
	HRP.Massless = true
	task.wait()
	Hum.JumpPower = 0
	Hum.WalkSpeed = 0
	Hum.PlatformStand = true
	Hum.AutoRotate = false
	for _, PossibleMotor6D in pairs(Character:GetDescendants()) do
		if not PossibleMotor6D:IsA("Motor6D") or PossibleMotor6D == RootJoint or PossibleMotor6D.Enabled == false then continue end
		local ColliderPart = Instance.new("Part")
		ColliderPart.Size = PossibleMotor6D.Part1.Size / 1.7
		ColliderPart.CFrame = PossibleMotor6D.Part1.CFrame
		ColliderPart.Massless = true
		ColliderPart.CanQuery = false
		ColliderPart.CanTouch = false
		ColliderPart.Transparency = 1
		ColliderPart.Name = "ColliderPart"
		ColliderPart:AddTag("RagdollStuff")
		ColliderPart.Parent = Character
		local ColliderPartWeld = Instance.new("Weld")
		ColliderPartWeld.Part0 = ColliderPart
		ColliderPartWeld.Part1 = PossibleMotor6D.Part1
		ColliderPartWeld.Name = "ColliderPartWeld"
		ColliderPartWeld:AddTag("RagdollStuff")
		ColliderPartWeld.Parent = ColliderPart
		local RagdollAttach0 = Instance.new("Attachment")
		RagdollAttach0.CFrame = PossibleMotor6D.C0
		RagdollAttach0.Name = "RagdollAttach0"
		RagdollAttach0:AddTag("RagdollStuff")
		RagdollAttach0.Parent = PossibleMotor6D.Part0
		local RagdollAttach1 = Instance.new("Attachment")
		RagdollAttach1.CFrame = PossibleMotor6D.C1
		RagdollAttach1.Name = "RagdollAttach1"
		RagdollAttach1:AddTag("RagdollStuff")
		RagdollAttach1.Parent = PossibleMotor6D.Part1
		local RagdollConstraint = Instance.new("BallSocketConstraint")
		RagdollConstraint.Attachment0 = RagdollAttach0
		RagdollConstraint.Attachment1 = RagdollAttach1
		RagdollConstraint.LimitsEnabled = true
		RagdollConstraint.TwistLimitsEnabled = true
		RagdollConstraint.Name = "RagdollConstraint"
		RagdollConstraint:AddTag("RagdollStuff")
		RagdollConstraint.Parent = Character
		PossibleMotor6D.Enabled = false
	end
end
--//passed value should check if its a RIG itself
function RagdollHandler.UnRagdoll(Character: Model)
	if not Character:GetAttribute("ragdolled") then return end
	Character:GetAttribute("ragdolled",false)
	
	local Hum = Character:FindFirstChildWhichIsA("Humanoid")
	if Hum.Health <= 0 then return end
	local HRP: BasePart = Character.HumanoidRootPart
	HRP.Massless = false
	game["Run Service"].Heartbeat:Wait()
	task.wait()
	HRP.Anchored = true
	local GetUpCFrame = CFrame.new(HRP.Position)
	Restrictions.FilterDescendantsInstances = {Character}
	local GetUpRayEnd = HRP.Position + Vector3.new(0, -3, 0) - HRP.Position
	local GetUpRay = game.Workspace:Raycast(HRP.Position, GetUpRayEnd, Restrictions)
	if GetUpRay then
		GetUpCFrame = CFrame.new(GetUpRay.Position + Vector3.new(0, 3, 0))
	end
	HRP.CFrame = GetUpCFrame
	Hum.PlatformStand = false
	game["Run Service"].Heartbeat:Wait()
	Hum.AutoRotate = true
	HRP.Anchored = false
	for _, BodyPart in pairs(Character:GetDescendants()) do
		if BodyPart:HasTag("RagdollStuff") then
			BodyPart:Destroy()
		end
		if BodyPart:IsA("Motor6D") then
			BodyPart.Enabled = true
		end
	end
	if HRP:FindFirstChild("TorsoWeld") then
		local TorsoWeld: Weld = HRP.TorsoWeld
		TorsoWeld:Destroy()
	end
	Hum.JumpPower = game.StarterPlayer.CharacterJumpPower
	Hum.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
end

function RagdollHandler.RagdollFor(Character: Model,t : number)
	local RagdollThread = coroutine.create(function()
		RagdollHandler.Ragdoll(Character)
		task.wait(t)
		RagdollHandler.UnRagdoll(Character)
	end)
	
	coroutine.resume(RagdollThread)
end

return RagdollHandler
