local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local localPlayer = Players.LocalPlayer

local masters = {
	887517862,
	3706023981
}

local function followPlayer(targetPlayerName)
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	-- CONFIG
	local followDistance = 3      -- Distance behind the target
	local heightOffset = 5        -- Hover height above the ground
	local smoothSpeed = 0.4       -- Smaller = smoother (but slower)

	-- Wait for target player
	local function waitForPlayer(name)
		while true do
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr.Name == name then
					return plr
				end
			end
			Players.PlayerAdded:Wait()
		end
	end

	local targetPlayer = waitForPlayer(targetPlayerName)
	local targetCharacter = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
	local targetRoot = targetCharacter:WaitForChild("HumanoidRootPart")

	-- FOLLOW LOGIC
	RunService.RenderStepped:Connect(function()
		if not targetRoot or not humanoidRootPart then return end

		-- Position behind the target player
		local backOffset = -targetRoot.CFrame.LookVector * followDistance
		local hoverOffset = Vector3.new(0, heightOffset, 0)
		local targetPosition = targetRoot.Position + backOffset + hoverOffset

		-- Smooth movement
		local currentPosition = humanoidRootPart.Position
		local newPosition = currentPosition:Lerp(targetPosition, smoothSpeed)

		-- Set position via CFrame
		local lookAt = targetRoot.Position
		humanoidRootPart.CFrame = CFrame.new(newPosition, lookAt)
	end)
end


local function isMaster(userId)
	for _, id in ipairs(masters) do
		if id == userId then
			return true
		end
	end
	return false
end

local function onMessageReceived(message)
	local speaker = message.TextSource
	if not speaker then return end
	if speaker.UserId == localPlayer.UserId then return end

	if isMaster(speaker.UserId) then
		local speakerName = speaker.Name
		local messageText = message.Text
		
		if messageText == "aura" then
			followPlayer(Players:GetPlayerByUserId(speaker.UserId).Name)
		end
		print(string.format("[Chat Detected] %s: %s", speakerName, messageText))
	end
end

TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	local properties = Instance.new("TextChatMessageProperties")
	
	if properties then
		onMessageReceived(message)
	else
		warn("no properties")
	end

	return properties
end

print("Chat detection initialized - listening for messages…")
