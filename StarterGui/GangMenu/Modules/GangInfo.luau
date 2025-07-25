-- GangInfo.luau
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GangInfo = {}
GangInfo.__index = GangInfo
local GangMenu = script.Parent.Parent
local Background = GangMenu:WaitForChild("GUIs").TeamFrame.Config.Frame:WaitForChild("Gangs")
local Frames = Background
-- Template will be cloned when needed in PopulateUI
local template = nil
local DEBUG_PREFIX = "[GangInfo]"
local GangRemoteEvent = ReplicatedStorage:WaitForChild("GangRemoteEvent")

local function debugPrint(...)
	print(DEBUG_PREFIX, ...)
end

local populateUi

function GangInfo.new(frames, remoteEvent, debugPrint)
	local self = setmetatable({}, GangInfo)

	self.Frames = frames
	self.RemoteEvent = remoteEvent
	self.DebugPrint = debugPrint
	return self
end
-- Helper to get player thumbnail
local function getPlayerThumbnail(userId)
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420
	local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
	return content
end

-- Helper to get player rank from Roblox group
local function getPlayerRank(player, groupId)
	if groupId then
		return player:GetRoleInGroup(groupId)
	end
	return "Member"
end

function GangInfo.GetTeamInfo(team)
	if not team then return nil end
	local groupId = team.GroupId or team:GetAttribute("GroupId")
	local members = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team == team then
			table.insert(members, {
				Username = player.Name,
				UserId = player.UserId,
				Thumbnail = getPlayerThumbnail(player.UserId),
				Rank = getPlayerRank(player, groupId)
			})
		end
	end
	return {
		GangId = groupId or team.TeamId or team.Name, -- Use GroupId if available
		TeamName = team.Name,
		TeamColor = team.TeamColor and team.TeamColor.Name or tostring(team.TeamColor),
		ActivePlayers = #members,
		Members = members
	}
end

function GangInfo.GetTeamInfoByPlayer(player)
	if not player or not player.Team then return nil end
	return GangInfo.GetTeamInfo(player.Team)
end

-- Correctly named method
function GangInfo:PopulateUI()
	local InfoFrame = self.Frames:FindFirstChild("GANG")
	if not InfoFrame then
		warn("[GangInfo] No GANG frame found")
		return
	end
	local PlayerList = InfoFrame:FindFirstChild("Players")
	if not PlayerList then
		warn("[GangInfo] No PlayerList in GANG frame")
		return
	end
	if not PlayerList:IsA("ScrollingFrame") then
		warn("[GangInfo] PlayerList is not a ScrollingFrame! Fix in Studio.")
	end

	-- Find template only when needed
	local pltemplate = PlayerList:FindFirstChild("pltemplate")
	if not pltemplate then
		warn("[GangInfo] pltemplate not found in PlayerList")
		return
	end
	local templateClone = pltemplate:Clone()

	-- Clear old rows
	for _, child in ipairs(PlayerList:GetChildren()) do
		if child:IsA("Frame") and child.Name ~= "pltemplate" then
			child:Destroy()
		end
	end
	local layout = PlayerList:FindFirstChildOfClass("UIListLayout")
	-- ... continue with population logic ...
end

return GangInfo
