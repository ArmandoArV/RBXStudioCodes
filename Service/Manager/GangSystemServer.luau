local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local GroupService = game:GetService("GroupService")

-- Initialize RemoteEvent
local GangRemoteEvent = ReplicatedStorage:FindFirstChild("GangRemoteEvent") or Instance.new("RemoteEvent")
GangRemoteEvent.Name = "GangRemoteEvent"
GangRemoteEvent.Parent = ReplicatedStorage

-- Initialize RemoteFunction for group info
local GetGroupName = Instance.new("RemoteFunction")
GetGroupName.Name = "GetGroupName"
GetGroupName.Parent = ReplicatedStorage

-- Debug logging
local function debugLog(message)
	print("[GangSystemServer] " .. message)
end

-- Gang data tracking
local gangData = {
	groupTeamMappings = {},
	teamCreationTimes = {},
	reservedColors = {}
}

-- Function to set GroupId attributes for existing teams that might not have them
local function initializeExistingTeamGroupIds()
	debugLog("Initializing GroupId attributes for existing teams...")

	-- Import GroupIds module to check for registered groups
	local success, GroupIds = pcall(function()
		return require(SSS:WaitForChild("GroupIds"))
	end)

	if not success then
		debugLog("Could not load GroupIds module")
		return
	end

	-- Check all existing teams
	for _, team in ipairs(Teams:GetTeams()) do
		-- Skip if team already has GroupId attribute
		if team:GetAttribute("GroupId") then
			debugLog("Team " .. team.Name .. " already has GroupId: " .. tostring(team:GetAttribute("GroupId")))
		else
			-- Try to find matching group ID from GroupIds module based on team color
			local teamColorName = team.TeamColor.Name
			debugLog("Checking team: " .. team.Name .. " with color: " .. teamColorName)

			for groupName, groupData in pairs(GroupIds) do
				for subGroupName, subGroupData in pairs(groupData) do
					if subGroupData.TEAM == teamColorName and subGroupData.ID then
						team:SetAttribute("GroupId", subGroupData.ID)
						debugLog("Set GroupId " .. subGroupData.ID .. " for team " .. team.Name)
						-- Store in mapping for consistency
						gangData.groupTeamMappings[subGroupData.ID] = team
						break
					end
				end
			end

			-- If no GroupId found, warn about it
			if not team:GetAttribute("GroupId") then
				debugLog("Warning: Could not find GroupId for team " .. team.Name .. " with color " .. teamColorName)
			end
		end
	end
end

-- Utility function to manually set GroupId for a team (useful for debugging/manual setup)
local function setTeamGroupId(teamName, groupId)
	local team = Teams:FindFirstChild(teamName)
	if team then
		team:SetAttribute("GroupId", groupId)
		gangData.groupTeamMappings[groupId] = team
		debugLog("Manually set GroupId " .. groupId .. " for team " .. teamName)
		return true
	else
		debugLog("Team not found: " .. teamName)
		return false
	end
end

-- Expose utility function globally for server console use
_G.setTeamGroupId = setTeamGroupId

-- Get group info from Roblox
GetGroupName.OnServerInvoke = function(player, groupId)
	local success, result = pcall(function()
		return GroupService:GetGroupInfoAsync(groupId).Name
	end)
	return success and result or "Invalid Group ID"
end

-- Validate color
local function isColorReserved(color)
	for _, reserved in pairs(gangData.reservedColors) do
		if reserved == color then
			return true
		end
	end
	return false
end

-- Handle gang creation
local function handleCreateGang(player, data)
	-- Validate input
	if not data or typeof(data) ~= "table" then
		return false, "Invalid data"
	end

	if type(data.name) ~= "string" or #data.name < 2 then
		return false, "Gang name must be at least 2 characters"
	end

	if type(data.groupId) ~= "number" then
		return false, "Invalid group ID"
	end

	if not data.color or typeof(data.color) ~= "table" then
		return false, "Invalid color data"
	end

	local color = Color3.new(data.color.r, data.color.g, data.color.b)
	if isColorReserved(color) then
		return false, "Color is reserved"
	end

	-- Check if team exists
	if Teams:FindFirstChild(data.name) then
		return false, "Gang name already exists"
	end

	-- Create new team
	local newTeam = Instance.new("Team")
	newTeam.Name = data.name
	newTeam.TeamColor = BrickColor.new(color)
	newTeam:SetAttribute("GroupId", data.groupId) -- Set GroupId attribute for the team
	newTeam:SetAttribute("IsGang", "yes")
	newTeam.Parent = Teams
	-- Update player team
	player.Team = newTeam
	player:LoadCharacter()
	
	-- Store mapping
	gangData.groupTeamMappings[data.groupId] = newTeam
	gangData.teamCreationTimes[newTeam] = os.time()

	return true, {
		name = data.name,
		groupId = data.groupId,
		color = {
			r = newTeam.TeamColor.Color.R,
			g = newTeam.TeamColor.Color.G,
			b = newTeam.TeamColor.Color.B
		}
	}
end

-- Handle gang joining
local function handleJoinGang(player, data)
	-- Validate input
	if not data or typeof(data) ~= "table" then
		return false, "Invalid data"
	end

	if not data.groupId or type(data.groupId) ~= "number" then
		return false, "Invalid group ID"
	end

	if not data.groupName or type(data.groupName) ~= "string" then
		return false, "Invalid group name"
	end

	-- Find team by mapping or name
	local targetTeam = gangData.groupTeamMappings[data.groupId] or Teams:FindFirstChild(data.groupName)

	if not targetTeam then
		return false, "No gang found for this group"
	end

	-- Join team
	player.Team = targetTeam

	return true, {
		name = targetTeam.Name,
		groupId = data.groupId
	}
end

-- Main event handler
GangRemoteEvent.OnServerEvent:Connect(function(player, action, data)
	local success, result

	if action == "CreateGang" then
		success, result = handleCreateGang(player, data)
		if success then
			GangRemoteEvent:FireClient(player, "GangCreated", result)
			GangRemoteEvent:FireAllClients("RefreshGangList")
		else
			GangRemoteEvent:FireClient(player, "GangCreateFailed", result)
		end
	elseif action == "JoinGang" then
		success, result = handleJoinGang(player, data)
		if success then
			GangRemoteEvent:FireClient(player, "GangJoined", result)
		else
			GangRemoteEvent:FireClient(player, "GangJoinFailed", result)
		end
	end
end)

-- Initialize reserved colors
local function initializeReservedColors()
	for _, team in ipairs(Teams:GetTeams()) do
		table.insert(gangData.reservedColors, team.TeamColor.Color)
	end
end

initializeReservedColors()
initializeExistingTeamGroupIds()
debugLog("System initialized")

-- Full GetAvailableGangColors with debug logging
local GetAvailableGangColors = Instance.new("RemoteFunction")
GetAvailableGangColors.Name = "GetAvailableGangColors"
GetAvailableGangColors.Parent = ReplicatedStorage

local allGangColors = {
	"Bright red", "Bright blue", "Bright yellow", "Bright green", "Black", "White", "Medium stone grey",
	"Dark stone grey", "Really red", "Really blue", "Really black", "Really white", "Bright orange",
	"Bright violet", "Bright yellowish green", "Bright bluish green", "Bright pink", "Bright purple"
}

local function getReservedColorNames()
	local reserved = {}
	for _, team in ipairs(Teams:GetTeams()) do
		local name = team.Name
		local colorName = team.TeamColor.Name
		reserved[colorName] = true
		print("[ReservedColor] Team:", name, "uses color:", colorName)
	end
	return reserved
end

GetAvailableGangColors.OnServerInvoke = function(player)
	local reserved = getReservedColorNames()
	local available = {}

	for _, colorName in ipairs(allGangColors) do
		if not reserved[colorName] then
			table.insert(available, colorName)
		end
	end

	print("[AvailableColors] Sending to client:")
	for _, color in ipairs(available) do
		print("-", color)
	end

	return available
end
