-- MapTeleportServer.luau
-- Server script to handle map teleportation requests with group restrictions and spawn delays

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

-- Import GroupIds module from ServerScriptService
local GroupIds = require(ServerScriptService:WaitForChild("GroupIds"))

-- Import CapturePointHandler to check capture point ownership
local CapturePointHandler = require(ServerScriptService:WaitForChild("Handler"):WaitForChild("CapturePointHandler"))

-- Create the RemoteEvent for map teleportation
local mapTeleportEvent = ReplicatedStorage:FindFirstChild("MapTeleportEvent")
if not mapTeleportEvent then
    mapTeleportEvent = Instance.new("RemoteEvent")
    mapTeleportEvent.Name = "MapTeleportEvent"
    mapTeleportEvent.Parent = ReplicatedStorage
end

-- Create RemoteFunction for getting accessible locations
local getAccessibleLocationsFunction = ReplicatedStorage:FindFirstChild("GetAccessibleLocations")
if not getAccessibleLocationsFunction then
    getAccessibleLocationsFunction = Instance.new("RemoteFunction")
    getAccessibleLocationsFunction.Name = "GetAccessibleLocations"
    getAccessibleLocationsFunction.Parent = ReplicatedStorage
end

-- Track spawn delays per player
local playerSpawnTimes = {}
local SPAWN_DELAY = 10 -- 10 seconds

-- Function to check if player has group access
local function hasGroupAccess(player, groupData)
    if not groupData or not groupData.ID then 
        return false 
    end
    
    local groupId = groupData.ID
    
    local success, result = pcall(function()
        return player:IsInGroup(groupId)
    end)
    
    if success then
        return result
    else
        warn("[MapTeleport] Error checking group membership for", player.Name, "in group", groupId, ":", result)
        return false
    end
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

-- Function to check if a location allows anyone to access it
local function locationAllowsAnyone(locationName)
    -- Check if the location object has an "Anyone" BoolValue set to true
    local locationObject = findLocationInWorkspace(locationName)
    if locationObject then
        local anyoneValue = locationObject:FindFirstChild("Anyone")
        if anyoneValue and anyoneValue:IsA("BoolValue") and anyoneValue.Value == true then
            return true
        end
    end
    return false
end

-- Function to check if a player owns/controls a capture point
local function playerOwnsLocation(player, locationName)
    local locationObject = findLocationInWorkspace(locationName)
    if not locationObject then
        return false
    end
    
    -- First check if this is a capture point using CapturePointHandler
    local capturePoint = CapturePointHandler:FindCapturePointByName(locationName)
    if capturePoint then
        if capturePoint:IsOccupied() then
            local occupyingTeam = capturePoint.OccupyingTeam
            
            if occupyingTeam and player.Team and player.Team == occupyingTeam then
                return true
            end
        end
    end
    
    -- Check for common ownership indicators - customize these based on your capture system
    
    -- Method 1: Check for "Owner" StringValue with player name
    local ownerValue = locationObject:FindFirstChild("Owner")
    if ownerValue and ownerValue:IsA("StringValue") then
        if ownerValue.Value == player.Name then
            return true
        end
    end
    
    -- Method 2: Check for "ControlledBy" StringValue with player name
    local controlledByValue = locationObject:FindFirstChild("ControlledBy")
    if controlledByValue and controlledByValue:IsA("StringValue") then
        if controlledByValue.Value == player.Name then
            return true
        end
    end
    
    -- Method 3: Check for "OwnerUserId" IntValue with player's user ID
    local ownerUserIdValue = locationObject:FindFirstChild("OwnerUserId")
    if ownerUserIdValue and ownerUserIdValue:IsA("IntValue") then
        if ownerUserIdValue.Value == player.UserId then
            return true
        end
    end
    
    -- Method 4: Check for team-based ownership (if you use teams)
    if player.Team then
        local teamOwnerValue = locationObject:FindFirstChild("OwningTeam")
        if teamOwnerValue and teamOwnerValue:IsA("StringValue") then
            if teamOwnerValue.Value == player.Team.Name then
                return true
            end
        end
    end
    
    -- Method 5: Check for group-based ownership
    local owningGroupValue = locationObject:FindFirstChild("OwningGroup")
    if owningGroupValue and owningGroupValue:IsA("IntValue") then
        local success, result = pcall(function()
            return player:IsInGroup(owningGroupValue.Value)
        end)
        if success and result then
            return true
        end
    end
    
    return false
end

-- Function to check if a location is group-restricted and get all possible group data
local function getLocationGroupRestrictions(locationName)
    local restrictions = {}
    
    for groupName, groupInfo in pairs(GroupIds) do
        -- Check MAIN group
        if groupInfo.MAIN then
            local mainLocationName = groupName .. "_MAIN"
            local mainSpawnLocation = groupInfo.MAIN.SPAWN_LOCATION
            
            -- Check both the constructed name and the actual spawn location
            if mainLocationName == locationName or mainSpawnLocation == locationName then
                table.insert(restrictions, {
                    groupData = groupInfo.MAIN,
                    groupName = groupName,
                    subGroupName = "MAIN"
                })
            end
        end
        
        -- Check sub-groups
        for subGroupName, subGroupData in pairs(groupInfo) do
            if subGroupName ~= "MAIN" and type(subGroupData) == "table" and subGroupData.ID then
                local subLocationName = groupName .. "_" .. subGroupName
                local subSpawnLocation = subGroupData.SPAWN_LOCATION
                
                -- Check both the constructed name and the actual spawn location
                if subLocationName == locationName or subSpawnLocation == locationName then
                    table.insert(restrictions, {
                        groupData = subGroupData,
                        groupName = groupName,
                        subGroupName = subGroupName
                    })
                end
            end
        end
    end
    
    return restrictions
end

-- Function to check if player can access a specific location
local function canPlayerAccessLocation(player, locationName)
    -- First check if location allows anyone to access it
    if locationAllowsAnyone(locationName) then
        return true, nil
    end
    
    -- Check if player owns/controls this location
    if playerOwnsLocation(player, locationName) then
        return true, nil
    end
    
    local restrictions = getLocationGroupRestrictions(locationName)
    
    if #restrictions > 0 then
        -- This is a group-restricted location, check if player has access to ANY of the required groups
        for i, restriction in pairs(restrictions) do
            if hasGroupAccess(player, restriction.groupData) then
                return true, restriction.groupData
            end
        end
        
        return false, nil -- Player doesn't have access to any of the required groups
    else
        -- This is a capture point that the player doesn't own and has no group restrictions
        return false, nil
    end
end

-- Function to check spawn delay
local function canPlayerSpawn(player)
    local userId = player.UserId
    local currentTime = tick()
    local lastSpawnTime = playerSpawnTimes[userId] or 0
    local timeLeft = SPAWN_DELAY - (currentTime - lastSpawnTime)
    
    if timeLeft > 0 then
        return false, timeLeft
    end
    
    return true, 0
end

-- Function to get spawn position from a location object
local function getSpawnPosition(locationObject)
    if locationObject:IsA("BasePart") then
        local position = locationObject.Position
        return position + Vector3.new(0, locationObject.Size.Y/2 + 5, 0)
    elseif locationObject:IsA("Model") then
        if locationObject.PrimaryPart then
            local position = locationObject.PrimaryPart.Position
            return position + Vector3.new(0, locationObject.PrimaryPart.Size.Y/2 + 5, 0)
        else
            for _, child in pairs(locationObject:GetChildren()) do
                if child:IsA("BasePart") then
                    local position = child.Position
                    return position + Vector3.new(0, child.Size.Y/2 + 5, 0)
                end
            end
        end
    elseif locationObject:IsA("SpawnLocation") then
        local position = locationObject.Position
        return position + Vector3.new(0, locationObject.Size.Y/2 + 1, 0)
    end
    
    if locationObject.Position then
        return locationObject.Position + Vector3.new(0, 5, 0)
    end
    
    return nil
end

-- Function to get all accessible spawn points for a player (called by client)
local function getAccessibleSpawnPointsForPlayer(player)
    local accessibleSpawns = {}
    
    -- Add group-restricted locations that the player has access to
    for groupName, groupInfo in pairs(GroupIds) do
        -- Check MAIN group access
        if groupInfo.MAIN and hasGroupAccess(player, groupInfo.MAIN) then
            local spawn = {
                name = groupName .. "_MAIN",
                displayName = groupName .. " Base",
                locationName = groupInfo.MAIN.SPAWN_LOCATION or (groupName .. "_MAIN"),
                isGroupRestricted = true,
                teamColor = groupInfo.MAIN.TEAM
            }
            table.insert(accessibleSpawns, spawn)
        end
        
        -- Check sub-groups
        for subGroupName, subGroupData in pairs(groupInfo) do
            if subGroupName ~= "MAIN" and type(subGroupData) == "table" and subGroupData.ID then
                if hasGroupAccess(player, subGroupData) then
                    local spawn = {
                        name = groupName .. "_" .. subGroupName,
                        displayName = groupName .. " " .. subGroupName,
                        locationName = subGroupData.SPAWN_LOCATION or (groupName .. "_" .. subGroupName),
                        isGroupRestricted = true,
                        teamColor = subGroupData.TEAM or groupInfo.MAIN.TEAM -- Use subgroup team or fallback to main group team
                    }
                    table.insert(accessibleSpawns, spawn)
                end
            end
        end
    end
    
    -- Add all accessible locations (group-restricted with access, locations with "Anyone" flag, etc.)
    local publicLocations = {}
    
    -- Check workspace.ubicaciones for locations with "Anyone" flag or no restrictions
    local ubicacionesFolder = workspace:FindFirstChild("ubicaciones")
    if ubicacionesFolder then
        for _, locationObject in pairs(ubicacionesFolder:GetChildren()) do
            local locationName = locationObject.Name
            local restrictions = getLocationGroupRestrictions(locationName)
            local isRestricted = #restrictions > 0
            local allowsAnyone = locationAllowsAnyone(locationName)
            
            if allowsAnyone or not isRestricted then
                -- Get team color if this location has group restrictions
                local teamColor = nil
                if #restrictions > 0 then
                    -- Use the first restriction's team color
                    teamColor = restrictions[1].groupData.TEAM
                end
                
                local publicLoc = {
                    name = locationName,
                    displayName = locationName,
                    locationName = locationName,
                    isGroupRestricted = false,
                    teamColor = teamColor,
                    allowsAnyone = allowsAnyone
                }
                table.insert(publicLocations, publicLoc)
            end
        end
    end
    
    -- Check workspace.CapturePoints for locations with "Anyone" flag, no restrictions, or player ownership
    local capturePointsFolder = workspace:FindFirstChild("CapturePoints")
    if capturePointsFolder then
        for _, locationObject in pairs(capturePointsFolder:GetChildren()) do
            local locationName = locationObject.Name
            local restrictions = getLocationGroupRestrictions(locationName)
            local isRestricted = #restrictions > 0
            local allowsAnyone = locationAllowsAnyone(locationName)
            local playerOwns = playerOwnsLocation(player, locationName)
            
            if allowsAnyone or not isRestricted or playerOwns then
                -- Check if we haven't already added this location
                local alreadyAdded = false
                for _, publicLoc in pairs(publicLocations) do
                    if publicLoc.name == locationName then
                        alreadyAdded = true
                        break
                    end
                end
                
                if not alreadyAdded then
                    -- Get team color if this location has group restrictions or is owned
                    local teamColor = nil
                    if #restrictions > 0 then
                        -- Use the first restriction's team color
                        teamColor = restrictions[1].groupData.TEAM
                    elseif playerOwns and player.Team then
                        -- If player owns it and has a team, use player's team color
                        teamColor = player.Team.Name
                    end
                    
                    local publicLoc = {
                        name = locationName,
                        displayName = locationName,
                        locationName = locationName,
                        isGroupRestricted = false,
                        teamColor = teamColor,
                        allowsAnyone = allowsAnyone,
                        playerOwns = playerOwns
                    }
                    table.insert(publicLocations, publicLoc)
                end
            end
        end
    end
    
    -- Add public locations to accessible spawns
    for _, publicLocation in pairs(publicLocations) do
        table.insert(accessibleSpawns, publicLocation)
    end
    
    return accessibleSpawns
end

-- Function to teleport player to location
local function teleportPlayer(player, locationName)
    -- Check spawn delay
    local canSpawn, timeLeft = canPlayerSpawn(player)
    if not canSpawn then
        return false, "Spawn cooldown active. Wait " .. math.ceil(timeLeft) .. " seconds."
    end
    
    -- Check group access
    local hasAccess, groupData = canPlayerAccessLocation(player, locationName)
    if not hasAccess then
        return false, "You don't have access to this location."
    end
    
    -- Check if player has a character
    local character = player.Character
    if not character then
        return false, "Character not found."
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return false, "HumanoidRootPart not found."
    end
    
    -- Find the location
    local locationObject = findLocationInWorkspace(locationName)
    if not locationObject then
        return false, "Location not found: " .. locationName
    end
    
    -- Get spawn position
    local spawnPosition = getSpawnPosition(locationObject)
    if not spawnPosition then
        return false, "Could not determine spawn position."
    end
    
    -- Update spawn time
    playerSpawnTimes[player.UserId] = tick()
    
    -- Teleport the player
    humanoidRootPart.CFrame = CFrame.new(spawnPosition)
    print("[MapTeleport] Teleported " .. player.Name .. " to " .. locationName .. " at " .. tostring(spawnPosition))
    
    return true, "Successfully teleported to " .. locationName
end

-- Handle teleportation requests from clients
mapTeleportEvent.OnServerEvent:Connect(function(player, locationName)
    -- Validate input
    if not locationName or type(locationName) ~= "string" then
        warn("[MapTeleport] Invalid location name from " .. player.Name)
        mapTeleportEvent:FireClient(player, false, "Invalid location name")
        return
    end
    
    -- Attempt teleportation
    local success, message = teleportPlayer(player, locationName)
    
    -- Send response back to client
    mapTeleportEvent:FireClient(player, success, message)
    
    if success then
        print("[MapTeleport] Successfully teleported " .. player.Name .. " to " .. locationName)
    else
        warn("[MapTeleport] Failed to teleport " .. player.Name .. " to " .. locationName .. ": " .. message)
    end
end)

-- Clean up spawn times when player leaves
Players.PlayerRemoving:Connect(function(player)
    playerSpawnTimes[player.UserId] = nil
end)

-- Handle requests for accessible locations from clients
getAccessibleLocationsFunction.OnServerInvoke = function(player)
    local success, result = pcall(function()
        return getAccessibleSpawnPointsForPlayer(player)
    end)
    
    if success then
        return result
    else
        warn("[MapTeleport] Error getting accessible locations for " .. player.Name .. ": " .. tostring(result))
        return {}
    end
end

print("[MapTeleport] Map teleportation server with group restrictions loaded successfully!")