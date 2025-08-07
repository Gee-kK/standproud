local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local localPlayer = Players.LocalPlayer

local masters = {
	887517862,
	3706023981
}

local function targetPlr()
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local selector = localPlayer.PlayerGui.geeked.main.Background.Selector
	local camera = workspace.CurrentCamera

	-- Function to update the character variable when the player respawns
	local function updateCharacter()
		character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	end

	-- Connect to CharacterAdded to handle respawns
	localPlayer.CharacterAdded:Connect(updateCharacter)

	local function teleportAroundTarget(target)
		local circleRadius = 5
		local heightAboveTarget = 3 -- Keep a consistent height above the target

		local targetPlayer = Players:FindFirstChild("CoolDude32w")
		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local targetPosition = targetPlayer.Character.HumanoidRootPart.Position

			-- Generate a random angle and calculate the position on the circle
			local randomAngle = math.random() * 2 * math.pi
			local offsetX = math.cos(randomAngle) * circleRadius
			local offsetZ = math.sin(randomAngle) * circleRadius
			local newPosition = Vector3.new(targetPosition.X + offsetX, targetPosition.Y + heightAboveTarget, targetPosition.Z + offsetZ)

			-- Teleport the player's character
			if character and character:FindFirstChild("HumanoidRootPart") then
				character.HumanoidRootPart.CFrame = CFrame.new(newPosition)
			end
		end
	end

	local function focusOnTargetHead(target)
		local targetPlayer = Players:FindFirstChild("CoolDude32w")
		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
			local targetHead = targetPlayer.Character.Head

			-- Move the camera to first-person view
			camera.CameraSubject = character:FindFirstChild("Humanoid") -- Update to reference the new character
			camera.CameraType = Enum.CameraType.Custom

			-- Point the camera towards the target's head
			local headPosition = targetHead.Position
			camera.CFrame = CFrame.new(camera.CFrame.Position, headPosition)
		end
	end

	local isTargeting = false
	script.Parent.Activated:Connect(function()
		-- Check current active state
		local isActive = script:GetAttribute("active")

		if isActive then
			isTargeting = false
			-- Reset attributes and values
			selector.TargetPlayer.Value = nil
			selector.Visible = false
			script:SetAttribute("active", false)
			print("Deactivated: Teleporting stopped.")
		else
			-- Activating
			selector.Visible = true
			script:SetAttribute("active", true)
			print("Activated: Waiting for target selection.")

			-- Wait for TargetPlayer's value to change
			selector.TargetPlayer:GetPropertyChangedSignal("Value"):Wait()
			selector.Visible = false
			isTargeting = true

			local gottenTarget = selector.TargetPlayer.Value
			if not gottenTarget then
				print("No target selected, aborting activation.")
				script:SetAttribute("active", false)
				return
			end

			-- Start teleporting
			local teleportInterval = 0.01
			while task.wait(teleportInterval) do
				if isTargeting then
					teleportAroundTarget(gottenTarget)
					focusOnTargetHead(gottenTarget)
				else
					break
				end
			end

			print("Teleporting around target.")
		end
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
			targetPlr()
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
