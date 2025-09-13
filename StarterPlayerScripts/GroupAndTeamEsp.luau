local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer


-- GroupIds will be set after receiving from server
local GroupIds = nil
local ALL_GROUP_IDS = nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupIdsEvent = ReplicatedStorage:WaitForChild("GroupIdsEvent")


local function getAllGroupIds()
	local ids = {}
	if not GroupIds then return ids end
	for _, group in pairs(GroupIds) do
		for _, entry in pairs(group) do
			if entry.ID then
				ids[entry.ID] = true
			end
		end
	end
	local count = 0
	for _ in pairs(ids) do count = count + 1 end
	print("[DEBUG] getAllGroupIds: count =", count)
	return ids
end

-- Helper: get all group IDs for a player
local function getPlayerGroups(player)
	local groups = {}
	if not ALL_GROUP_IDS then return groups end
	pcall(function()
		for groupId in pairs(ALL_GROUP_IDS) do
			if player:IsInGroup(groupId) then
				groups[groupId] = true
			end
		end
	end)
	return groups
end

-- Check if two players share a group
local function sameGroup(p1, p2)
	local g1 = getPlayerGroups(p1)
	local g2 = getPlayerGroups(p2)
	for id in pairs(g1) do
		if g2[id] then
			print("[DEBUG] sameGroup:", p1.Name, "and", p2.Name, "share group", id)
			return true
		end
	end
	return false
end

-- Check if two players are on the same team
local function sameTeam(p1, p2)
	return p1.Team == p2.Team and p1.Team ~= nil
end

-- ESP logic
local function addESP(character, teamColor)
	if not character then return end
	if character:FindFirstChild("ESP_Highlight") then return end
	print("[DEBUG] Adding ESP to", character.Name)
	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Highlight"
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 1
	highlight.FillColor = teamColor or Color3.new(0, 1, 0)
	highlight.Parent = character
end

local function removeESP(character)
	if not character then return end
	local highlight = character:FindFirstChild("ESP_Highlight")
	if highlight then
		print("[DEBUG] Removing ESP from", character.Name)
		highlight:Destroy()
	end
end

local function updateAllESP()
	if not ALL_GROUP_IDS then print("[DEBUG] updateAllESP: ALL_GROUP_IDS not set"); return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local isAlly = sameTeam(LocalPlayer, player) or sameGroup(LocalPlayer, player)
			local char = player.Character
			if isAlly and char then
				print("[DEBUG] Ally detected:", player.Name)
				local color = player.Team and player.Team.TeamColor and player.Team.TeamColor.Color or Color3.new(0, 1, 0)
				addESP(char, color)
			else
				removeESP(char)
			end
		end
	end
end


-- Wait for group IDs from server before running ESP logic
GroupIdsEvent.OnClientEvent:Connect(function(receivedGroupIds)
	print("[DEBUG] Received group IDs from server. Count:", receivedGroupIds and #receivedGroupIds or "table")
	GroupIds = receivedGroupIds
	ALL_GROUP_IDS = getAllGroupIds()

	-- Listen for team/group/character changes (now that group IDs are set)
	Players.PlayerAdded:Connect(function(player)
		player:GetPropertyChangedSignal("Team"):Connect(updateAllESP)
		player.CharacterAdded:Connect(function()
			task.wait(1)
			updateAllESP()
		end)
	end)

	LocalPlayer:GetPropertyChangedSignal("Team"):Connect(updateAllESP)

	Players.PlayerRemoving:Connect(function(player)
		if player.Character then removeESP(player.Character) end
	end)

	-- Initial ESP setup
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			player:GetPropertyChangedSignal("Team"):Connect(updateAllESP)
			player.CharacterAdded:Connect(function()
				task.wait(1)
				updateAllESP()
			end)
		end
	end
	updateAllESP()
end)