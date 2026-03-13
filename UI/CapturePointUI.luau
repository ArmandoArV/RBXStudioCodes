-- CapturePointUI.luau
-- Simple UI to display all capture points, their owner group id, and team color


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local ServerScript = game:WaitForChild("ServerScriptService")
local CapturePointHandler = require(ServerScript:WaitForChild("Handler"):WaitForChild("CapturePointHandler"))
local TurfClient = require(ReplicatedStorage:WaitForChild("UI"):WaitForChild("TurfClient"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent = ReplicatedStorage:FindFirstChild("CapturePointEvent")

local function createCapturePointUI()
	local player = Players.LocalPlayer
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CapturePointUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 400, 0, 300)
	frame.Position = UDim2.new(0.5, -200, 0.1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 0.2
	frame.Parent = screenGui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "Capture Points"
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 28
	title.TextColor3 = Color3.new(1,1,1)
	title.Parent = frame

	local list = Instance.new("Frame")
	list.Size = UDim2.new(1, -20, 1, -50)
	list.Position = UDim2.new(0, 10, 0, 45)
	list.BackgroundTransparency = 1
	list.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = list

	local function updateCapturePointsUI(allInfos)
		list:ClearAllChildren()
		layout.Parent = list
		for _, info in pairs(allInfos) do
			local teamColor = Color3.new(0.5,0.5,0.5)
			local groupId = info.OccupyingTeam or "None"
			-- You can add logic here to get team color/groupId from your group/team system

			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 32)
			row.BackgroundTransparency = 1
			row.Parent = list

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(0.3, 0, 1, 0)
			nameLabel.Position = UDim2.new(0, 0, 0, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = info.Name
			nameLabel.Font = Enum.Font.SourceSans
			nameLabel.TextSize = 22
			nameLabel.TextColor3 = Color3.new(1,1,1)
			nameLabel.Parent = row

			local groupLabel = Instance.new("TextLabel")
			groupLabel.Size = UDim2.new(0.3, 0, 1, 0)
			groupLabel.Position = UDim2.new(0.3, 0, 0, 0)
			groupLabel.BackgroundTransparency = 1
			groupLabel.Text = "Group: " .. groupId
			groupLabel.Font = Enum.Font.SourceSans
			groupLabel.TextSize = 20
			groupLabel.TextColor3 = Color3.new(0.8,0.8,0.8)
			groupLabel.Parent = row

			local scoreLabel = Instance.new("TextLabel")
			scoreLabel.Size = UDim2.new(0.2, 0, 1, 0)
			scoreLabel.Position = UDim2.new(0.6, 0, 0, 0)
			scoreLabel.BackgroundTransparency = 1
			scoreLabel.Text = "Score: " .. tostring(info.Score)
			scoreLabel.Font = Enum.Font.SourceSans
			scoreLabel.TextSize = 20
			scoreLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
			scoreLabel.Parent = row

			local modeLabel = Instance.new("TextLabel")
			modeLabel.Size = UDim2.new(0.2, 0, 1, 0)
			modeLabel.Position = UDim2.new(0.8, 0, 0, 0)
			modeLabel.BackgroundTransparency = 1
			modeLabel.Text = "Mode: " .. tostring(info.Mode)
			modeLabel.Font = Enum.Font.SourceSans
			modeLabel.TextSize = 18
			modeLabel.TextColor3 = Color3.new(0.7,0.7,1)
			modeLabel.Parent = row
		end
	end

	if remoteEvent then
		remoteEvent.OnClientEvent:Connect(function(action, info)
			if action == "UpdateCapturePointUI" then
				if info and type(info) == "table" then
					updateCapturePointsUI(info)
				end
			end
		end)
	end

	-- Initial static UI build (optional, can be removed if always event-driven)
	-- updateCapturePointsUI({})
end

return createCapturePointUI
