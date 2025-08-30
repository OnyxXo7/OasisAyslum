local rs = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local libs = rs:WaitForChild("Shared")
local TeamSelect = require(libs.TeamSelect)
local InputHandler = require(rs.Shared.InputHandler)

--this script handles the local logic
--anything that are comepletely local are here [local interfaces, UI, events awiting server confirm]
-- only interfaces that allow \ REQUESTING \ and events that \ await DISPLAY \ are here

--Player Join

--

local function onCharcterAdded()
	warn("LOCAL char added")
	TeamSelect.OpenUI()
	local plrHu : Humanoid = plr.Character:WaitForChild("Humanoid")
	plrHu.Died:Connect(function() -- for some reason, died Disconnects itself after being called... lame
		warn(plr.DisplayName .. " Died.")

	end)

end


local function LocalInitialize()
	InputHandler.Localinit()

	--/on charcter added local
	if plr.Character then
		onCharcterAdded()
	end
	plr.CharacterAdded:Connect(function()
		onCharcterAdded()
	end)
end




LocalInitialize()