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

-- Alternative toggle function that works with your existing GUI
local function toggleExistingMapGUI()
	local mapGui = findExistingMapGUI()
	if mapGui then
		mapGui.Enabled = not mapGui.Enabled
		print("[MapButton] Toggled existing Map GUI. Visible:", mapGui.Enabled)
		return true
	else
		warn("[MapButton] Could not find existing Map GUI")
		return false
	end
end

-- Wait for the gang menu buttons structure
local gangMenu = playerGui:WaitForChild("Buttons")
local background = gangMenu:WaitForChild("GUIs"):WaitForChild("TeamFrame").Config.Frame:WaitForChild("Gangs")
local buttonsFrame = background:WaitForChild("Buttons")

-- Create the Map button following the same structure as other buttons
local function createMapButton()
	-- Check if button already exists
	if buttonsFrame:FindFirstChild("MAP") then
		return buttonsFrame:FindFirstChild("MAP")
	end
	
	-- Create main button frame
	local mapButton = Instance.new("Frame")
	mapButton.Name = "MAP"
	mapButton.Size = UDim2.new(0, 100, 0, 60) -- Adjust size to match other buttons
	mapButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	mapButton.BorderSizePixel = 0
	mapButton.Parent = buttonsFrame
	
	-- Add corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = mapButton
	
	-- Add stroke (matching other buttons)
	local stroke = Instance.new("UIStroke")
	stroke.Name = "UIStroke"
	stroke.Color = Color3.fromRGB(70, 70, 70)
	stroke.Thickness = 2
	stroke.Transparency = 0.5
	stroke.Parent = mapButton
	
	-- Add gradient (matching other buttons)
	local gradientFrame = Instance.new("Frame")
	gradientFrame.Name = "Gradient"
	gradientFrame.Size = UDim2.new(1, 0, 1, 0)
	gradientFrame.BackgroundTransparency = 1
	gradientFrame.Parent = mapButton
	
	local gradientUI = Instance.new("UIGradient")
	gradientUI.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.9),
		NumberSequenceKeypoint.new(1, 0.9)
	}
	gradientUI.Parent = gradientFrame
	
	-- Create toggle button
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "Toggle"
	toggleButton.Size = UDim2.new(1, 0, 1, 0)
	toggleButton.BackgroundTransparency = 1
	toggleButton.Text = ""
	toggleButton.Parent = mapButton
	
	-- Create label
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "MAPA"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = mapButton
	
	-- Add layout order (place it after other buttons)
	mapButton.LayoutOrder = 5 -- Adjust as needed
	
	return mapButton
end

-- Function to setup map button functionality
local function setupMapButton()
	local mapButton = createMapButton()
	if not mapButton then return end
	
	local toggleButton = mapButton:FindFirstChild("Toggle")
	if not toggleButton then return end
	
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
	
	-- Add hover effects (matching other buttons)
	toggleButton.MouseEnter:Connect(function()
		local tween = TweenService:Create(mapButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(65, 65, 65)
		})
		tween:Play()
	end)
	
	toggleButton.MouseLeave:Connect(function()
		local tween = TweenService:Create(mapButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		})
		tween:Play()
	end)
	
	print("[MapButton] Map button setup complete")
end

-- Alternative: Add a keyboard shortcut (M key) to open the map
local function setupKeyboardShortcut()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.M then
			-- Try existing map GUI first, then fallback to global function
			if not toggleExistingMapGUI() then
				if _G.ToggleMapGUI then
					_G.ToggleMapGUI()
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
