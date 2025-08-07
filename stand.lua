local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local localPlayer = Players.LocalPlayer

-- List of master UserIds
local masters = {
	887517862,
	3706023981
}

-- Check if a player is a master
local function isMaster(userId)
	for _, id in ipairs(masters) do
		if id == userId then
			return true
		end
	end
	return false
end

-- Command functions
local commands = {}

-- Example: Teleport to another player
commands["tp"] = function(speaker, args)
	if #args < 1 then
		print("Usage: !tp <playerName>")
		return
	end
	local targetName = args[1]
	local target = Players:FindFirstChild(targetName)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		localPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position)
		print("Teleported to " .. targetName)
	else
		print("Player not found.")
	end
end

-- Example: Say something
commands["say"] = function(speaker, args)
	local message = table.concat(args, " ")
	if message ~= "" then
		game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
		print("Said: " .. message)
	end
end

-- Example: Print all players
commands["players"] = function(speaker, args)
	print("Players in game:")
	for _, plr in ipairs(Players:GetPlayers()) do
		print("- " .. plr.Name)
	end
end

-- Process chat messages
local function onMessageReceived(message)
	local speaker = message.TextSource
	if speaker then
		local userId = speaker.UserId

		if isMaster(userId) then
			local messageText = message.Text
			if messageText:sub(1, 1) == "." then
				local parts = string.split(messageText:sub(2), " ")
				local cmdName = parts[1]:lower()
				table.remove(parts, 1)
				if commands[cmdName] then
					commands[cmdName](speaker, parts)
				else
					print("Unknown command: " .. cmdName)
				end
				return
			end
		end

		if userId ~= localPlayer.UserId then
			print(string.format("[Chat Detected] %s: %s", speaker.Name, message.Text))
		end
	end
end


TextChatService.OnIncomingMessage = function(message)
	local properties = Instance.new("TextChatMessageProperties")
	onMessageReceived(message)
	return properties
end

print("Chat detection & command system initialized.")
