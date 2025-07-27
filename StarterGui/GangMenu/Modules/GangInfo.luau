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
local GroupService = game:GetService("GroupService")
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
	local groupId = team:GetAttribute("GroupId")

	-- If no GroupId attribute is found, try to get it from the team name or other sources
	if not groupId then
		-- Try to extract groupId from ReplicatedStorage gang data if available
		local gangsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Gangs")
		if gangsFolder and gangsFolder:FindFirstChild(team.Name) then
			local gangFolder = gangsFolder:FindFirstChild(team.Name)
			local groupIdValue = gangFolder:FindFirstChild("GroupId")
			if groupIdValue and groupIdValue.Value then
				groupId = groupIdValue.Value
			end
		end
	end

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
		GangSize = #members, -- Add GangSize field that was referenced in PopulateUI
		Members = members
	}
end

function GangInfo.GetTeamInfoByPlayer(player)
	if not player or not player.Team then return nil end
	return GangInfo.GetTeamInfo(player.Team)
end


-- Correctly named method
function GangInfo:PopulateUI(player)
	local InfoFrame = self.Frames:FindFirstChild("MENU").GANG
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
	local templateClone = pltemplate

	-- Clear old rows
	for _, child in ipairs(PlayerList:GetChildren()) do
		if child:IsA("Frame") and child.Name ~= "pltemplate" then
			child:Destroy()
		end
	end
	local layout = PlayerList:FindFirstChildOfClass("UIListLayout")
	-- llamar la funcion pa conseguir los datos no se
	local function getEmblemAsync(groupId)
		if not groupId or type(groupId) ~= "number" then
			return "" -- Return empty string if no valid groupId
		end
		local success, result = pcall(function()
			local groupInfo = GroupService:GetGroupInfoAsync(groupId)
			return groupInfo.EmblemUrl
		end)
		if success and result then
			return result
		else
			warn("[GangInfo] Failed to get emblem for groupId:", groupId)
			return "" -- Return empty string if API call fails
		end
	end
	local teamInfo = GangInfo.GetTeamInfoByPlayer(player)
	if not teamInfo then
		self.DebugPrint("No team info found for player:", player.Name)
		return
	end
	InfoFrame.GangID.Text = "ID: "..tostring(teamInfo.GangId)
	InfoFrame.GangName.Text = teamInfo.TeamName
	InfoFrame.GangName.Sombra.Text = teamInfo.TeamName --shadow
	InfoFrame.GangSize.Text = tostring(teamInfo.GangSize)

	-- Only try to get emblem if we have a valid numeric groupId
	if type(teamInfo.GangId) == "number" then
		InfoFrame.IMG.Image = getEmblemAsync(teamInfo.GangId)
	else
		InfoFrame.IMG.Image = "" -- Clear image if no valid groupId
	end
	for _, member in ipairs(teamInfo.Members) do
		local row = templateClone:Clone()
		row.Name = member.Username
		row.Visible = true
		row.Parent = PlayerList

		local usernameLabel = row:FindFirstChild("PlayerName")
		if usernameLabel then
			usernameLabel.Text = member.Username
		end

		local rankLabel = row:FindFirstChild("PlayerRank")
		if rankLabel then
			rankLabel.Text = member.Rank
		end

		local thumbImage = row:FindFirstChild("IMG")
		if thumbImage and thumbImage:IsA("ImageLabel") then
			thumbImage.Image = member.Thumbnail
		end
	end
end

return GangInfo
