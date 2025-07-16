local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupIds = require(script.Parent.GroupIds)

local remote = ReplicatedStorage:FindFirstChild("GetExcludedGangColors")
if not remote then
	remote = Instance.new("RemoteFunction")
	remote.Name = "GetExcludedGangColors"
	remote.Parent = ReplicatedStorage
end

remote.OnServerInvoke = function()
	local excluded = {}
	for _, group in pairs(GroupIds) do
		for _, entry in pairs(group) do
			if entry.TEAM then
				table.insert(excluded, entry.TEAM)
			end
		end
	end
	return excluded
end