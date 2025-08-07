local players = game:GetService("Players")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
local teams = game:GetService("Teams")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")

local screenGui = script:FindFirstAncestorWhichIsA("ScreenGui")
local config = require(screenGui.Config.Config)
local groups = require(screenGui.Config.GroupIcons)
local groupids = require(game.ServerScriptService.GroupIds)
local PlayerEntry = require(script.Parent.Classes.PlayerEntry)
local TeamEntry = require(script.Parent.Classes.TeamEntry)
local LeaderboardManager = require(script.Parent.Classes.LeaderboardManager)

screenGui.Enabled = true
local teamFrame = screenGui.Template.Team
local playerFrame = screenGui.Template.Player:Clone()
local layoutOrder = 1
local list = screenGui.Ui.Holder.Main.ListHold
local barhold = screenGui.Ui.Holder.Main.BarHold
local leaderboardManager = LeaderboardManager.new()
for _,i in pairs(list:GetChildren()) do
	if not i:IsA("UIListLayout") then i:Destroy() end
end
for _, team in pairs(teams:GetTeams()) do
	local frame = teamFrame:Clone()
	frame.LayoutOrder = layoutOrder
	frame.Name = team.Name
	frame.Parent = list
	frame.Visible = true
	frame.Frame.BackgroundColor3 = team.TeamColor.Color
	frame.Frame.TeamLabel.Text = team.Name
	local teamEntry = TeamEntry.new(team.Name, frame, layoutOrder)
	leaderboardManager:addTeam(teamEntry)
	layoutOrder = layoutOrder + 100
end
function checkTeams()
	for teamName, teamEntry in pairs(leaderboardManager.teams) do
		local isempty = true
		for _, player in pairs(game.Players:GetPlayers()) do
			if player.Team and player.Team.Name == teamName then
				isempty = false
				break
			end
		end
		if list:FindFirstChild(teamName) then
			list:FindFirstChild(teamName).Visible = not isempty
		end
	end
end
local count = 0
function setupPlyr(player)
	if player and game.Players:FindFirstChild(player.Name) then
		count = count + 1
		barhold.frame.number.Text = count
		if list:FindFirstChild(player.Name) then
			list:FindFirstChild(player.Name):Destroy()
		end
		local playerFrameClone = playerFrame:Clone()
		playerFrameClone.LayoutOrder = layoutOrder
		playerFrameClone.Name = player.Name
		playerFrameClone.Parent = list
		task.wait(0.1)
		local teamName = player.Team and player.Team.Name or nil
		if teamName and leaderboardManager:getTeam(teamName) then
			playerFrameClone.LayoutOrder = leaderboardManager:getTeam(teamName).layoutOrder + 1
		else
			playerFrameClone.LayoutOrder = 0
		end
		checkTeams()
		playerFrameClone.Visible = true
		-- basic data
		local basicui = playerFrameClone.basic
		local isCNI = false
		-- Check CNI group membership
		local cniGroupId = groupids.CNI.MAIN.ID
		if player:IsInGroup(cniGroupId) or (player.Team and player.Team.TeamColor and player.Team.TeamColor.Name == "Black") then
			isCNI = true
		end
		if isCNI then
			basicui.PlayerRank.Text = "CNI"
			basicui.userdata.PlayerLabel.Text = "CLASIFICADO"
		else
			basicui.PlayerRank.Text = player:GetRoleInGroup(config.GroupId)
			basicui.userdata.PlayerLabel.Text = player.Name
		end
		for _, thing in pairs(groups) do
			if player:IsInGroup(config.GroupId) then
				if thing.RankId == player:GetRankInGroup(config.GroupId) then
					basicui.userdata.Rank.Image = "rbxassetid://" .. thing.Image
				end
			else
				basicui.userdata.Rank.Visible = false
			end
		end
		-- detailed data
		local detailedui = playerFrameClone.details
		if isCNI then
			detailedui.Frame.user.Label.Text = "@CLASIFICADO"
			detailedui.Frame.rank.Label.Text = "CNI"
		else
			detailedui.Frame.user.Label.Text = "@" .. player.Name
			detailedui.Frame.rank.Label.Text = player:GetRoleInGroup(config.GroupId)
		end
		local userId = player.UserId
		local thumbType = Enum.ThumbnailType.HeadShot
		local thumbSize = Enum.ThumbnailSize.Size420x420
		local content, isReady = players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
		local imageLabel = detailedui.usericon
		imageLabel.Image = content
		local entry = PlayerEntry.new(player, playerFrameClone)
		leaderboardManager:addPlayer(entry)
		local OGteam = teamName
		player.Changed:Connect(function(thing)
			task.wait(0.02)
			local newTeam = player.Team and player.Team.Name or nil
			if newTeam ~= OGteam then
				if OGteam and leaderboardManager:getTeam(OGteam) then
					leaderboardManager:getTeam(OGteam):removePlayer(player.Name)
				end
				if newTeam and leaderboardManager:getTeam(newTeam) then
					leaderboardManager:getTeam(newTeam):addPlayer(entry)
					playerFrameClone.LayoutOrder = leaderboardManager:getTeam(newTeam).layoutOrder + 1
				else
					playerFrameClone.LayoutOrder = 0
				end
				OGteam = newTeam
				checkTeams()
			end
		end)
	end
end
game.Players.PlayerAdded:Connect(function(player)
	setupPlyr(player)
end)
game.Players.PlayerRemoving:Connect(function(player)
	count = count-1
	barhold.frame.number.Text = count
	for _,i in pairs(list:GetChildren()) do
		if i.Name == player.Name then
			i:Destroy()
		end
	end
	checkTeams()
end)
count = 0
barhold.frame.number.Text = count
for _, player in pairs(game.Players:GetPlayers()) do
	setupPlyr(player)
end
local event = game:GetService("ReplicatedStorage"):FindFirstChild("LeaderboardEvent")
if not event then
	warn("[SERVER] LeaderboardEvent not found in workspace!")
end
local processing = false
event.OnServerEvent:Connect(function(player,code)
	if code == "Restart" and processing == false then
		--print("Received request to restart leaderboard")
		processing = true
		count = 0
		barhold.frame.number.Text = count
		screenGui.Ui.Holder.Main.Restart.Visible = false
		for _,i in pairs(list:GetChildren()) do
			if not i:IsA("UIListLayout") then i:Destroy() end
		end
		leaderboardManager.teams = {}
		layoutOrder = 0
		for _, team in pairs(teams:GetTeams()) do
			local frame = teamFrame:Clone()
			frame.LayoutOrder = layoutOrder
			frame.Name = team.Name
			frame.Parent = list
			frame.Visible = true
			frame.Frame.BackgroundColor3 = team.TeamColor.Color
			frame.Frame.TeamLabel.Text = team.Name
			local teamEntry = TeamEntry.new(team.Name, frame, layoutOrder)
			leaderboardManager:addTeam(teamEntry)
			layoutOrder = layoutOrder + 100
		end
		for _, player in pairs(game.Players:GetPlayers()) do
			setupPlyr(player)
		end
		print("Finished reloading leaderboard!")
		processing = false
	end
end)
		
game.Teams.ChildAdded:Connect(function(team)
	if team:IsA("Team") then
		task.wait(0.01)
		local frame = teamFrame:Clone()
		frame.LayoutOrder = layoutOrder
		frame.Name = team.Name
		frame.Parent = list
		frame.Visible = true
		frame.Frame.BackgroundColor3 = team.TeamColor.Color
		frame.Frame.TeamLabel.Text = team.Name
		layoutOrder = layoutOrder + 100
		local teamEntry = TeamEntry.new(team.Name, frame, layoutOrder)
		leaderboardManager:addTeam(teamEntry)
	end
end)
game.Teams.ChildRemoved:Connect(function(child)
	if child:IsA("Team") then
		leaderboardManager.teams[child.Name] = nil
		if list:FindFirstChild(child.Name) then
			list:FindFirstChild(child.Name):Destroy()
		end
	end
end)
