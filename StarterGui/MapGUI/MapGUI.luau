-- MapGUI.luau
-- Client-side script to connect existing map GUI ImageButtons to teleportation system with group restrictions
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for the map teleport event and function from ReplicatedStorage
local mapTeleportEvent = ReplicatedStorage:WaitForChild("MapTeleportEvent")
local getAccessibleLocationsFunction = ReplicatedStorage:WaitForChild("GetAccessibleLocations")

-- Spawn delay tracking
local lastSpawnTime = 0
local SPAWN_DELAY = 10 -- 10 seconds delay between spawns

-- Find your existing Map GUI structure: Map(Gui)->Background(Frame)->Map(Img)->Ubication buttons
local function findMapGUI()
    local mapGui = playerGui:WaitForChild("Map") -- Your Map ScreenGui
    local background = mapGui:WaitForChild("Background") -- Your Background Frame  
    local mapImg = background:WaitForChild("Map") -- Your Map ImageLabel

    return mapGui, background, mapImg
end

-- Function to get all accessible spawn points for the player from server
local function getAccessibleSpawnPoints()
    local success, result = pcall(function()
        return getAccessibleLocationsFunction:InvokeServer()
    end)

    if success and result then
        return result
    else
        warn("[MapGUI] Failed to get accessible spawn points from server:", tostring(result))
        return {}
    end
end

-- Function to check spawn delay
local function canSpawn()
    local currentTime = tick()
    local timeLeft = SPAWN_DELAY - (currentTime - lastSpawnTime)

    if timeLeft > 0 then
        return false, timeLeft
    end

    return true, 0
end

-- Function to create and show cooldown notification with tween
local function showCooldownNotification(timeLeft, mapGui)
    -- Hide map UI immediately
    mapGui.Enabled = false

    -- Create cooldown notification
    local notification = Instance.new("ScreenGui")
    notification.Name = "SpawnCooldownNotification"
    notification.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.3, 0, 0.1, 0)
    frame.Position = UDim2.new(0.5, 0, -0.1, 0) -- Start above screen
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    frame.BorderSizePixel = 0
    frame.Parent = notification

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Spawn Cooldown: " .. math.ceil(timeLeft) .. "s"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = frame

    -- Tween notification down from top
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local tweenDown = TweenService:Create(frame, tweenInfo, {
        Position = UDim2.new(0.5, 0, 0.092, 0)
    })
    tweenDown:Play()

    -- Start countdown loop
    task.spawn(function()
        local remainingTime = timeLeft

        while remainingTime > 0 do
            wait(1)
            remainingTime = remainingTime - 1

            if label and label.Parent then
                label.Text = "Spawn Cooldown: " .. math.ceil(remainingTime) .. "s"
            else
                break -- Label was destroyed, exit loop
            end
        end

        -- Tween notification back up and destroy
        if notification and notification.Parent then
            local tweenUp = TweenService:Create(frame, tweenInfo, {
                Position = UDim2.new(0.5, 0, -0.1, 0)
            })
            tweenUp:Play()

            tweenUp.Completed:Connect(function()
                notification:Destroy()
            end)
        end
    end)
end

-- Function to setup teleportation for existing location buttons
local function setupLocationButtons()
    local mapGui, background, mapImg = findMapGUI()
    local accessibleSpawns = getAccessibleSpawnPoints()

    print("[MapGUI] Player has access to", #accessibleSpawns, "spawn points")

    -- Find all location ImageButtons (Ubication1, Ubication2, etc.)
    for _, child in pairs(mapImg:GetChildren()) do
        if child:IsA("ImageButton") then
            local locationName = child.Name
            local hasAccess = false
            local matchedSpawnPoint = nil

            -- Check if this button corresponds to an accessible spawn point
            for _, spawnPoint in pairs(accessibleSpawns) do
                if spawnPoint.name == locationName or spawnPoint.displayName == locationName or spawnPoint.locationName ==
                    locationName then
                    hasAccess = true
                    matchedSpawnPoint = spawnPoint
                    break
                end
            end

            -- Only allow access if the server confirmed the player has access to this location
            -- No fallback access - all access must be verified by server through group membership

            if hasAccess then
                print("[MapGUI] Setting up accessible location button:", locationName)

                -- Set team color if available
                if matchedSpawnPoint and matchedSpawnPoint.teamColor then
                    local teamColor = BrickColor.new(matchedSpawnPoint.teamColor).Color
                    child.ImageColor3 = teamColor
                    print("[MapGUI] Set button color for", locationName, "to team color:", matchedSpawnPoint.teamColor)
                else
                    -- Default color for locations without team colors
                    child.ImageColor3 = Color3.new(1, 1, 1) -- White
                end
                local maplabel = child:FindFirstChildOfClass("TextLabel")
                if not maplabel then
                    warn("label for map button not found")
                else
                    maplabel.Text = child.Name
                    maplabel.Visible = true
                end

                -- Check if location is controlled by a different gang and add lock icon
                local playerTeam = player.Team
                local isControlledByDifferentGang = false
                
                if matchedSpawnPoint and matchedSpawnPoint.teamColor and playerTeam then
                    local locationTeamColor = matchedSpawnPoint.teamColor
                    local playerTeamColor = playerTeam.TeamColor.Name
                    
                    if locationTeamColor ~= playerTeamColor then
                        isControlledByDifferentGang = true
                    end
                end

                -- Add locked indicator for locations controlled by different gangs
                if isControlledByDifferentGang then
                    local lockIcon = child:FindFirstChild("LockIcon")
                    if not lockIcon then
                        lockIcon = Instance.new("ImageLabel")
                        lockIcon.Name = "LockIcon"
                        lockIcon.Size = UDim2.new(1, 0, 1, 0)
                        lockIcon.BackgroundTransparency = .6
                        lockIcon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        lockIcon.Image = "rbxassetid://18383949066"
                        lockIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                        lockIcon.ZIndex = 2
                        lockIcon.Parent = child
                        lockIcon.ScaleType = Enum.ScaleType.Fit
                    end
                end

                -- Connect click event to teleportation
                child.MouseButton1Click:Connect(function()
                    -- Check spawn delay
                    local canSpawnNow, timeLeft = canSpawn()
                    if not canSpawnNow then
                        -- Show animated cooldown notification
                        showCooldownNotification(timeLeft, mapGui)
                        return
                    end

                    print("[MapGUI] Teleporting to:", locationName)

                    -- Hide map UI immediately
                    -- mapGui.Enabled = false

                    -- Update last spawn time
                    lastSpawnTime = tick()

                    -- Fire server event for teleportation
                    mapTeleportEvent:FireServer(locationName)
                end)
            else
                print("[MapGUI] Player does not have access to:", locationName)

                -- Disable button visually for inaccessible locations
                child.ImageTransparency = 0.7
                child.ImageColor3 = Color3.fromRGB(150, 150, 150) -- Gray for locked buttons
                child.Active = false

                -- Add locked indicator
                local lockIcon = child:FindFirstChild("LockIcon")
                if not lockIcon then
                    lockIcon = Instance.new("ImageLabel")
                    lockIcon.Name = "LockIcon"
                    lockIcon.Size = UDim2.new(1, 0, 1, 0)
                    lockIcon.BackgroundTransparency = .6
                    lockIcon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    lockIcon.Image = "rbxassetid://18383949066"
                    lockIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    lockIcon.ZIndex = 2
                    lockIcon.Parent = child
                    lockIcon.ScaleType = Enum.ScaleType.Fit
                end
            end
        end
    end
end

-- Function to toggle your existing map GUI visibility
local function toggleMapGui()
    local mapGui, background, mapImg = findMapGUI()
    local OGTeam = player.Team
    local Teams = game:GetService("Teams")
    -- Toggle visibility of your map GUI
    if OGTeam ~= nil and Teams:FindFirstChild(OGTeam.Name) then
        local team = Teams:FindFirstChild(OGTeam.Name)
        if (team:GetAttribute("IsGang") == true or team:GetAttribute("IsGang") == "yes") or OGTeam.Name == "CIUDADANO" then
            mapGui.Enabled = not mapGui.Enabled
        end
    end

    print("[MapGUI] Map GUI toggled. Visible:", mapGui.Enabled)
end

-- Listen for server response to hide UI after successful teleport
mapTeleportEvent.OnClientEvent:Connect(function(success, message)
    if success then
        -- Hide your map GUI after successful teleport
        local mapGui, background, mapImg = findMapGUI()
        mapGui.Enabled = false
        print("[MapGUI] Map closed after successful teleportation")
    else
        -- Show error message
        warn("[MapGUI] Teleportation failed:", message or "Unknown error")
    end
end)

-- Setup the system when everything is loaded
task.spawn(function()
    -- Wait a bit for the GUI to be fully loaded
    task.wait(2)

    local success, error = pcall(setupLocationButtons)
    if success then
        print("[MapGUI] Successfully connected location buttons to teleportation system")
    else
        warn("[MapGUI] Error setting up location buttons:", error)
        warn("[MapGUI] Make sure your GUI structure is: Map(Gui)->Background(Frame)->Map(Img)->LocationButtons")
    end
end)

-- Make toggle function globally accessible
_G.ToggleMapGUI = toggleMapGui

toggleMapGui()

print("[MapGUI] Map GUI integration system loaded successfully!")
