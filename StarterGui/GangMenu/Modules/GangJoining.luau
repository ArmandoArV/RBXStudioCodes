-- GangJoining.lua
local GangJoining = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local GangMenu = script.Parent.Parent
local Background = GangMenu:WaitForChild("Background")
local Frames = Background:WaitForChild("Menu")

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
    local JOINFrame = Frames:WaitForChild("JOIN")
    local groupIdInput = JOINFrame:WaitForChild("GroupID")
    local joinButton = JOINFrame:WaitForChild("Join")

    local statusLabel = JOINFrame:FindFirstChild("Status")
    if not statusLabel then
        statusLabel = Instance.new("TextLabel")
        statusLabel.Name = "Status"
        statusLabel.Parent = JOINFrame
        statusLabel.Text = ""
        statusLabel.TextColor3 = Color3.new(1, 1, 1)
        statusLabel.TextSize = 14
        statusLabel.BackgroundTransparency = 1
        statusLabel.Size = UDim2.new(1, 0, 0, 20)
        statusLabel.Position = UDim2.new(0, 0, 1, 5)
    end

    joinButton.MouseButton1Click:Connect(function()
        local groupId = tonumber(groupIdInput.Text)
        if not groupId then
            statusLabel.Text = "Invalid Group ID"
            return
        end

        statusLabel.Text = "Verifying group..."
        joinButton.Active = false

        local success, groupName = pcall(function()
            return ReplicatedStorage:WaitForChild("GetGroupName"):InvokeServer(groupId)
        end)

        if not success or not groupName then
            statusLabel.Text = "Invalid group"
            joinButton.Active = true
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
