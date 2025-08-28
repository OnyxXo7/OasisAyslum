local ToolHandler = {}
local rs = game:GetService("ReplicatedStorage")
local collectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local PlayerHandler = require(rs.Shared.PlayerHandler)
local ZoneService = require(rs.SharedLibs.Zone)

local MeleeHandler = require(rs.Shared.MeleeHandler)

local RagdollHandler = require(rs.Shared.RagdollHandler)
local inputEv = rs.ClientLibs.InputHandler.InputEv
function ToolHandler.initChar(plr : Player)
	local ToolLockFolder = Instance.new("Folder")
	ToolLockFolder.Name = "ToolLockFolder"
	ToolLockFolder.Parent = plr.Character
	local tool : Tool = "hello"

end

local function GetToolOwner(Tool : Tool)
	local player : Player
	local Parent = Tool.Parent
	local Grandparent = Tool.Parent.Parent
	if Parent:IsA("Model") then
		player = Players:GetPlayerFromCharacter(Parent)

	elseif Grandparent:IsA("Player") then --< backpack
		player = Grandparent

	elseif Parent.Name == "ToolLockFolder" then
	
		if Grandparent and Grandparent:IsA("Model") then
			player = Players:GetPlayerFromCharacter(Grandparent)
		end
	else
		warn("Didnt Get ToolOwner")
		player = nil
	end
	return player
	--<returns the player who owns the tool
end

--instead of if then for tools: have a table that takes Tool,gets function (setup for that specfic tool) (owner SHOULD NOT BE PASSED, owner should be tracked in its own scope)
-- maybe even a table for equip unequip and use ([Tool:getTag()] = {use=animtrack,equip=animtrack,unequip=animtrack})?


local function TrackOwner(Tool,ActionTable)
	if not Tool:IsA("Tool") then return end
	local ownerInputEv
	local ownerObj = Instance.new("ObjectValue")
	ownerObj.Name = "owner"
	local oldOwnerObj = Instance.new("ObjectValue")
	oldOwnerObj.Name = "oldOwner"
	oldOwnerObj.Parent = Tool
	ownerObj.Parent = Tool
	--/runs every parent changed
	Tool.AncestryChanged:Connect(function() -- TRACKS THE OWNER parent to something NOT NIL first always
	
		oldOwnerObj.Value = ownerObj.Value
		warn("^AncestorChanged")
		ownerObj.Value = GetToolOwner(Tool)

		local oldOwner = oldOwnerObj.Value
		local owner  = ownerObj.Value
		
		warn("^owner:" .. tostring(owner) .. "| oldowner: " .. tostring(oldOwner))
		--if both owner and old owner nil ignore
		
		
		if oldOwner ~= owner then -- owner changing
			warn("^new owner Found")
			if ownerInputEv then
				warn("^disconnecting old owner")
				ownerInputEv:Disconnect()
				ownerInputEv = nil
			end

			if owner then
				warn("^connecting new owner")
				warn("^" ..tostring(inputEv))
				ownerInputEv = inputEv.OnServerEvent:Connect(function(TriggeringPlayer,ActionName,State)
					if TriggeringPlayer ~= owner then return end
					local Action =  ActionTable[ActionName]
					if type(Action) == type(function()end) then
						Action(State)
					end

				end)
			end

		elseif not oldOwner and not owner then
			warn("^no new ToolOwner, Tool now borken :<")
		end
	end)
	
end


local ToolLogic = {
	["Screw Driver"] = function(Tool : Tool)
		--table consisting of actionNames and their functions
		--/get OWNER useing | Tool:GetAttribute("owner")
		
		local ActionTable = {
			["UseKEY"] = function(State)
				if not Tool:GetAttribute("Equipped") then return end
				
				local toolHitbox = Tool.Hitbox
				if State then
					local owner = Tool.owner.Value
					local zone = ZoneService.new(toolHitbox)
					for _,part in pairs(zone:getParts()) do


						--ScrewDriver is in proxmity to vent
						if collectionService:HasTag(part,"NearVent") then
							--local OpenVentRq :RemoteEvent = part.OpenVentRq
							--OpenVentRq:FireServer()
							--^^used when the screw would fire, and the server would verify it, now the screw handles it
							local Vent : Model = part.Parent

							local VentIsOpen = Vent:GetAttribute("Open")
							local VentIsOpening = Vent:GetAttribute("Opening")
							local VentHitbox = part
							local UNSCREW1 :Sound = VentHitbox.UNSCREW1
							local UNSCREW2 :Sound = VentHitbox.UNSCREW2

							local OpeningVent = Vent.OpeningVent


							local Humanoid :Humanoid = owner.Character:FindFirstChild("Humanoid")
							local WALKSPEED = Humanoid.WalkSpeed
							local JUMPHEIGHT =  Humanoid.JumpHeight

							local UseScrewDriver :AnimationTrack = PlayerHandler.getTrack(owner,"UseScrewDriver")
							local ScrewDriverIdle :AnimationTrack = PlayerHandler.getTrack(owner,"ScrewDriverIdle")
							if VentIsOpen == false and VentIsOpening == false then
								Vent:SetAttribute("Opening",true)
								warn(Humanoid)
								Humanoid.WalkSpeed = 0
								Humanoid.JumpHeight = 0
								ScrewDriverIdle:Stop()
								UseScrewDriver:Play()
								UNSCREW1:Play()
								task.wait(UNSCREW1.TimeLength)
								UNSCREW2:Play()
								task.wait(UNSCREW2.TimeLength)

								UseScrewDriver:Stop()
								ScrewDriverIdle:Play()
								task.wait(0.2) --< small delay after using vent before moving
								Humanoid.WalkSpeed = WALKSPEED
								Humanoid.JumpHeight = JUMPHEIGHT

								Vent:SetAttribute("Open",true)
								Vent:SetAttribute("Opening",false)


							end







						end
					end
				else
	
				end
			end
		}
		--//TRACK OWNER //
		TrackOwner(Tool,ActionTable)
		--//^^TRACK OWNER^^//
		
		

		Tool.Equipped:Connect(function()
			Tool:SetAttribute("Equipped",true)
			local owner = Tool.owner.Value
			warn(Tool.Name .. "------------EQUIIPPED")
			warn("owner is " .. tostring(owner))
			if owner then
				warn(Tool.Name .. "------------FOUND OWNER")
				local ScrewDriverIdle : AnimationTrack = PlayerHandler.getTrack(owner,"ScrewDriverIdle")
				ScrewDriverIdle:Play()
			end
		end)
		Tool.Unequipped:Connect(function()
			
			Tool:SetAttribute("Equipped",false)
			local owner = Tool.owner.Value
			if owner then
				local ScrewDriverIdle : AnimationTrack = PlayerHandler.getTrack(owner,"ScrewDriverIdle")
				ScrewDriverIdle:Stop()
			end
		end)

	end,
	["KeyCard"] = function(Tool :Tool)
		
		local ActionTable = {
			["UseKEY"] = function(State)
				if not Tool:GetAttribute("Equipped") then return end
					local owner = Tool.owner.Value
					local Handle = Tool:WaitForChild("Handle")
					if State then
						warn("^USING TOOL!") -- =====the function wrapping this needs to be streamlined
						--use screwDriver
						
						local toolHitbox = ZoneService.new(Handle)

					--if cooldown is false OR cooldown doesnt exist
					if Tool:GetAttribute("UseCooldown") == nil or Tool:GetAttribute("UseCooldown") == false then
							


							--Play use keycard anim
							--play use keycard sound
							for _,part in pairs(toolHitbox:getParts()) do

								--ScrewDriver is in proxmity to KeyReader
								if collectionService:HasTag(part,"KeyReaderHitbox") then
									warn("in hitbox")
									if owner then
										local UseKeycardAnim : AnimationTrack
										UseKeycardAnim = PlayerHandler.getTrack(owner,"UseKeycard")
										UseKeycardAnim:Play()
									end
									Handle.fart:Play()
									Tool:SetAttribute("UseCooldown",true)
									local KeyReaderHitbox : Part = part
									warn(KeyReaderHitbox:GetChildren())
									local keycardLevel = Tool.level.Value
									local keyReaderLevel = KeyReaderHitbox.level.Value

									if keycardLevel >= keyReaderLevel then
										KeyReaderHitbox.Clearance.Value = true
									end

								end

							end

							--task.wait(UseKeycardAnim.Length) --should be length of anim 
							--Tool:SetAttribute("UseCooldown",false)
						end
					else
						--lift key logic
					end
				
					
			end
		}
		TrackOwner(Tool,ActionTable)
	
	
		--changeUseCooldown to a atribute
		--cooldownlogic
		Tool.AttributeChanged:Connect(function(attribute: string) 
			if attribute == "UseCooldown" and Tool:GetAttribute("UseCooldown") == true then
				task.wait(1)
				Tool:SetAttribute("UseCooldown",false)
			end
		end)
		
		--equip/unequip logic
		Tool.Equipped:Connect(function()
			Tool:SetAttribute("Equipped",true)
			local owner = Tool.owner.Value
			if owner then
				local IdleKeycardAnim : AnimationTrack = PlayerHandler.getTrack(owner,"IdleKeycard")
				IdleKeycardAnim:Play()
			end


			--play idle anim
		end)
		Tool.Unequipped:Connect(function()
			Tool:SetAttribute("Equipped",false)
			local owner = Tool.owner.Value
			if owner then
				local IdleKeycardAnim : AnimationTrack = PlayerHandler.getTrack(owner,"IdleKeycard")
				IdleKeycardAnim:Stop()
			end
			--stop idle anim
		end)

		
	end,
	["Knife"] = function(Tool: Tool)
		local Handle = Tool:WaitForChild("Handle")
		
		local HeavyChargingCoroutine
		local ShankCoroutine
		local function cleanHeavyChargingCoroutine(owner)
			if HeavyChargingCoroutine then
				local KnifeHeavyStab = PlayerHandler.getTrack(owner,"KnifeHeavyStab")
				coroutine.close(HeavyChargingCoroutine)
				HeavyChargingCoroutine = nil

				KnifeHeavyStab:Stop()
			end
		end
		local function cleanShankCoroutine()
			if ShankCoroutine then
				coroutine.close(ShankCoroutine) 
				ShankCoroutine = nil
			end
		end
	
		local ActionTable = {
			["UseKEY"] = function(State) --FIRED ON INPUT EVENT
				if not Tool:GetAttribute("Equipped") then return end


				local owner : Player = Tool.owner.Value -- required to obj bec its a player
				local CHARGETIME = 3
				local KnifeStab = PlayerHandler.getTrack(owner,"KnifeStab")
				local KnifeHeavyStab = PlayerHandler.getTrack(owner,"KnifeHeavyStab")
				if State then
					
					if not ShankCoroutine and not Tool:GetAttribute("Cooldown") then
						
						ShankCoroutine = coroutine.create(function()
							task.wait(0.15)
							
							if not HeavyChargingCoroutine then
								HeavyChargingCoroutine = coroutine.create(function()
									--in charge pos
									
									KnifeHeavyStab:Play()
									task.wait(0.2) --??
									KnifeHeavyStab:AdjustSpeed(0)
									Tool:SetAttribute("HeavyCharged",true)
									
									HeavyChargingCoroutine = nil
									return
								end)
								coroutine.resume(HeavyChargingCoroutine)
								
							end
							--start playing chargeing anim, on charged, let go to swing, (unequipping or letting go early cancels)
							ShankCoroutine = nil
							return
						end)
						coroutine.resume(ShankCoroutine)
					end
				else
					
					if ShankCoroutine then
						cleanShankCoroutine() --before HeavyCharging
						-- shank
						KnifeStab:Play()
						Tool.SwingTrail.Enabled = true
						task.wait(KnifeStab.Length/2)
						Tool.SwingTrail.Enabled = false
						local hitRig = MeleeHandler.HeadRaycast(owner,8)
						Handle.KnifeShing:Play()
						
						if hitRig then
							local hum = hitRig:FindFirstChildOfClass("Humanoid")
							local stunchance = math.random(1,5)
							if stunchance == 5 then --might be good to track if the player is stunned
								RagdollHandler.RagdollFor(hitRig,2)

							end

							Handle.Stab:Play()

							hum:TakeDamage(10)
						end
						
						
					elseif HeavyChargingCoroutine then
						
						cleanHeavyChargingCoroutine(owner)
					elseif Tool:GetAttribute("HeavyCharged") then
						
						Tool:SetAttribute("HeavyCharged",false)
						--heavyattack
						Tool.SwingTrail.Enabled = true
						Tool.Handle.whoosh:Play()
						KnifeHeavyStab:AdjustSpeed(1)
						local hitRig = MeleeHandler.HeadRaycast(owner,8)
						
						Tool:SetAttribute("Cooldown",true)
						
						if hitRig then
							local hum = hitRig:FindFirstChildOfClass("Humanoid")
							local stunchance = math.random(1,5)
							if stunchance == 5 then --might be good to track if the player is stunned
								RagdollHandler.RagdollFor(hitRig,2)

							end

							Handle.HeavyStab:Play() -- for stab too
							
							
							hum:TakeDamage(40)
						end
						warn("*".. tostring(Tool:GetAttribute("Cooldown")))
						task.wait(KnifeHeavyStab.Length - 0.2 - 0.58)
						Tool:SetAttribute("Cooldown",false)
						task.wait(1) -- wait to disable trail
						Tool.SwingTrail.Enabled = false

						
					end

				
					
					
				end
			end
		}
		TrackOwner(Tool,ActionTable)
		
	
		
		
		--//i explcitly get ownervalue here, because these events dont happen on input event
		Tool.Equipped:Connect(function()
			
			
			local owner = Tool.owner.Value 
			if owner then
				local equip = PlayerHandler.getTrack(owner,"KnifeEquip")
				local idle = PlayerHandler.getTrack(owner,"KnifeIdle")
				Handle.KnifeEquip:Play()
				equip:Play()
				Tool.SwingTrail.Enabled = true
				task.wait(equip.Length)
				idle:Play()
				Tool:SetAttribute("Equipped",true)
				Tool.SwingTrail.Enabled = false
			end
		end)
		
		Tool.Unequipped:Connect(function()
			Tool:SetAttribute("Equipped",false)
			Tool.SwingTrail.Enabled = false
			local owner = Tool.owner.Value
			if owner then
				local equip = PlayerHandler.getTrack(owner,"KnifeEquip")
				local idle = PlayerHandler.getTrack(owner,"KnifeIdle")
				equip:Stop()
				idle:Stop()
				
			end
			if ShankCoroutine then
				coroutine.close(ShankCoroutine)
				ShankCoroutine = nil
			end
			cleanShankCoroutine()
			cleanHeavyChargingCoroutine(owner)
		end)
		--/may change to backpack
	

	end,
	["Tazer"] = function(Tool: Tool)
		local TazerHandle =  Tool.Handle
		local DefaultBarrelCFrame  = TazerHandle.DefualtBarrelCFrame
		local projectile = TazerHandle.projectile
		local TazeBeam = TazerHandle.TazeBeam
		local ReloadCoroutine = nil
		
		TazeBeam.Attachment0 = DefaultBarrelCFrame
		local ActionTable = {
			["UseKEY"] = function(State) --/Fire Tazer
				--FIRED ON INPUT EVENT
				if not Tool:GetAttribute("Equipped") then return end
				local owner = Tool.owner.Value
				local TazerFire = PlayerHandler.getTrack(owner,"TazerFire")
				local TazerFireSFX = Tool.Handle.TazeFire
				local TazeSFX = Tool.Handle.Taze
				if State and Tool:GetAttribute("Loaded") then
					TazerFireSFX:Play()
					TazerFire:Play()
					local speed = 5
					local Debris = game:GetService("Debris")
					local CLONEprojectile : Part =  projectile:Clone()
					CLONEprojectile.Parent = game.Workspace
					TazeBeam.Attachment1 = CLONEprojectile.Att
					
					task.wait(0.05) --wait for clone and teleport
					CLONEprojectile.CFrame = DefaultBarrelCFrame.WorldCFrame
					CLONEprojectile:ApplyImpulse(CLONEprojectile.CFrame.LookVector * speed)
					CLONEprojectile.Touched:Connect(function(touched)
						warn("`".. touched.Name)
						if touched.Parent:IsA("Model") and touched.Parent:FindFirstChildOfClass("Humanoid") then
							warn("`HIT A RIG:" .. tostring(touched.Parent))
							if touched.Parent == owner.Character then return end
							RagdollHandler.Ragdoll(touched.Parent)
							CLONEprojectile.Anchored = true
							task.wait(0.2)
							TazeSFX:Play()
							task.wait(1.5)
							TazeSFX:Stop()
						end
					end)
					warn("Speed: " .. speed)
					warn(CLONEprojectile.CFrame.LookVector * speed)
					Debris:AddItem(CLONEprojectile,1)
					Tool:SetAttribute("Loaded",false)
				else
					
				end
			end,
			["ReloadKEY"] = function(State) --/Reload
				
				if not Tool:GetAttribute("Equipped") then return end
				local owner = Tool.owner.Value
				local TazerReloadSFX = Tool.Handle.Reload
				local TazerReload = PlayerHandler.getTrack(owner,"TazerReload")
				if State and not Tool:GetAttribute("Loaded") and not ReloadCoroutine then
					ReloadCoroutine = coroutine.create(function() 
						TazerReload:Play()
						TazerReloadSFX:Play()
						task.wait(TazerReload.Length)
						Tool:SetAttribute("Loaded",true)
						ReloadCoroutine = nil
						return
					end)
					coroutine.resume(ReloadCoroutine)
					--need to use a corutine to watch if close if unequipped, and not run if corutine exists
					--this prevents it to getting to loaded without completeing the anim, and running twice
				else

				end
			end
			
		}
		TrackOwner(Tool,ActionTable)
		
		Tool.Equipped:Connect(function()
			Tool:SetAttribute("Equipped",true)
			local owner = Tool.owner.Value 
			
			if owner then
				local TazerEquip : AnimationTrack = PlayerHandler.getTrack(owner,"TazerEquip")
				local TazerIdle : AnimationTrack = PlayerHandler.getTrack(owner,"TazerIdle")
				TazerEquip:Play()
				task.wait(TazerEquip.Length)
				TazerIdle:Play()
				--idleanim
			end
		end)

		Tool.Unequipped:Connect(function()
			Tool:SetAttribute("Equipped",false)
			local owner = Tool.owner.Value
			
			if owner then
				local TazerReload = PlayerHandler.getTrack(owner,"TazerReload")
				local TazerIdle : AnimationTrack = PlayerHandler.getTrack(owner,"TazerIdle")
				TazerIdle:Stop()
				
				if ReloadCoroutine then
					TazerReload:Stop()
					coroutine.close(ReloadCoroutine)
					ReloadCoroutine = nil
				end
				--stop tazer idle
				
			end
		end)

		
		
		
		
	end,
	["Medkit"] = function(Tool: Tool)
		local ActionTable = {
			["UseKEY"] = function(State)
				if not Tool:GetAttribute("Equipped") then return end
				local owner = Tool.owner.Value
				local medkitUse = PlayerHandler.getTrack(owner,"MedkitUse")
				local medkitIdle = PlayerHandler.getTrack(owner,"MedkitIdle")
				if State then
					medkitIdle:Stop()
					medkitUse:Play()
					task.wait(medkitUse.Length)
					medkitIdle:Play()
				else

				end
				
			end

		}
		TrackOwner(Tool,ActionTable)
		
		Tool.Equipped:Connect(function()
			Tool:SetAttribute("Equipped",true)
			local owner = Tool.owner.Value 
			local medkitIdle = PlayerHandler.getTrack(owner,"MedkitIdle")
			if owner then
				medkitIdle:Play()
			end
		end)

		Tool.Unequipped:Connect(function()
			Tool:SetAttribute("Equipped",false)
			local owner = Tool.owner.Value
			local medkitIdle = PlayerHandler.getTrack(owner,"MedkitIdle")
			local medkitUse = PlayerHandler.getTrack(owner,"MedkitUse")
			if owner then
				medkitIdle:Stop()
				medkitUse:Stop()
			end
		end)
	end,
	["BloxyCola"] = function(Tool: Tool)
		local ActionTable = {
			["UseKEY"] = function(State)
				if not Tool:GetAttribute("Equipped") then return end
				local owner = Tool.owner.Value
				local BloxyColaUse = PlayerHandler.getTrack(owner,"BloxyColaUse")
				local BloxyColaIdle = PlayerHandler.getTrack(owner,"BloxyColaIdle")
				if State then
					BloxyColaIdle:stop()
					BloxyColaUse:Play()
					task.wait(BloxyColaUse.Length)
					BloxyColaIdle:Play()
				end
			end

		}
		TrackOwner(Tool,ActionTable)
		
		Tool.Equipped:Connect(function()
			Tool:SetAttribute("Equipped",true)
			local owner = Tool.owner.Value 
			local BloxyColaEquip1 = PlayerHandler.getTrack(owner,"BloxyColaEquip1")
			local BloxyColaEquip2 = PlayerHandler.getTrack(owner,"BloxyColaEquip2")
			local BloxyColaIdle = PlayerHandler.getTrack(owner,"BloxyColaIdle")
			if owner then
				if not Tool:GetAttribute("SodaOpened") then
					Tool:SetAttribute("SodaOpened",true)
					BloxyColaEquip1:Play()
					task.wait(BloxyColaEquip1.Length)
					BloxyColaIdle:Play()
				else
					BloxyColaEquip2:Play()
					task.wait(BloxyColaEquip2.Length)
					BloxyColaIdle:Play()
				end
				
			end
		end)

		Tool.Unequipped:Connect(function()
			Tool:SetAttribute("Equipped",false)
			local owner = Tool.owner.Value
			local BloxyColaUse = PlayerHandler.getTrack(owner,"BloxyColaUse")
			local BloxyColaEquip1 = PlayerHandler.getTrack(owner,"BloxyColaEquip1")
			local BloxyColaEquip2 = PlayerHandler.getTrack(owner,"BloxyColaEquip2")
			local BloxyColaIdle = PlayerHandler.getTrack(owner,"BloxyColaIdle")
			if owner then
				BloxyColaIdle:Stop()
				BloxyColaUse:Stop()
				BloxyColaEquip1:Stop()
				BloxyColaEquip2:Stop()
			end
		end)
	end
	
}

function ToolHandler.addLogic(Tool : Tool) -- IF I ADD MORE TAGS this a problem
	
	local toolTag = Tool:GetTags()[1]
	ToolLogic[toolTag](Tool)
end







return ToolHandler