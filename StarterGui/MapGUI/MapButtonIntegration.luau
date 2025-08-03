-- MapButtonIntegration.luau
-- Script to add a Map button to the existing gang menu button system and integrate it with your existing map GUI
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Function to check if your existing map GUI exists
local function findExistingMapGUI()
    local mapGui = playerGui:FindFirstChild("Map")
    if mapGui then
        local background = mapGui:FindFirstChild("Background")
        if background then
            local mapImg = background:FindFirstChild("Map")
            if mapImg then
                print("[MapButton] Found existing Map GUI structure")
                return mapGui, background, mapImg
            end
        end
    end
    return nil
end
local gangMenu = playerGui:WaitForChild("Buttons")
-- Alternative toggle function that works with your existing GUI
local function toggleExistingMapGUI()
    local mapGui = findExistingMapGUI()
    if mapGui then
        mapGui.Enabled = not mapGui.Enabled
        print("[MapButton] Toggled existing Map GUI. Visible:", mapGui.Enabled)
        gangMenu:WaitForChild("Scripts").EquiposLocal.open.Value = false
        return true
    else
        warn("[MapButton] Could not find existing Map GUI")
        return false
    end
end

-- Wait for the gang menu buttons structure
local background = gangMenu:WaitForChild("GUIs"):WaitForChild("TeamFrame").Config.Frame:WaitForChild("Gangs")
local buttonsFrame = background:WaitForChild("Buttons")

-- Create the Map button following the same structure as other buttons
local function createMapButton()
    -- Check if button already exists
    if buttonsFrame:FindFirstChild("MAP") then
        return buttonsFrame:FindFirstChild("MAP")
    end

    -- Create main button frame
    local mapButton = script.MENU:Clone()
    mapButton.Name = "MAP"
    mapButton.Parent = buttonsFrame
    mapButton.Visible = true

    -- Create label
    local label = mapButton.Label
    label.Text = "MAPA"
    label.Shadow.Text = "MAPA"

    -- Add layout order (place it after other buttons)
    mapButton.LayoutOrder = 5 -- Adjust as needed

    return mapButton
end

-- Function to setup map button functionality
local function setupMapButton()
    local mapButton = createMapButton()
    if not mapButton then
        return
    end

    local toggleButton = mapButton:FindFirstChild("Toggle")
    if not toggleButton then
        return
    end

    -- Connect to map GUI toggle function
    toggleButton.MouseButton1Click:Connect(function()
        print("[MapButton] Map button clicked")

        -- First try to use existing map GUI
        if not toggleExistingMapGUI() then
            -- Fallback to the global toggle function from MapGUI if existing GUI not found
            if _G.ToggleMapGUI then
                _G.ToggleMapGUI()
            else
                warn("[MapButton] No map GUI found. Make sure your Map GUI exists or MapGUI.luau is loaded.")
            end
        end
    end)

    print("[MapButton] Map button setup complete")
end

-- Alternative: Add a keyboard shortcut (M key) to open the map
local function setupKeyboardShortcut()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if input.KeyCode == Enum.KeyCode.M then
            -- Try existing map GUI first, then fallback to global function
            if not toggleExistingMapGUI() then
                if _G.ToggleMapGUI then
                    _G.ToggleMapGUI()
                    gangMenu:WaitForChild("Scripts").EquiposLocal.open.Value = false
                end
            end
        end
    end)
    print("[MapButton] Keyboard shortcut (M key) setup complete")
end

-- Wait a bit for everything to load, then setup the button
task.spawn(function()
    -- Check if existing map GUI is present first
    task.wait(1)
    local hasExistingGUI = findExistingMapGUI() ~= nil

    if hasExistingGUI then
        setupMapButton()
        setupKeyboardShortcut()
        print("[MapButton] Map button integration complete! Using existing Map GUI.")
    else
        -- Wait for MapGUI to be loaded as fallback
        local attempts = 0
        while not _G.ToggleMapGUI and attempts < 50 do
            task.wait(0.1)
            attempts = attempts + 1
        end

        if _G.ToggleMapGUI then
            setupMapButton()
            setupKeyboardShortcut()
            print("[MapButton] Map button integration complete! Using fallback MapGUI.")
        else
            warn("[MapButton] No map GUI system found. Please ensure your Map GUI exists.")
        end
    end
end)

print("[MapButton] Map button integration script loaded")
