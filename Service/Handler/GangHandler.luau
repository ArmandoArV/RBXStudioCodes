local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")

local GangHandler = {}
GangHandler.__index = GangHandler

-- ================
-- Dependencies
-- ================
local Gang = require(ReplicatedStorage:WaitForChild("Classes"):WaitForChild("Gang"))
local GroupIds = require(ReplicatedStorage:WaitForChild("GroupIds"))

-- ================
-- Configuration
-- ================
local REMOTE_EVENT_NAME = "GangRemoteEvent"
local DEBUG_PREFIX = "[GangHandler]"

-- Ensure RemoteEvent exists
local remoteEvent = ReplicatedStorage:FindFirstChild(REMOTE_EVENT_NAME)
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = REMOTE_EVENT_NAME
	remoteEvent.Parent = ReplicatedStorage
end

-- ================
-- Utility Functions
-- ================
local function debugLog(...)
	print(DEBUG_PREFIX, ...)
end

local function getReservedColors()
	local reserved = {}
	for _, group in pairs(GroupIds) do
		for _, entry in pairs(group) do
			if entry.TEAM then
				reserved[entry.TEAM] = true
			end
		end
	end
	return reserved
end

local function updateGangInfoInStorage(gang)
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
	else
		gangInstance:ClearAllChildren()
	end

	-- Leader
	local leaderValue = Instance.new("ObjectValue")
	leaderValue.Name = "Leader"
	leaderValue.Value = gangInfo.Leader
	leaderValue.Parent = gangInstance

	-- Members
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

local function validateGangName(name)
	if type(name) ~= "string" or #name < 2 then
		return false, "Gang name must be at least 2 characters"
	end
	if Teams:FindFirstChild(name) then
		return false, "Gang name already exists"
	end
	return true
end

local function validateColor(colorTable)
	if typeof(colorTable) ~= "table" then
		return false, "Invalid color data"
	end
	local r, g, b = colorTable.r, colorTable.g, colorTable.b
	if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
		return false, "Invalid color components"
	end
	return true, Color3.new(r, g, b)
end

-- ================
-- GangHandler API
-- ================
function GangHandler.new()
	local self = setmetatable({}, GangHandler)
	self._remoteEvent = remoteEvent
	self._reservedColors = getReservedColors()
	self._gangs = {} -- In-memory cache of gang objects
	return self
end

-- Utility function to get or create CIUDADANO team
local function getOrCreateCiudadanoTeam()
	local ciudadanoTeam = Teams:FindFirstChild("CIUDADANO")
	if not ciudadanoTeam then
		ciudadanoTeam = Instance.new("Team")
		ciudadanoTeam.Name = "CIUDADANO"
		ciudadanoTeam.TeamColor = BrickColor.new("Gold") -- Brick gold color
		ciudadanoTeam:SetAttribute("IsGang", false) -- Mark as not a gang
		ciudadanoTeam.Parent = Teams
		debugLog("Created CIUDADANO team")
	end
	return ciudadanoTeam
end

function GangHandler:Init()
	debugLog("Initializing RemoteEvent listener")
	self._remoteEvent.OnServerEvent:Connect(function(player, action, data)
		self:HandleRequest(player, action, data)
	end)
	
	-- Ensure CIUDADANO team exists
	getOrCreateCiudadanoTeam()
	
	-- Handle new players joining - assign them to CIUDADANO team
	Players.PlayerAdded:Connect(function(player)
		-- Wait for player to load in
		player.CharacterAdded:Connect(function()
			-- Only assign to CIUDADANO if they're not already in a team
			if not player.Team then
				local ciudadanoTeam = getOrCreateCiudadanoTeam()
				player.Team = ciudadanoTeam
				debugLog("Assigned new player", player.Name, "to CIUDADANO team")
			end
		end)
	end)
end

function GangHandler:HandleRequest(player, action, data)
	debugLog("Handling", action, "request from", player.Name)

	local handler = self["Handle"..action]
	if handler then
		handler(self, player, data)
	else
		debugLog("Unknown action:", action)
		self._remoteEvent:FireClient(player, action.."Failed", "Unknown action")
	end
end

function GangHandler:HandleCreateGang(player, data)
	debugLog("[CreateGang] Incoming data:", data)

	-- Basic validation
	if typeof(data) ~= "table" then
		debugLog("[CreateGang] Invalid data type")
		return self._remoteEvent:FireClient(player, "GangCreateFailed", "Invalid data")
	end

	local name = data.name
	local groupId = data.groupId
	local colorTable = data.color

	-- Validate name
	local nameValid, nameError = validateGangName(name)
	if not nameValid then
		debugLog("[CreateGang] Invalid name:", nameError)
		return self._remoteEvent:FireClient(player, "GangCreateFailed", nameError)
	end

	-- Validate groupId
	if type(groupId) ~= "number" then
		debugLog("[CreateGang] Invalid groupId")
		return self._remoteEvent:FireClient(player, "GangCreateFailed", "Invalid groupId")
	end

	-- Validate color
	local colorValid, colorOrError = validateColor(colorTable)
	if not colorValid then
		debugLog("[CreateGang] Invalid color:", colorOrError)
		return self._remoteEvent:FireClient(player, "GangCreateFailed", colorOrError)
	end

	-- Check for reserved color
	if self._reservedColors[colorOrError] then
		debugLog("[CreateGang] Reserved color")
		return self._remoteEvent:FireClient(player, "GangCreateFailed", "ReservedColor")
	end

	-- Create Roblox Team
	local newTeam = Instance.new("Team")
	newTeam.Name = name
	newTeam.TeamColor = BrickColor.new(colorOrError)
	newTeam:SetAttribute("GroupId", groupId) -- Set GroupId attribute for the team
	newTeam.Parent = Teams
	player.Team = newTeam

	-- Create Gang object
	local gang = Gang.new(player, {})
	gang.Name = name
	gang.Color = colorOrError
	self._gangs[name] = gang -- Cache the gang object

	-- Update storage and notify clients
	updateGangInfoInStorage(gang)
	self._remoteEvent:FireClient(player, "GangCreated", gang:GetInfo())
	self._remoteEvent:FireAllClients("RefreshGangList")

	debugLog("Gang created:", name)
end

function GangHandler:HandleJoinGang(player, data)
	debugLog("[JoinGang] Incoming data:", data)

	if typeof(data) ~= "table" then
		debugLog("[JoinGang] Invalid data")
		return self._remoteEvent:FireClient(player, "GangJoinFailed", "Invalid data")
	end

	local groupId = data.groupId
	local colorTable = data.color
	local groupName = nil
	local targetTeam = nil

	-- Try to find by groupId first
	if type(groupId) == "number" then
		debugLog("[JoinGang] Searching by groupId:", groupId)
		for name, group in pairs(GroupIds) do
			if group.GROUP_ID == groupId then
				groupName = name
				debugLog("[JoinGang] Found matching group:", groupName)
				break
			end
		end

		if groupName then
			targetTeam = Teams:FindFirstChild(groupName)
			if targetTeam then
				debugLog("[JoinGang] Found team by group name")
			end
		end
	end

	-- Fallback to name search
	if not targetTeam and type(data.name) == "string" then
		debugLog("[JoinGang] Fallback to name search:", data.name)
		targetTeam = Teams:FindFirstChild(data.name)
	end

	-- Fallback to color search
	if not targetTeam and colorTable then
		local colorValid, color = validateColor(colorTable)
		if colorValid then
			debugLog("[JoinGang] Searching by color")
			for _, team in pairs(Teams:GetTeams()) do
				if team.TeamColor.Color == color then
					targetTeam = team
					break
				end
			end
		end
	end

	-- Handle no team found
	if not targetTeam then
		local errorMsg = "No matching gang found"
		if groupName then
			errorMsg = "No gang found for group: "..groupName
		elseif data.name then
			errorMsg = "No gang found with name: "..data.name
		end
		debugLog("[JoinGang]", errorMsg)
		return self._remoteEvent:FireClient(player, "GangJoinFailed", errorMsg)
	end

	-- Success case
	player.Team = targetTeam
	local teamColor = targetTeam.TeamColor.Color
	self._remoteEvent:FireClient(player, "GangJoined", {
		name = targetTeam.Name,
		color = {
			r = teamColor.R,
			g = teamColor.G,
			b = teamColor.B
		}
	})
	debugLog(player.Name, "joined gang", targetTeam.Name)
end

function GangHandler:HandleLeaveGang(player, data)
	debugLog("[LeaveGang] Request from", player.Name)

	-- Check if player is currently in a team
	if not player.Team then
		debugLog("[LeaveGang] Player not in any gang")
		return self._remoteEvent:FireClient(player, "GangLeaveFailed", "You are not in any gang")
	end

	local currentTeam = player.Team
	local teamName = currentTeam.Name

	-- Find or create CIUDADANO team with brick gold color
	local ciudadanoTeam = getOrCreateCiudadanoTeam()

	-- Assign player to CIUDADANO team instead of nil
	player.Team = ciudadanoTeam

	-- Update gang storage if this was a custom gang
	if self._gangs[teamName] then
		local gang = self._gangs[teamName]
		local gangInfo = gang:GetInfo()

		-- Remove from members list
		for i, member in ipairs(gangInfo.Members) do
			if member == player then
				table.remove(gangInfo.Members, i)
				break
			end
		end

		-- If this was the leader and there are other members, transfer leadership
		if gangInfo.Leader == player and #gangInfo.Members > 0 then
			gang.Leader = gangInfo.Members[1]
			debugLog("[LeaveGang] Leadership transferred to", gang.Leader.Name)
		elseif gangInfo.Leader == player and #gangInfo.Members == 0 then
			-- If no members left, remove the gang entirely
			currentTeam:Destroy()
			self._gangs[teamName] = nil

			-- Remove from ReplicatedStorage
			local gangFolder = ReplicatedStorage:FindFirstChild("Gangs")
			if gangFolder then
				local gangInstance = gangFolder:FindFirstChild(teamName)
				if gangInstance then
					gangInstance:Destroy()
				end
			end

			debugLog("[LeaveGang] Gang", teamName, "disbanded - no members left")
			self._remoteEvent:FireAllClients("RefreshGangList")
		end

		-- Update storage if gang still exists
		if self._gangs[teamName] then
			updateGangInfoInStorage(gang)
		end
	end

	-- Notify client of successful leave
	self._remoteEvent:FireClient(player, "GangLeft", {
		previousGang = teamName
	})

	debugLog(player.Name, "left gang", teamName)
end

function GangHandler:AddMember(player, member)
	debugLog("AddMember called for", player.Name, "adding", member and member.Name)
	-- Implementation would go here
end

function GangHandler:RemoveMember(player, member)
	debugLog("RemoveMember called for", player.Name, "removing", member and member.Name)
	-- Implementation would go here
end

function GangHandler:SetLeader(player, newLeader)
	debugLog("SetLeader called for", player.Name, "new leader", newLeader and newLeader.Name)
	-- Implementation would go here
end

return GangHandler