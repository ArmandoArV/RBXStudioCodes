-- Server-side code to provide excluded gang colors to clients via RemoteFunction
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
    return excluded
end
