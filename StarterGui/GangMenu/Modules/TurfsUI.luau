-- TurfsUI.lua
local TurfsUI = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GangMenu = script.Parent.Parent
local Background = GangMenu:WaitForChild("Background")
local Frames = Background:WaitForChild("Menu")

local DEBUG_PREFIX = "[TurfsUI]"

local function debugPrint(...)
    print(DEBUG_PREFIX, ...)
end

function TurfsUI.new(frames, debugPrint)
    local self = setmetatable({}, TurfsUI)

    self.Frames = frames
    self.DebugPrint = debugPrint

    return self
end

function TurfsUI:Populate()
    local TurfsFrame = Frames:FindFirstChild("TURFS")
    if not TurfsFrame then
        warn("[TurfsUI] No TURFS frame found")
        return
    end
    local BackgroundFrame = TurfsFrame:FindFirstChild("Background")
    if not BackgroundFrame then
        warn("[TurfsUI] No Background in TURFS frame")
        return
    end

    if not BackgroundFrame:IsA("ScrollingFrame") then
        warn("[TurfsUI] Background is not a ScrollingFrame! Fix in Studio.")
    end

    for _, child in ipairs(BackgroundFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local layout = BackgroundFrame:FindFirstChildOfClass("UIListLayout")
    if not layout then
        layout = Instance.new("UIListLayout")
        layout.Parent = BackgroundFrame
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)
    end

    local folder = ReplicatedStorage:WaitForChild("CapturePoints")
    local capturePoints = folder:GetChildren()

    debugPrint("Found capture points:", #capturePoints)

    local template = BackgroundFrame:FindFirstChild("FrameToDuplicate")
    if not template then
        warn("[TurfsUI] FrameToDuplicate not found")
        return
    end

    local rowCount = 0
    for _, cpFolder in ipairs(capturePoints) do
        local name = cpFolder.Name
        local location = cpFolder:FindFirstChild("Location") and cpFolder.Location.Value or "?"
        local occupied = cpFolder:FindFirstChild("Occupied") and cpFolder.Occupied.Value or false
        local team = cpFolder:FindFirstChild("Team") and cpFolder.Team.Value or "None"

        local row = template:Clone()
        row.Name = name .. "Row"
        row.Visible = true
        row.Parent = BackgroundFrame

        local ownedBox = row:FindFirstChild("Owned")
        local payTitleBox = row:FindFirstChild("PayTitle")

        if ownedBox and ownedBox:IsA("TextBox") then
            ownedBox.Text = (team ~= "None") and team or "Unoccupied"
        else
            warn("[TurfsUI] Owned TextBox missing in row", row.Name)
        end

        if payTitleBox and payTitleBox:IsA("TextBox") then
            payTitleBox.Text = "Location: " .. location .. " | Occupied: " .. tostring(occupied)
        else
            warn("[TurfsUI] PayTitle TextBox missing in row", row.Name)
        end

        rowCount = rowCount + 1
    end

    if BackgroundFrame:IsA("ScrollingFrame") and layout then
        BackgroundFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end

    debugPrint("Total rows created:", rowCount)
end

return TurfsUI
