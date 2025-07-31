-- MapSystemInit.luau
-- Initialization script to ensure the map system components load properly

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Function to check if MapTeleportEvent exists
local function waitForMapTeleportEvent()
	local event = ReplicatedStorage:WaitForChild("MapTeleportEvent", 10)
	if event then
		print("[MapSystem] MapTeleportEvent found")
		return true
	else
		warn("[MapSystem] MapTeleportEvent not found - server script may not be running")
		return false
	end
end

-- Function to check if CapturePoints folder exists
local function waitForCapturePoints()
	local folder = ReplicatedStorage:WaitForChild("CapturePoints", 10)
	if folder and #folder:GetChildren() > 0 then
		print("[MapSystem] CapturePoints folder found with", #folder:GetChildren(), "locations")
		return true
	else
		warn("[MapSystem] CapturePoints folder not found or empty")
		return false
	end
end

-- Main initialization
print("[MapSystem] Initializing map system...")

-- Wait for required components
local hasEvent = waitForMapTeleportEvent()
local hasLocations = waitForCapturePoints()

if hasEvent and hasLocations then
	print("[MapSystem] All required components found. Map system ready!")
else
	if not hasEvent then
		warn("[MapSystem] Missing MapTeleportEvent - teleportation will not work")
	end
	if not hasLocations then
		warn("[MapSystem] Missing CapturePoints - no locations available")
	end
end

-- Display available locations for debugging
task.spawn(function()
	task.wait(2) -- Wait a bit for everything to load
	local capturePoints = ReplicatedStorage:FindFirstChild("CapturePoints")
	if capturePoints then
		print("[MapSystem] Available locations:")
		for i, location in pairs(capturePoints:GetChildren()) do
			if location:IsA("Folder") then
				print("  " .. i .. ". " .. location.Name)
			end
		end
		
		-- Show instructions
		print("[MapSystem] Instructions:")
		print("  - Press M key to open map")
		print("  - Or look for the MAPA button in the gang menu")
		print("  - Click any location to teleport there")
	end
end)

print("[MapSystem] Map system initialization complete")
