-- GangJoining.lua
local GangJoining = {}
GangJoining.__index = GangJoining
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local GangMenu = script.Parent.Parent
local Background = GangMenu:WaitForChild("GUIs").TeamFrame.Config.Frame:WaitForChild("Gangs")
local Frames = Background

local DEBUG_PREFIX = "[GangJoining]"
local GangRemoteEvent = ReplicatedStorage:WaitForChild("GangRemoteEvent")

local function debugPrint(...)
	print(DEBUG_PREFIX, ...)
end

function GangJoining.new(frames, remoteEvent, debugPrint)
	local self = setmetatable({}, GangJoining)
	self.Frames = frames
	self.RemoteEvent = remoteEvent
	self.DebugPrint = debugPrint
	return self
end


function GangJoining:Setup()
	debugPrint("hi")
	local JOINFrame = Frames:WaitForChild("JOIN")
	local groupIdInput = JOINFrame:WaitForChild("GroupID")
	local joinButton = JOINFrame:WaitForChild("Join")

	local statusLabel = JOINFrame:FindFirstChild("Status")
	--if not statusLabel then
	--	statusLabel = Instance.new("TextLabel")
	--	statusLabel.Name = "Status"
	--	statusLabel.Parent = JOINFrame
	--	statusLabel.Text = ""
	--	statusLabel.TextColor3 = Color3.new(1, 1, 1)
	--	statusLabel.TextSize = 14
	--	statusLabel.BackgroundTransparency = 1
	--	statusLabel.Size = UDim2.new(1, 0, 0, 20)
	--	statusLabel.Position = UDim2.new(0, 0, 1, 5)
	--end

	joinButton.Toggle.MouseButton1Click:Connect(function()
		debugPrint("mango")
		local groupId = tonumber(groupIdInput.Text)
		if not groupId then
			statusLabel.Text = "Invalid Group ID"
			return
		end

		statusLabel.Text = "Verificando Grupo..."
		joinButton.Label.Text = ". . ."
		joinButton.Label.Shadow.Text = ". . ."
		joinButton.Toggle.Visible = false

		local success, groupName = pcall(function()
			return ReplicatedStorage:WaitForChild("GetGroupName"):InvokeServer(groupId)
		end)

		if not success or not groupName then
			statusLabel.Text = "Grupo Invalido"
			joinButton.Toggle.Visible = true
			joinButton.Label.Text = "Ingresar"
			joinButton.Label.Shadow.Text = "Ingresar"
			return
		end

		debugPrint("Attempting to join gang:", groupName, "Group ID:", groupId)
		GangRemoteEvent:FireServer("JoinGang", {
			groupId = groupId,
			groupName = groupName
		})
	end)
end

return GangJoining
