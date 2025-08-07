local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local localPlayer = Players.LocalPlayer

local masters = {
	887517862,
	3706023981
}

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
	if not speaker then
		return
	end

	-- Skip if it's from the local player
	if speaker.UserId == localPlayer.UserId then
		return
	end

	-- Only print if the sender IS a master
	if isMaster(speaker.UserId) then
		local speakerName = speaker.Name
		local messageText = message.Text
		print(string.format("[Chat Detected] %s: %s", speakerName, messageText))
	end
end

TextChatService.OnIncomingMessage = function(message)
	local properties = Instance.new("TextChatMessageProperties")
	onMessageReceived(message)
	return properties
end

print("Chat detection initialized - listening for messages...")
