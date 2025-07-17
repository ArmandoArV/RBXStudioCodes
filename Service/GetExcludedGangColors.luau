local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupIds = require(script.Parent.GroupIds)

local remote = Instance.new("RemoteFunction")
remote.Name = "GetExcludedGangColors"
remote.Parent = ReplicatedStorage

remote.OnServerInvoke = function()
	local excluded = {}

	for _, group in pairs(GroupIds) do
		for _, entry in pairs(group) do
			if entry.TEAM then
				table.insert(excluded, entry.TEAM)
			end
		end
	end

	-- Debug
	print("[GetExcludedGangColors] Sending excluded TEAM colors:")
	for _, c in ipairs(excluded) do
		print("- " .. c)
	end

	return excluded
end
