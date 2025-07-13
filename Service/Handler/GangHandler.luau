local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gang = require(ReplicatedStorage:WaitForChild("Classes"):WaitForChild("Gang"))
local GangHandler = {}
local GangRemoteEvent = "GangRemoteEvent"
-- Ensure the RemoteEvent exists
local remoteEvent = ReplicatedStorage:FindFirstChild(GangRemoteEvent)
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = GangRemoteEvent
	remoteEvent.Parent = ReplicatedStorage
end


local GangHandler = {}

-- Listen for gang creation requests from client
remoteEvent.OnServerEvent:Connect(function(player, action, ...)
	if action == "CreateGang" then
		local groupName, color = ...
		-- Use player's UserId as leader
		local gang, status = GangHandler:CreateGang(groupName, color, player)
		if status == "ReservedColor" then
			remoteEvent:FireClient(player, "GangCreateFailed", "ReservedColor")
		elseif status == "TeamExists" then
			remoteEvent:FireClient(player, "GangCreateFailed", "TeamExists")
		elseif status == "Success" then
			remoteEvent:FireClient(player, "GangCreated", gang:GetInfo())
		else
			remoteEvent:FireClient(player, "GangCreateFailed", "UnknownError")
		end
		return
	end

	-- ...existing code for other actions...
	local gangHandler = require(ReplicatedStorage:WaitForChild("Handler"):WaitForChild("GangHandler"))
	local gang = gangHandler:GetGangByPlayer(player)

	if not gang then
		warn("Player " .. player.Name .. " is not in a gang.")
		return
	end

	if action == "AddMember" then
		local member = ...
		gangHandler:AddMember(gang, member)
	elseif action == "RemoveMember" then
		local member = ...
		gangHandler:RemoveMember(gang, member)
	elseif action == "SetLeader" then
		local newLeader = ...
		gangHandler:SetLeader(gang, newLeader)
	elseif action == "GetInfo" then
		return gangHandler:GetGangInfo(gang)
	end
end)

-- Update the gang info in ReplicatedStorage
local function updateGangInfo(gang)
	local gangFolder = ReplicatedStorage:FindFirstChild("Gangs")
	if not gangFolder then
		gangFolder = Instance.new("Folder")
		gangFolder.Name = "Gangs"
		gangFolder.Parent = ReplicatedStorage
	end

	local gangInfo = gang:GetInfo()
	local gangInstance = gangFolder:FindFirstChild(gangInfo.Name)

	if not gangInstance then
		gangInstance = Instance.new("Folder")
		gangInstance.Name = gangInfo.Name
		gangInstance.Parent = gangFolder
	end

	-- Update leader and members
	local leaderValue = Instance.new("ObjectValue")
	leaderValue.Name = "Leader"
	leaderValue.Value = gangInfo.Leader
	leaderValue.Parent = gangInstance

	local membersFolder = Instance.new("Folder")
	membersFolder.Name = "Members"
	membersFolder.Parent = gangInstance

	for _, member in ipairs(gangInfo.Members) do
		local memberValue = Instance.new("ObjectValue")
		memberValue.Name = member.Name
		memberValue.Value = member
		memberValue.Parent = membersFolder
	end
end

-- Utility to get reserved team colors from GroupIds
local function getReservedColors()
	local reserved = {}
	local groupIDs = require(ReplicatedStorage:WaitForChild("GroupIds"))
	for _, group in pairs(groupIDs) do
		for _, entry in pairs(group) do
			if entry.TEAM then
				reserved[entry.TEAM] = true
			end
		end
	end
	return reserved
end

-- Create a gang/team with group name and color, preventing reserved colors
function GangHandler:CreateGang(groupName, color, leader)
	local reservedColors = getReservedColors()
	if reservedColors[color] then
		warn("Cannot create gang with reserved color: " .. tostring(color))
		return nil, "ReservedColor"
	end

	-- Create Roblox Team
	local Teams = game:GetService("Teams")
	if Teams:FindFirstChild(groupName) then
		warn("Team already exists: " .. groupName)
		return nil, "TeamExists"
	end
	local team = Instance.new("Team")
	team.Name = groupName
	team.TeamColor = BrickColor.new(color)
	team.AutoAssignable = false
	team.Parent = Teams

	-- Retrieve group name using GroupService:GetGroupsAsync
	local groupIdNum = tonumber(groupName)
	local groupNameResult = nil
	if groupIdNum and leader and leader.UserId then
		local success, groups = pcall(function()
			return game:GetService("GroupService"):GetGroupsAsync(leader.UserId)
		end)
		print("[GROUP INFO DEBUG] GetGroupsAsync success:", success)
		print("[GROUP INFO DEBUG] Groups:", groups)
		if success and type(groups) == "table" then
			for _, group in pairs(groups) do
				if group.Id == groupIdNum then
					groupNameResult = group.Name
					print("[GROUP INFO DEBUG] Found group name:", groupNameResult)
					break
				end
			end
		end
	end
	if not groupNameResult then
		print("[GROUP INFO DEBUG] Group name not found for groupId:", groupIdNum)
	end

	-- Create gang object
	local gang = Gang.new(leader, {})
	gang.Name = groupName
	gang.Color = color
	updateGangInfo(gang)
	remoteEvent:FireAllClients("GangCreated", gang:GetInfo())
	return gang, "Success"
end

function GangHandler:AddMember(gang, player)
	if gang:IsMember(player) then
		warn(player.Name .. " is already a member of the gang: " .. gang.Name)
		return false
	end
	gang:AddMember(player)
	updateGangInfo(gang)
	remoteEvent:FireAllClients("MemberAdded", gang:GetInfo(), player.UserId)
	return true
end

function GangHandler:RemoveMember(gang, player)
	if not gang:IsMember(player) then
		warn(player.Name .. " is not a member of the gang: " .. gang.Name)
		return false
	end
	gang:RemoveMember(player)
	updateGangInfo(gang)
	remoteEvent:FireAllClients("MemberRemoved", gang:GetInfo(), player.UserId)
	return true
end

function GangHandler:SetLeader(gang, player)
	if not gang:IsMember(player) then
		warn(player.Name .. " is not a member of the gang: " .. gang.Name)
		return false
	end
	gang:SetLeader(player)
	updateGangInfo(gang)
	remoteEvent:FireAllClients("LeaderChanged", gang:GetInfo(), player.UserId)
	return true
end

function GangHandler:GetGangInfo(gang)
	return gang:GetInfo()
end

function GangHandler:GetAllGangs()
	local gangs = {}
	local gangFolder = ReplicatedStorage:FindFirstChild("Gangs")
	if gangFolder then
		for _, gang in pairs(gangFolder:GetChildren()) do
			if gang:IsA("Folder") then
				local leader = gang:FindFirstChild("Leader")
				local members = gang:FindFirstChild("Members")
				local memberList = members and members:GetChildren() or {}
				local gangInfo = Gang.new(leader and leader.Value, memberList)
				table.insert(gangs, gangInfo:GetInfo())
			end
		end
	end
	return gangs
end

return GangHandler
