local GangCreation = {}
GangCreation.__index = GangCreation
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local GangMenu = script.Parent.Parent
local Background = GangMenu:WaitForChild("Background")
local Frames = Background:WaitForChild("Menu")

local DEBUG_PREFIX = "[GangCreation]"
local GangRemoteEvent = ReplicatedStorage:WaitForChild("GangRemoteEvent")

local selectedBrickColor = nil

local function debugPrint(...)
    print(DEBUG_PREFIX, ...)
end

local populateAvailableColors

function GangCreation.new(frames, remoteEvent, debugPrint)
    local self = setmetatable({}, GangCreation)

    self.Frames = frames
    self.RemoteEvent = remoteEvent
    self.DebugPrint = debugPrint
    return self
end

function GangCreation:Setup(uiManager)
    local CREATEFrame = self.Frames:WaitForChild("CREATE")
    local groupIdInput = CREATEFrame:WaitForChild("ID")
    local groupImg = CREATEFrame:WaitForChild("IMG")
    local groupName = groupImg:WaitForChild("GroupName")
    local createButton = CREATEFrame:WaitForChild("Create")
    local availableColors = CREATEFrame:WaitForChild("AvailableColors")

    local colorStatusLabel = CREATEFrame:FindFirstChild("ColorStatus")
    if not colorStatusLabel then
        colorStatusLabel = Instance.new("TextLabel")
        colorStatusLabel.Name = "ColorStatus"
        colorStatusLabel.Parent = CREATEFrame
        colorStatusLabel.Text = ""
        colorStatusLabel.TextColor3 = Color3.new(1, 0.2, 0.2)
        colorStatusLabel.TextSize = 14
        colorStatusLabel.BackgroundTransparency = 1
        colorStatusLabel.Size = UDim2.new(1, 0, 0, 20)
        colorStatusLabel.Position = UDim2.new(0, 0, 1, 5)
    end

    local function createColorButton(brickColor)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = brickColor.Color
        btn.Text = brickColor.Name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14

        btn.MouseButton1Click:Connect(function()
            selectedBrickColor = brickColor
            self.DebugPrint("Selected BrickColor:", brickColor.Name)
            populateAvailableColors()
        end)

        return btn
    end

    populateAvailableColors = function()
        self.DebugPrint("Populating available colors")

        availableColors:ClearAllChildren()

        if not availableColors:IsA("ScrollingFrame") then
            warn("AvailableColors is not a ScrollingFrame! Please fix this in Studio.")
        end

        local uiListLayout = availableColors:FindFirstChildOfClass("UIListLayout")
        if not uiListLayout then
            uiListLayout = Instance.new("UIListLayout")
            uiListLayout.Parent = availableColors
            uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            uiListLayout.Padding = UDim.new(0, 5)
        end

        local excludedColors = {}

        local success1, reservedResult = pcall(function()
            return ReplicatedStorage:WaitForChild("GetExcludedGangColors"):InvokeServer()
        end)
        local success2, takenResult = pcall(function()
            return ReplicatedStorage:WaitForChild("GetTakenGangColors"):InvokeServer()
        end)

        if success1 and type(reservedResult) == "table" then
            for _, colorName in ipairs(reservedResult) do
                excludedColors[colorName] = true
            end
        end
        if success2 and type(takenResult) == "table" then
            for _, colorName in ipairs(takenResult) do
                excludedColors[colorName] = true
            end
        end

        local GangColorPalette = require(ReplicatedStorage:WaitForChild("UI"):WaitForChild("GangColorPalette"))
        local visibleIndex = 1

        for _, name in ipairs(GangColorPalette) do
            if not excludedColors[name] and (not selectedBrickColor or selectedBrickColor.Name ~= name) then
                local success, bc = pcall(BrickColor.new, name)
                if success and bc then
                    local btn = createColorButton(bc)
                    btn.LayoutOrder = visibleIndex
                    btn.Parent = availableColors
                    visibleIndex = visibleIndex + 1
                else
                    warn("Invalid BrickColor name:", name)
                end
            end
        end

        task.wait(0.1)
        availableColors.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
        self.DebugPrint("AvailableColors count after populate:", #availableColors:GetChildren())
    end

    local function validateGroupId(id)
        local idNum = tonumber(id)
        if not idNum then
            return false
        end

        local success, result = pcall(function()
            return ReplicatedStorage:WaitForChild("GetGroupName"):InvokeServer(idNum)
        end)

        if success and result then
            groupImg.Image = "rbxthumb://type=GroupIcon&id=" .. idNum .. "&w=150&h=150"
            groupName.Text = result
            return true
        else
            groupImg.Image = ""
            groupName.Text = "Invalid Group ID"
            return false
        end
    end

    groupIdInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            validateGroupId(groupIdInput.Text)
        end
    end)

    createButton.MouseButton1Click:Connect(function()
        self.DebugPrint("Create button clicked")

        local groupId = tonumber(groupIdInput.Text)
        local name = groupName.Text

        if not groupId or name == "" or name == "Invalid Group ID" or not selectedBrickColor then
            self.DebugPrint("Validation failed - Missing fields")
            colorStatusLabel.Text = "Please fill all fields and select a color."
            return
        end

        local colorName = selectedBrickColor.Name
        local excludedColors = {}
        local success, result = pcall(function()
            return ReplicatedStorage:WaitForChild("GetExcludedGangColors"):InvokeServer()
        end)
        if success and type(result) == "table" then
            for _, exColor in ipairs(result) do
                excludedColors[exColor] = true
            end
        end
        if excludedColors[colorName] then
            self.DebugPrint("Color is taken!")
            colorStatusLabel.Text = "Color is already taken. Please select another."
            return
        end

        colorStatusLabel.Text = ""
        local colorData = selectedBrickColor.Color
        self.DebugPrint("Creating gang:", name, "Group ID:", groupId, "Color:", colorData)

        self.RemoteEvent:FireServer("CreateGang", {
            name = name,
            groupId = groupId,
            color = {
                r = colorData.R,
                g = colorData.G,
                b = colorData.B
            }
        })
    end)

    populateAvailableColors()
end

return GangCreation
