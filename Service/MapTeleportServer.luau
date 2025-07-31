-- MapTeleportServer.luau
-- Server script to handle map teleportation requests

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")

-- Create the RemoteEvent for map teleportation
local mapTeleportEvent = ReplicatedStorage:FindFirstChild("MapTeleportEvent")
if not mapTeleportEvent then
	mapTeleportEvent = Instance.new("RemoteEvent")
	mapTeleportEvent.Name = "MapTeleportEvent"
	mapTeleportEvent.Parent = ReplicatedStorage
end

-- Function to find a location in workspace
local function findLocationInWorkspace(locationName)
	-- First, try to find it in workspace.ubicaciones if it exists
	local ubicacionesFolder = workspace:FindFirstChild("ubicaciones")
	if ubicacionesFolder then
		local location = ubicacionesFolder:FindFirstChild(locationName)
		if location then
			return location
		end
	end
	
	-- Then try workspace.CapturePoints
	local capturePointsFolder = workspace:FindFirstChild("CapturePoints")
	if capturePointsFolder then
		local location = capturePointsFolder:FindFirstChild(locationName)
		if location then
			return location
		end
	end
	
	-- Finally, try searching directly in workspace
	local location = workspace:FindFirstChild(locationName)
	if location then
		return location
	end
	
	return nil
end

-- Function to get spawn position from a location object
local function getSpawnPosition(locationObject)
	if locationObject:IsA("BasePart") then
		-- If it's a part, spawn above it
		local position = locationObject.Position
		return position + Vector3.new(0, locationObject.Size.Y/2 + 5, 0)
	elseif locationObject:IsA("Model") then
		-- If it's a model, try to use PrimaryPart or find a suitable part
		if locationObject.PrimaryPart then
			local position = locationObject.PrimaryPart.Position
			return position + Vector3.new(0, locationObject.PrimaryPart.Size.Y/2 + 5, 0)
		else
			-- Find the first BasePart in the model
			for _, child in pairs(locationObject:GetChildren()) do
				if child:IsA("BasePart") then
					local position = child.Position
					return position + Vector3.new(0, child.Size.Y/2 + 5, 0)
				end
			end
		end
	elseif locationObject:IsA("SpawnLocation") then
		-- If it's a spawn location, use its position
		local position = locationObject.Position
		return position + Vector3.new(0, locationObject.Size.Y/2 + 1, 0)
	end
	
	-- Fallback: try to get position property
	if locationObject.Position then
		return locationObject.Position + Vector3.new(0, 5, 0)
	end
	
	return nil
end

-- Function to teleport player to location
local function teleportPlayer(player, locationName)
	-- Check if player has a character
	local character = player.Character
	if not character then
		warn("[MapTeleport] Player " .. player.Name .. " has no character")
		return false
	end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		warn("[MapTeleport] Player " .. player.Name .. " has no HumanoidRootPart")
		return false
	end
	
	-- Find the location
	local locationObject = findLocationInWorkspace(locationName)
	if not locationObject then
		warn("[MapTeleport] Location not found: " .. locationName)
		return false
	end
	
	-- Get spawn position
	local spawnPosition = getSpawnPosition(locationObject)
	if not spawnPosition then
		warn("[MapTeleport] Could not determine spawn position for: " .. locationName)
		return false
	end
	
	-- Teleport the player
	humanoidRootPart.CFrame = CFrame.new(spawnPosition)
	print("[MapTeleport] Teleported " .. player.Name .. " to " .. locationName .. " at " .. tostring(spawnPosition))
	
	return true
end

-- Handle teleportation requests from clients
mapTeleportEvent.OnServerEvent:Connect(function(player, locationName)
	print("[MapTeleport] Received teleport request from " .. player.Name .. " to " .. locationName)
	
	-- Validate input
	if not locationName or type(locationName) ~= "string" then
		warn("[MapTeleport] Invalid location name from " .. player.Name)
		mapTeleportEvent:FireClient(player, false)
		return
	end
	
	-- Attempt teleportation
	local success = teleportPlayer(player, locationName)
	
	-- Send response back to client
	mapTeleportEvent:FireClient(player, success)
	
	if success then
		print("[MapTeleport] Successfully teleported " .. player.Name .. " to " .. locationName)
	else
		warn("[MapTeleport] Failed to teleport " .. player.Name .. " to " .. locationName)
	end
end)

print("[MapTeleport] Map teleportation server loaded successfully!")
