-- CapturePointUI.luau
-- Simple UI to display all capture points, their owner group id, and team color


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local CapturePointHandler = require(ReplicatedStorage:WaitForChild("Handler"):WaitForChild("CapturePointHandler"))
local TurfClient = require(ReplicatedStorage:WaitForChild("UI"):WaitForChild("TurfClient"))

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

    -- Get all capture points
    local capturePoints = CapturePointHandler:GetAllCapturePoints()
    for _, cp in ipairs(capturePoints) do
        local info = cp:GetInfo()
        local occupyingTeam = cp.OccupyingTeam
        local teamColor = Color3.new(0.5,0.5,0.5)
        local groupId = "None"
        if occupyingTeam then
            teamColor = occupyingTeam.TeamColor and occupyingTeam.TeamColor.Color or Color3.new(0.5,0.5,0.5)
            -- Use TurfClient to get the turf for this team
            local turfInstance = TurfClient:GetTurfByTeam(occupyingTeam)
            if turfInstance then
                local ownerValue = turfInstance:FindFirstChild("Owner")
                if ownerValue and ownerValue.Value then
                    local owner = ownerValue.Value
                    groupId = tostring(owner.UserId or owner.Name or "Unknown")
                end
            end
        end

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 32)
        row.BackgroundTransparency = 1
        row.Parent = list

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = info.Name
        nameLabel.Font = Enum.Font.SourceSans
        nameLabel.TextSize = 22
        nameLabel.TextColor3 = Color3.new(1,1,1)
        nameLabel.Parent = row

        local groupLabel = Instance.new("TextLabel")
        groupLabel.Size = UDim2.new(0.3, 0, 1, 0)
        groupLabel.Position = UDim2.new(0.4, 0, 0, 0)
        groupLabel.BackgroundTransparency = 1
        groupLabel.Text = "Group: " .. groupId
        groupLabel.Font = Enum.Font.SourceSans
        groupLabel.TextSize = 20
        groupLabel.TextColor3 = Color3.new(0.8,0.8,0.8)
        groupLabel.Parent = row

        local colorBox = Instance.new("Frame")
        colorBox.Size = UDim2.new(0, 32, 0, 32)
        colorBox.Position = UDim2.new(0.7, 10, 0, 0)
        colorBox.BackgroundColor3 = teamColor
        colorBox.BorderSizePixel = 0
        colorBox.Parent = row
    end
end

return createCapturePointUI
