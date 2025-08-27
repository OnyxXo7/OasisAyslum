local VentHandler = {}
local runService = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")
local collectionService = game:GetService("CollectionService")
local zoneMod = require(rs.SharedLibs.Zone)

-- Later i want differnt items to able to open the vent,
-- so it will have to run its check somehow on the server after the request

-- ex: throwin a chair at the vent will open it
-- ex: prying the vent with a crowbar
local function OpenVent(Vent:Model,VentDefualtCFrame)
	
	local ventHitbox = Vent.VentHitbox
	local ventPart : Part = Vent.VentPart
	local VFXatt : Attachment = Vent.VentVFX.Att
	local zone = zoneMod.new(ventHitbox)
	local OpenVentRq :RemoteEvent = ventHitbox.OpenVentRq
	local VectorForce :VectorForce = ventPart.VectorForce
	local VENTOPEN : Sound = ventHitbox.VENTOPEN
	warn("ATT CHANGED, VENT OPEN:" .. tostring(Vent:GetAttribute("Open")) )
	if Vent:GetAttribute("Open") == true then
		warn("VENT OPENED")
		VENTOPEN:Play()
		for _,smoke : ParticleEmitter in pairs(VFXatt:GetChildren()) do
			smoke.Enabled = true
		end
		ventPart.Anchored = false 
		ventPart.CanCollide = false
		VectorForce.Enabled = true
		task.wait(0.1) --< allows vent to not collide into you
		ventPart.CanCollide = true		
		VectorForce.Enabled = false
		task.wait(0.3)
		for _,smoke : ParticleEmitter in pairs(VFXatt:GetChildren()) do
			smoke.Enabled = false
		end
		task.wait(3)
		Vent:SetAttribute("Open",false)
	elseif Vent:GetAttribute("Open") == false then
		warn("VENT CLOSED")
		ventPart.CFrame = VentDefualtCFrame
		ventPart.Anchored = true
	end
end


function VentHandler.setup() -- what if the vent a vent doesnt exist when this is called?
	if runService:IsClient() then return end -- the clint cant open vents or create them
	for index,Vent in pairs(collectionService:GetTagged("Vent")) do --manually tag what is considered a vent (or duplicate a vent)
		Vent:SetAttribute("Opening",false)
		Vent:SetAttribute("Open",false)
		local VentDefualtCFrame = Vent.VentPart.CFrame
		
		Vent:GetAttributeChangedSignal("Open"):Connect(function()
			OpenVent(Vent,VentDefualtCFrame)
		end)
	end

	
	--/UNCOMMNET ME IF A VENT IS MISSING "VENTID" ATTRIBUTE
	--collectionService:GetInstanceAddedSignal("Vent"):Connect(function(newVent)
	--	-- You might need a different way to assign IDs (since index above won't apply here)
	--	local id = #collectionService:GetTagged("Vent")
	--	newVent:SetAttribute("Opening",false)
	--	newVent:SetAttribute("Open",false)
	
	-- and connect events
	--end)
end

-- highlight the vent when close to the vent with a screwDriver
function VentHandler.LocalInit() -- VentHandler.LocalConnectEvents() 

end

return VentHandler
