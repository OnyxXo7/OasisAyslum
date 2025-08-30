local InputHandler = {}
local inputService = game:GetService("UserInputService")

local UIS = game:GetService("UserInputService")
local rs = game:GetService("ReplicatedStorage")
--local CAS = game:GetService("ContextActionService")
local inputEv = rs.updServer.InputEv

local function HandleAction(actionName,inputState,inputObject)
	if inputState== Enum.UserInputState.Begin then
		inputEv:FireServer(actionName,true)
	elseif inputState == Enum.UserInputState.End then
		inputEv:FireServer(actionName,false)
	end
end


--action to key, for devs/users to read
local keybinds = {
	UseKEY = {
		Enum.UserInputType.MouseButton1,
		Enum.KeyCode.ButtonR2
	},
	CrouchKEY = {
		Enum.KeyCode.C,
		Enum.KeyCode.ButtonB
	},
	SprintKEY = {
		Enum.KeyCode.LeftAlt,
		Enum.KeyCode.ButtonL3
	},
	ReloadKEY = {
		Enum.KeyCode.R,
		Enum.KeyCode.ButtonX

	}
	
}



--key to action for computer to read
local keyToActionName = {}
for ActionName,keybinds in pairs(keybinds) do
	for _,key in pairs(keybinds) do
		keyToActionName[key] = ActionName
	end
end



local function checkMouse(input : InputObject)

	local inp = keyToActionName[input]
	
	
	if keyToActionName[input.KeyCode] then
		if input.UserInputState  == Enum.UserInputState.Begin then
			inputEv:FireServer(keyToActionName[input.KeyCode], true)
		elseif input.UserInputState  == Enum.UserInputState.End then
			inputEv:FireServer(keyToActionName[input.KeyCode], false)
		end
	end
 
	if keyToActionName[input.UserInputType] then
		
		if input.UserInputState == Enum.UserInputState.Begin then
			inputEv:FireServer(keyToActionName[input.UserInputType], true)
		elseif input.UserInputState == Enum.UserInputState.End then
			inputEv:FireServer(keyToActionName[input.UserInputType], false)
		end
	end
end





--/joystick, mouse, and touchscreen controls are handled EXPLICITLY

--/NOTE: you may need to rate limit how fast players can click any given button (on THIS client modulescirpt) [this is only to avoid SPAMMING remote events to the server]
function InputHandler.Localinit()
	
	UIS.InputBegan:Connect(checkMouse)
	UIS.InputEnded:Connect(checkMouse)
end


return InputHandler
