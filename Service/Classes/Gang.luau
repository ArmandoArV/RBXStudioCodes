local Gang = {}
Gang.__index = Gang

function Gang.new(name, leader, members)
    local self = setmetatable({}, Gang)
    self.Name = name
    self.Leader = leader
    self.Members = members or {}
    -- Optional: Initialize other properties like groupId
    self.GroupId = nil -- Placeholder for group ID if needed
    if leader then
        self:AddMember(leader) -- Automatically add the leader as a member
    end
    self.Members[leader.UserId] = leader -- Ensure leader is in members
    print("Gang created: " .. self.Name .. " with leader: " .. leader.Name)
    -- Optional: Initialize any other necessary properties
    self.isInWar = false -- Placeholder for war status
    self.warTarget = nil -- Placeholder for war target gang
    
    return self
end

function Gang:AddMember(player)
    if not self.Members[player.UserId] then
        self.Members[player.UserId] = player
        print(player.Name .. " has joined the gang: " .. self.Name)
    else
        warn(player.Name .. " is already a member of the gang: " .. self.Name)
    end
end

function Gang:RemoveMember(player)
    if self.Members[player.UserId] then
        self.Members[player.UserId] = nil
        print(player.Name .. " has left the gang: " .. self.Name)
    else
        warn(player.Name .. " is not a member of the gang: " .. self.Name)
    end
end

function Gang:IsMember(player)
    return self.Members[player.UserId] ~= nil
end

function Gang:SetLeader(player)
    if self.Members[player.UserId] then
        self.Leader = player
        print(player.Name .. " is now the leader of the gang: " .. self.Name)
    else
        warn(player.Name .. " is not a member of the gang: " .. self.Name)
    end
end

function Gang:GetMembers()
    local memberList = {}
    for _, member in pairs(self.Members) do
        table.insert(memberList, member)
    end
    return memberList
end

function Gang:GetInfo()
    return {
        Name = self.Name,
        Leader = self.Leader,
        Members = self:GetMembers(),
        GroupId = self.GroupId
    }
end

return Gang

