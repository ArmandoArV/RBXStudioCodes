local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")

-- Debugging function
local function debugPrint(...)
    print("[Gang Creation Debug]", ...)
end

-- UI Setup
local GangMenu = script.Parent
local Buttons = GangMenu:WaitForChild("Buttons")
local Frames = GangMenu:WaitForChild("Menu")

-- Ensure RemoteEvent exists
local GangRemoteEvent = ReplicatedStorage:FindFirstChild("GangRemoteEvent") or Instance.new("RemoteEvent")
GangRemoteEvent.Name = "GangRemoteEvent"
GangRemoteEvent.Parent = ReplicatedStorage

-- UI Visibility Management
local function setButtonColors(activeButton)
    for _, button in pairs(Buttons:GetChildren()) do
        if button:IsA("TextButton") then
            button.BackgroundColor3 = button == activeButton and Color3.fromRGB(45, 45, 45) or Color3.new(0, 0, 0)
        end
    end
end

-- Button Connections
Buttons.TURFS.MouseButton1Click:Connect(function()
    Frames.TURFS.Visible = true
    Frames.CREATE.Visible = false
    Frames.JOIN.Visible = false
    setButtonColors(Buttons.TURFS)
end)

Buttons.CREATE.MouseButton1Click:Connect(function()
    Frames.TURFS.Visible = false
    Frames.CREATE.Visible = true
    Frames.JOIN.Visible = false
    setButtonColors(Buttons.CREATE)
    debugPrint("CREATE button clicked - UI switched to CREATE frame")
end)

Buttons.MENU.MouseButton1Click:Connect(function()
    Frames.TURFS.Visible = false
    Frames.CREATE.Visible = false
    Frames.JOIN.Visible = true
    setButtonColors(Buttons.MENU)
end)

-- Gang Creation Functionality
local function setupGangCreation()
    local CREATEFrame = Frames.CREATE
    local groupIdInput = CREATEFrame:WaitForChild("ID")
    local groupImg = CREATEFrame:WaitForChild("IMG")
    local groupName = groupImg:WaitForChild("GroupName")
    local createButton = CREATEFrame:WaitForChild("Create")
    local availableColors = CREATEFrame:WaitForChild("AvailableColors")

    local selectedBrickColor = nil

    -- Populate available BrickColors from external module
    local GangColorPalette = require(ReplicatedStorage.UI.GangColorPalette)
    local function populateAvailableColors()
        debugPrint("populateAvailableColors started")
        if not availableColors then
            warn("availableColors is nil!")
            return
        end

        local children = availableColors:GetChildren()
        debugPrint("Children count:", #children)

        for i, child in ipairs(children) do
            debugPrint(string.format("Child %d: %s", i, child.Name))
            if child:IsA("TextButton") or child:IsA("Frame") then
                child:Destroy()
            end
        end

        debugPrint("GangColorPalette count:", #GangColorPalette)

        for i, name in ipairs(GangColorPalette) do
            local success, bc = pcall(function()
                return BrickColor.new(name)
            end)
            if not success or not bc then
                warn("BrickColor '" .. name .. "' is invalid or not found!")
            else
                local colorButton = Instance.new("TextButton")
                colorButton.Size = UDim2.new(1, 0, 0, 30)
                colorButton.BackgroundColor3 = bc.Color
                colorButton.Text = bc.Name
                colorButton.TextColor3 = Color3.new(1, 1, 1)
                colorButton.Font = Enum.Font.SourceSans
                colorButton.TextSize = 14
                colorButton.Parent = availableColors

                colorButton.MouseButton1Click:Connect(function()
                    selectedBrickColor = bc
                    debugPrint("Selected BrickColor:", bc.Name)
                end)
            end
        end

        debugPrint("Available BrickColors populated")
    end

    -- Group ID input handler
    groupIdInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local groupId = groupIdInput.Text
            local groupIdNum = tonumber(groupId)
            if groupIdNum then
                groupImg.Image = "rbxthumb://type=GroupIcon&id=" .. groupIdNum .. "&w=150&h=150"
                local remoteFunction = ReplicatedStorage:WaitForChild("GetGroupName")
                local groupNameResult = remoteFunction:InvokeServer(groupIdNum)
                groupName.Text = groupNameResult or "Group Name Not Found"
                debugPrint("Group info loaded for ID:", groupIdNum)
            else
                groupImg.Image = ""
                groupName.Text = "Invalid Group ID"
                debugPrint("Invalid group ID entered")
            end
        end
    end)

    -- Create button handler
    createButton.MouseButton1Click:Connect(function()
        debugPrint("Create button clicked - Starting gang creation process")

        local groupId = groupIdInput.Text
        local name = groupName.Text

        -- Input validation
        if groupId == "" or name == "" then
            debugPrint("Validation failed - Empty fields")
            return
        end

        local groupIdNum = tonumber(groupId)
        if not groupIdNum then
            debugPrint("Validation failed - Invalid Group ID")
            return
        end

        if not selectedBrickColor then
            debugPrint("Validation failed - No BrickColor selected")
            return
        end

        debugPrint(string.format("Attempting to create gang - Name: %s, ID: %d, BrickColor: %s", name, groupIdNum,
            selectedBrickColor.Name))

        -- Fire to server
        GangRemoteEvent:FireServer("CreateGang", {
            name = name,
            groupId = groupIdNum,
            color = {
                r = selectedBrickColor.Color.R,
                g = selectedBrickColor.Color.G,
                b = selectedBrickColor.Color.B
            }
        })
    end)

    -- Handle server responses
    GangRemoteEvent.OnClientEvent:Connect(function(eventType, data)
        debugPrint("Received server event:", eventType, data)

        if eventType == "GangCreated" then
            debugPrint("Gang created successfully!")
            GangMenu.Visible = false
            Players.LocalPlayer:LoadCharacter()
        elseif eventType == "GangCreateFailed" then
            debugPrint("Gang creation failed:", data)
        end
    end)

    -- Call this once to populate colors
    populateAvailableColors()
end

local function joinGang()
    local JOINFrame = Frames.JOIN
    local groupIdInput = JOINFrame:WaitForChild("GroupID")
    local joinButton = JOINFrame:WaitForChild("Join")

    -- Placeholder for join gang functionality
    debugPrint("Join gang functionality not implemented yet")

    -- Add functionality to join a gang here
    if groupIdInput.Text == "" then
        debugPrint("Group ID input is empty")
        return
    end

    local groupId = tonumber(groupIdInput.Text)
    if not groupId then
        debugPrint("Invalid Group ID entered:", groupIdInput.Text)
        return
    end

    debugPrint("Attempting to join gang with Group ID:", groupId)
    GangRemoteEvent:FireServer("JoinGang", {
        groupId = groupId
    })

    debugPrint("Join gang request sent to server")

    -- Handle server response
    GangRemoteEvent.OnClientEvent:Connect(function(eventType, data)
        debugPrint("Received server event:", eventType, data)

        if eventType == "GangJoined" then
            debugPrint("Successfully joined gang!")
            GangMenu.Enabled = false
            Players.LocalPlayer:LoadCharacter()
        elseif eventType == "GangJoinFailed" then
            debugPrint("Failed to join gang:", data)
        end
    end)
end

-- Initialize
setupGangCreation()
joinGang()
debugPrint("Gang creation system initialized")
