local MeleeHandler = {}
local rs =game:GetService("ReplicatedStorage")


function  MeleeHandler.HeadRaycast(plr:Player,RANGE : number)
	local char :Model? = plr.Character
	if not char then return end

	local head : Part? = char:FindFirstChild("Head")
	if not head then return end
	local headPos = head.Position
	local direction = head.CFrame.LookVector * RANGE

	local Raycast1 = RaycastParams.new()
	Raycast1.FilterDescendantsInstances = {char}
	Raycast1.FilterType = Enum.RaycastFilterType.Exclude
	local   result = workspace:Raycast(headPos,direction,Raycast1)

	if result then
		local hitpart = result.Instance
		local ParentISModel = hitpart.Parent:IsA("Model")
		local ParentISAcessory = hitpart.Parent:IsA("Accessory")



		local RIG
		if ParentISModel or ParentISAcessory  then
			if ParentISModel then RIG = hitpart.Parent end
			if ParentISAcessory then RIG = hitpart.Parent.Parent end
			
			warn("got model:" .. RIG.Name)
			local hum = RIG:FindFirstChildOfClass("Humanoid")
			if hum then
				if RIG ~= plr.Character then
					return RIG
				else
					warn("]HIT YOURSELF, did nothing")
				end
			
			end

		end



	end

end

--wallbangGlitchChecker
--fire a raycast and return the part the arm is sticking through
return MeleeHandler