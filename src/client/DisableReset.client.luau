local StartGui = game:GetService("StarterGui")
local thing = game:GetService("RunService")

repeat
		local disabled = pcall(function()
			StartGui:SetCore("ResetButtonCallback",false)
		end)
		task.wait(1)
until disabled
