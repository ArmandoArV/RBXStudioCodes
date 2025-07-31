-- MapGUI.luau
-- Client-side script to connect existing map GUI ImageButtons to teleportation system

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for the map teleport event from ReplicatedStorage
local mapTeleportEvent = ReplicatedStorage:WaitForChild("MapTeleportEvent")

-- Find your existing Map GUI structure: Map(Gui)->Background(Frame)->Map(Img)->Ubication buttons
local function findMapGUI()
	local mapGui = playerGui:WaitForChild("Map") -- Your Map ScreenGui
	local background = mapGui:WaitForChild("Background") -- Your Background Frame  
	local mapImg = background:WaitForChild("Map") -- Your Map ImageLabel
	
	return mapGui, background, mapImg
end

-- Function to setup teleportation for existing location buttons
local function setupLocationButtons()
	local mapGui, background, mapImg = findMapGUI()
	
	-- Find all location ImageButtons (Ubication1, Ubication2, etc.)
	for _, child in pairs(mapImg:GetChildren()) do
		if child:IsA("ImageButton") then
			-- Extract location name from button name 
			local locationName = child.Name
			
			print("[MapGUI] Found location button:", locationName)
			
			-- Connect click event to teleportation
			child.MouseButton1Click:Connect(function()
				print("[MapGUI] Teleporting to:", locationName)
				
				-- Check if location exists in capture points
				local capturePointsFolder = ReplicatedStorage:FindFirstChild("CapturePoints")
				if capturePointsFolder and capturePointsFolder:FindFirstChild(locationName) then
					-- Fire server event for teleportation
					mapTeleportEvent:FireServer(locationName)
				else
					-- Try with workspace.ubicaciones if it exists
					local ubicacionesFolder = workspace:FindFirstChild("ubicaciones")
					if ubicacionesFolder and ubicacionesFolder:FindFirstChild(locationName) then
						mapTeleportEvent:FireServer(locationName)
					else
						warn("[MapGUI] Location not found:", locationName)
					end
				end
			end)
		end
	end
end

-- Function to toggle your existing map GUI visibility
local function toggleMapGui()
	local mapGui, background, mapImg = findMapGUI()
	
	-- Toggle visibility of your map GUI
	mapGui.Enabled = not mapGui.Enabled
	
	print("[MapGUI] Map GUI toggled. Visible:", mapGui.Enabled)
end

-- Listen for server response to hide UI after successful teleport
mapTeleportEvent.OnClientEvent:Connect(function(success)
	if success then
		-- Hide your map GUI after successful teleport
		local mapGui, background, mapImg = findMapGUI()
		mapGui.Enabled = false
		print("[MapGUI] Map closed after successful teleportation")
	end
end)

-- Setup the system when everything is loaded
task.spawn(function()
	-- Wait a bit for the GUI to be fully loaded
	task.wait(1)
	
	local success, error = pcall(setupLocationButtons)
	if success then
		print("[MapGUI] Successfully connected", "location buttons to teleportation system")
	else
		warn("[MapGUI] Error setting up location buttons:", error)
		warn("[MapGUI] Make sure your GUI structure is: Map(Gui)->Background(Frame)->Map(Img)->LocationButtons")
	end
end)

-- Make toggle function globally accessible
_G.ToggleMapGUI = toggleMapGui

print("[MapGUI] Map GUI integration system loaded successfully!")
