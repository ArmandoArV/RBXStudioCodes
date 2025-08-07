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

screenGui.Enabled = true
local teamFrame = screenGui.Template.Team
local playerFrame = screenGui.Template.Player:Clone()
local teamstable = {}
local layoutOrder = 1
local list = screenGui.Ui.Holder.Main.ListHold
local barhold = screenGui.Ui.Holder.Main.BarHold
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
	layoutOrder = layoutOrder + 100
	table.insert(teamstable,{team.Name,frame.LayoutOrder})
end
function checkTeams()
	for _,team in pairs(teamstable) do
		local isempty = true
		for _,i in pairs(game.Players:GetPlayers()) do
			if i.Team ~= nil and i.Team.Name == team[1] then
				isempty = false
			end
		end
		if list:FindFirstChild(team[1]) then 
			if isempty then
				table.remove(team,3)
				team[2] = list:FindFirstChild(team[1]).LayoutOrder
			end
			if not table.find(team,"hasplayer") then
				list:FindFirstChild(team[1]).Visible = false
			else
				list:FindFirstChild(team[1]).Visible = true
			end
		end
	end
end
local count = 0
function setupPlyr(player)
	if player ~= nil and game.Players:FindFirstChild(player.Name) then
		count = count+1
		barhold.frame.number.Text = count
		if screenGui.Ui.Holder.Main.ListHold:FindFirstChild(player.Name) then
			screenGui.Ui.Holder.Main.ListHold:FindFirstChild(player.Name):Destroy()
		end
		local playerFrame = playerFrame:Clone()
		playerFrame.LayoutOrder = layoutOrder
		playerFrame.Name = player.Name
		playerFrame.Parent = screenGui.Ui.Holder.Main.ListHold
		task.wait(0.1)
		for _, tablething in pairs(teamstable) do
			if player.Team ~= nil and tablething[1] == player.Team.Name then
				playerFrame.LayoutOrder = tablething[2] + 1
				--warn(playerFrame.LayoutOrder.." / "..tablething[2])
				if not table.find(tablething,"hasplayer") then
					table.insert(tablething,"hasplayer")
				end
			elseif player.Team == nil then
				--warn('"'..player.Name..'".Team returned nil! [1]')
				playerFrame.LayoutOrder = 0
			end
		end
		checkTeams()
		playerFrame.Visible = true
		--basic data
		local basicui = playerFrame.basic
		basicui.PlayerRank.Text = player:GetRoleInGroup(config.GroupId)
		basicui.userdata.PlayerLabel.Text = player.Name
		for _, thing in pairs(groups) do
			if player:IsInGroup(config.GroupId) then
				if thing.RankId == player:GetRankInGroup(config.GroupId) then
					basicui.userdata.Rank.Image = "rbxassetid://" .. thing.Image
				end
			else
				basicui.userdata.Rank.Visible = false
			end
		end
		--detailed data
		local detailedui = playerFrame.details
		detailedui.Frame.user.Label.Text = "@"..player.Name
		detailedui.Frame.rank.Label.Text = player:GetRoleInGroup(config.GroupId)
		local userId = player.UserId
		local thumbType = Enum.ThumbnailType.HeadShot
		local thumbSize = Enum.ThumbnailSize.Size420x420
		local content, isReady = players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
		local imageLabel = detailedui.usericon
		imageLabel.Image = content
		local OGteam = nil
		if player.Team ~= nil then
			OGteam = player.Team.Name
		end
		local NEWteam = nil
		for _, tablething in pairs(teamstable) do
			if player.Team ~= nil and tablething[1] == player.Team.Name then	
				--warn(playerFrame.LayoutOrder.." / "..tablething[2])
				if playerFrame.LayoutOrder <= tablething[2] then
					playerFrame.LayoutOrder = tablething[2] + 1
				end
			elseif player.Team == nil then
				--warn('"'..player.Name..'".Team returned nil! [2]')
				playerFrame.LayoutOrder = 0
			end
		end
		player.Changed:Connect(function(thing)
			task.wait(0.02)
			if player.Team ~= nil then
				if OGteam ~= nil then
					NEWteam = player.Team.Name
					if OGteam ~= NEWteam then
						for _, tablething in pairs(teamstable) do
							--warn(tablething)
							if tablething[1] == OGteam then
								tablething[2] = tablething[2] - 1
								if tablething[2] < list:FindFirstChild(tablething[1]).LayoutOrder then
									tablething[2] = list:FindFirstChild(tablething[1]).LayoutOrder
								end
								checkTeams()
							end
							if tablething[1] == NEWteam then
								local order
								if tablething[2] < list:FindFirstChild(tablething[1]).LayoutOrder then
									if not table.find(tablething,"hasplayer") then
										table.insert(tablething,"hasplayer")
										tablething[2] = list:FindFirstChild(tablething[1]).LayoutOrder + 1
										order = tablething[2]
									else
										local count = 0
										for _,i in pairs(game.Players:GetPlayers()) do
											if i.Team.Name == tablething[1] then
												count = count+1
											end
										end
										tablething[2] = list:FindFirstChild(tablething[1]).LayoutOrder + count
										order = tablething[2]
									end
								else
									tablething[2] = tablething[2] + 1
									order = tablething[2]
								end
								playerFrame.LayoutOrder = order
								if not table.find(tablething,"hasplayer") then
									table.insert(tablething,"hasplayer")
								end
								checkTeams()
							end
						end
					end
				end
				OGteam = player.Team.Name
				for _, tablething in pairs(teamstable) do
					if tablething[1] == player.Team.Name then	
						--warn(playerFrame.LayoutOrder.." / "..tablething[2])
						if playerFrame.LayoutOrder <= tablething[2] then
							playerFrame.LayoutOrder = tablething[2] + 1
						end
					end
				end
			elseif player.Team == nil then
				--warn('"'..player.Name..'".Team returned nil! [3]')
				playerFrame.LayoutOrder = 0
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
		table.clear(teamstable)
		teamstable = {}
		layoutOrder = 0
		for _, team in pairs(teams:GetTeams()) do
			local frame = teamFrame:Clone()
			frame.LayoutOrder = layoutOrder
			frame.Name = team.Name
			frame.Parent = list
			frame.Visible = true
			frame.Frame.BackgroundColor3 = team.TeamColor.Color
			frame.Frame.TeamLabel.Text = team.Name
			layoutOrder = layoutOrder + 100
			table.insert(teamstable,{team.Name,frame.LayoutOrder})
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
		table.insert(teamstable,{team.Name,frame.LayoutOrder})
	end
end)
game.Teams.ChildRemoved:Connect(function(child)
	if child:IsA("Team") then
		for _,i in pairs(teamstable) do
			if i[1] == child.Name then
				table.remove(teamstable,table.find(teamstable,i))
			end
		end
		list:FindFirstChild(child.Name):Destroy()
	end
end)