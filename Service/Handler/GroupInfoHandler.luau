local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupService = game:GetService("GroupService") -- Add this line

-- Create RemoteFunction for group info
local remoteFunction = ReplicatedStorage:FindFirstChild("GetGroupName")
if not remoteFunction then
	remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = "GetGroupName"
	remoteFunction.Parent = ReplicatedStorage
end

-- Server-side handler for group name requests
remoteFunction.OnServerInvoke = function(player, groupId)
	local groupIdNum = tonumber(groupId)
	if not groupIdNum then
		print("[SERVER DEBUG] Invalid Group ID received:", groupId)
		return "Invalid Group ID"
	end
	local success, info = pcall(function()
		return GroupService:GetGroupInfoAsync(groupIdNum) -- Changed from Players to GroupService
	end)
	print("[SERVER DEBUG] GetGroupInfoAsync result:", success, info)
	if success and type(info) == "table" and info.Name and info.Name ~= "" then
		print("[SERVER DEBUG] Returning group name:", info.Name)
		return tostring(info.Name)
	else
		print("[SERVER DEBUG] Group name not found for groupId:", groupIdNum)
		return "Group Name Not Found"
	end
end

return {} -- No public API needed