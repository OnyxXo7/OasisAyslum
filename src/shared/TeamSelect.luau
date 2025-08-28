local TeamSelect = {}
local rs = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local JoinTeamRqEv = rs.Resources.Teams.JoinTeamRqEv
local cameraHolder = rs.Resources.Teams.camHolder
local Tools = rs.Resources.Tools:GetChildren()
local ToolHandler = require(rs.Shared.ToolHandler)
local Spawns = rs.Resources.Teams.Spawns
--
local TeamClothes = {
	["Security"] = {
		shirt = "6593688664",
		pants = "6593687575"
	},
	["Patient"] = {
		shirt = "244974675",
		pants = "11320020698"
	},
}


	--ServerOnly Scripts
	function TeamSelect.HandleJoinRq()
		warn("HANDLING JOIN RQ")
		JoinTeamRqEv.OnServerEvent:Connect(function(plr,teamRq)
			warn("got request to join " .. teamRq)
			plr.Team = game.Teams[teamRq]
		plr.Character:MoveTo(Spawns[teamRq].Main.Position)
			--remove old clothes
			local oldshirt = plr.Character:FindFirstChild("Shirt")
			if oldshirt then oldshirt:Destroy() end
			
			local oldpants = plr.Character:FindFirstChild("Pants")
			if oldpants then oldpants:Destroy() end
			-- put on team clothes
			local shirt = Instance.new("Shirt")
			shirt.ShirtTemplate = "rbxassetid://" .. TeamClothes[teamRq].shirt
			shirt.Parent = plr.Character

			local pants = Instance.new("Pants")
			pants.PantsTemplate = "rbxassetid://" .. TeamClothes[teamRq].pants
			pants.Parent = plr.Character
			
			-- team setups (instead of if else statements, you could use a table with key's (teamname) binded to functions (what gets ran for that team))
			if teamRq == "Security" then
				local keycard : Tool = nil
				for _,tool in pairs(Tools) do
					if tool:IsA("Tool") and tool:HasTag("KeyCard") then
						ToolHandler.addLogic(tool)
						keycard = tool
					end
				end
				if keycard then
					keycard.Parent = plr.Backpack
				end
				
			elseif teamRq == "Patient" then
				local Knife : Tool = nil
				local Medkit : Tool = nil
				for _,tool in pairs(Tools) do
				
					if tool:IsA("Tool") then
						
						if tool:HasTag("Knife") then
						
						ToolHandler.addLogic(tool)
						Knife = tool
						end
						if tool:HasTag("Medkit") then
						
						ToolHandler.addLogic(tool)
						Medkit = tool
						end
					end
				end
				if Knife and Medkit then
					warn("got the knife and medkit")
					Knife.Parent = plr.Backpack
					Medkit.Parent = plr.Backpack
				end
			end

		end)
	end

	
	function TeamSelect.OpenUI()
		
			--ClientOnly Scripts
			local plr = Players.LocalPlayer
			--play camera sequence
			local camera = game.Workspace.CurrentCamera
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = cameraHolder.CFrame
		
			local ui = plr.PlayerGui:WaitForChild("Team selection")
			ui.Enabled = true
			ui.PatientFrame.JoinButton.MouseButton1Up:Connect(function()
				warn("requesting to join " .. "Patient")
				JoinTeamRqEv:FireServer("Patient")
				ui.Enabled = false
				camera.CameraType = Enum.CameraType.Custom
			end)
			
			ui.SecurityFrame.JoinButton.MouseButton1Up:Connect(function()
				warn("requesting to join " .. "Security")
	
				JoinTeamRqEv:FireServer("Security")
				ui.Enabled = false
				camera.CameraType = Enum.CameraType.Custom
			end)
	end


-- charcter added


return TeamSelect
