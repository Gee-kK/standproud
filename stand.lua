local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local localPlayer = Players.LocalPlayer

local masters = {
	887517862,
	3706023981,
	731698,
	-1
}

-- STATE
local currentConnection
local currentAction -- "aura" or "fling" or nil

-- Utility: partial name matching
local function findPlayerByPartialName(partialName)
	partialName = partialName:lower()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Name:lower():sub(1, #partialName) == partialName then
			return plr
		end
	end
end

-- Stop any current action
local function stopCurrentAction()
	if currentConnection then
		currentConnection:Disconnect()
		currentConnection = nil
	end
	currentAction = nil
	if localPlayer.Character.Humanoid then
		localPlayer.Character.Humanoid.PlatformStand = false
	end
	
end

-- Aura (follow)
local function followPlayer(targetPlayer)
	if not targetPlayer then return end
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")

	local targetCharacter = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
	local targetRoot = targetCharacter:WaitForChild("HumanoidRootPart")

	local followDistance = 4
	local heightOffset = 4
	local smoothSpeed = 0.5

	stopCurrentAction()
	currentAction = "aura"

	currentConnection = RunService.RenderStepped:Connect(function()
		if not targetRoot or not hrp then return end

		-- Prevent physics from interfering
		humanoid.PlatformStand = true
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero

		-- Calculate hover position behind target
		local backOffset = -targetRoot.CFrame.LookVector * followDistance
		local hoverOffset = Vector3.new(0, heightOffset, 0)
		local targetPos = targetRoot.Position + backOffset + hoverOffset

		-- Interpolate toward position smoothly
		local newPos = hrp.Position:Lerp(targetPos, smoothSpeed)

		-- Face the same direction as the target
		local lookAt = Vector3.new(targetRoot.Position.X, newPos.Y, targetRoot.Position.Z)
		hrp.CFrame = CFrame.new(newPos, lookAt)
	end)
end



-- Fling
local function flingPlayer(targetPlayer)
	print("fling")

	-- Validation
	if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	local myChar = localPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

	local myHRP = myChar.HumanoidRootPart
	local targetHRP = targetPlayer.Character.HumanoidRootPart

	-- Make only HRP collide
	for _, part in ipairs(myChar:GetChildren()) do
		if part:IsA("BasePart") and part ~= myHRP then
			part.CanCollide = false
			part.Massless = true
			part.Velocity = Vector3.zero
		end
	end

	-- Spin tool
	local bav = Instance.new("BodyAngularVelocity")
	bav.Name = "FlingSpin"
	bav.AngularVelocity = Vector3.new(0, 999999, 0)
	bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bav.P = math.huge
	bav.Parent = myHRP

	-- Stay inside target for some time
	local flingTime = 4 -- adjust
	local start = tick()
	while tick() - start < flingTime do
		myHRP.CFrame = targetHRP.CFrame
		task.wait()
	end

	-- Cleanup
	bav:Destroy()
end


-- Permissions
local function isMaster(userId)
	for _, id in ipairs(masters) do
		if id == userId then
			return true
		end
	end
	return false
end

-- Handle messages
local function onMessageReceived(message)
	local speaker = message.TextSource
	if not speaker then return end
	if speaker.UserId == localPlayer.UserId then return end
	if not isMaster(speaker.UserId) then return end
	
	print("received message")
	
	local text = message.Text
	local args = string.split(text, " ")
	local cmd = args[1]:lower()
	local arg1 = args[2] and table.concat(args, " ", 2) or nil -- supports spaces in names
	
	if cmd == "aura" then
		print("said aura")
		local target
		if arg1 then
			target = findPlayerByPartialName(arg1)
		else
			target = Players:GetPlayerByUserId(speaker.UserId)
		end
		
		if target then
			followPlayer(target)
		else
			print("no target")
		end
	elseif cmd == "fling" and arg1 then
		local target = findPlayerByPartialName(arg1)
		if target then
			flingPlayer(target)
		end
	elseif cmd == "stop" then
		stopCurrentAction()
	else
		print("no cmd")
	end

	print(string.format("[Command] %s: %s", speaker.Name, text))
end

TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	onMessageReceived(message)
	local properties = Instance.new("TextChatMessageProperties")
	properties.Text = message.Text
	return properties
end

print("Chat detection initialized - aura/fling ready.")
local SVersion = 8
game:GetService("StarterGui"):SetCore("SendNotification",{
	Title = "Chat detection initialized - aura/fling ready.", -- Required
	Text = "Version: ".. SVersion -- Required
})
