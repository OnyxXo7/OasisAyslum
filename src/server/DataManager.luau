local DataManager = {}


DataManager.Profiles = {}
local rs = game:GetService("ReplicatedStorage")
local players = game:GetService("Players"):GetChildren()

-- used for MULTIPLE SESSION data
--for _,player : Player in pairs(players) do
--	print(player.DisplayName .. "'s Data")
--	for key,item in pairs(player.Data) do
		
--	end
--end

function DataManager.addcoin(plr:Player, amount)
	-- get profile + sanity check
	local profile = DataManager.Profiles[plr]
	if not profile then return end
	--update profile
	profile.Data.coin += amount
	--server action
	warn(plr.DisplayName .. " has " .. profile.Data.coin .. " coins ")
	--update client info
	--rs.updClient.Coin:FireClient(plr,profile.Data.coin) 
end


function DataManager.addMinute(plr:Player, amount)
	local profile = DataManager.Profiles[plr]
	if not profile then return end
	profile.Data.minutes += amount
	--fo anything else :P
	warn(plr.DisplayName .. " has been playing for " .. profile.Data.minutes .. " mins!")
	-- notify client of change
	--rs.updClient.Minutes:FireClient(plr,profile.Data.minutes)
end


return DataManager