--[[
	
	Made by: Sr_IP
	Date: 13/08/2022
	
	re-organized by stevie
	05/07/2023 (julio)
	
	re-re-organized by Sr_IP
	18/07/2023 
	
	re-re-re-organized by stevie
	10/12/2023
	
	Enhanced and optimized by GitHub Copilot
	08/03/2025 - Added ToolCloner integration and performance improvements
	
	ENHANCEMENTS:
	- Integrated ToolCloner module for efficient tool management
	- Restructured code with better organization and modularity
	- Added comprehensive error handling with pcall protection
	- Implemented configuration-based equipment system
	- Added utility functions for batch operations
	- Improved performance with task.wait instead of deprecated wait
	- Better memory management with proper tool cleanup
	- Enhanced debugging with descriptive warnings
	- Modular design for easier maintenance and expansion

]] --

-- Services
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ToolCloner = require(script.Parent.Components.ToolCloner)
local GroupIds = require(ServerScriptService.GroupIds)

-- Equipment folders
local Equipment = ServerStorage.Equipment

-- Configuration flags
local Config = {
    DEBUG_MODE = true, -- Set to true for detailed logging
    CLEAR_TOOLS_ON_SPAWN = false, -- Set to true to clear existing tools before assigning new ones
    USE_REPLICATED_TOOLS = true -- Set to true to prefer tools from ReplicatedStorage when available
}

-- Equipment Configuration
local EquipmentConfig = {
    EM = {
        groups = {},
        equipment = {}
    },
    MARINA = {
        groups = {},
        equipment = {}
    },
    FAM = {
        groups = {},
        equipment = {}
    },
    PFP = {
        groups = {},
        equipment = {}
    },
    PM = {
        groups = {},
        equipment = {}
    },
    FGR = {
        groups = {},
        equipment = {}
    }
}

-- Enhanced cloning function with better error handling
local function cloneToolsFromFolder(player, folder)
    if Config.DEBUG_MODE then
        print("DEBUG: cloneToolsFromFolder called for player:", player.Name)
        print("DEBUG: Folder:", folder and folder.Name or "nil")
    end
    
    if not folder or not folder.Parent then
        warn("Invalid folder provided for player: " .. player.Name)
        return
    end
    
    local toolsCloned = 0
    for _, object in pairs(folder:GetDescendants()) do
        if object:IsA("Tool") then
            if Config.DEBUG_MODE then
                print("DEBUG: Found tool:", object.Name, "in folder:", folder.Name)
            end
            
            -- Remove existing tool if present to avoid duplicates
            local existingTool = player.Backpack:FindFirstChild(object.Name)
            if existingTool then
                if Config.DEBUG_MODE then
                    print("DEBUG: Removing existing tool:", object.Name)
                end
                existingTool:Destroy()
            end
            
            -- Clone and parent the tool
            local clone = object:Clone()
            clone.Parent = player.Backpack
            toolsCloned = toolsCloned + 1
            
            if Config.DEBUG_MODE then
                print("DEBUG: Successfully cloned tool:", object.Name)
            end
        end
    end
    
    if Config.DEBUG_MODE then
        print("DEBUG: Total tools cloned from folder", folder.Name .. ":", toolsCloned)
    end
end

-- Enhanced tool cloning function using ToolCloner module for specific tools
local function cloneSpecificTool(player, toolName)
    local tool = ToolCloner.CloneTool(toolName)
    if tool then
        -- Remove existing tool if present
        local existingTool = player.Backpack:FindFirstChild(toolName)
        if existingTool then
            existingTool:Destroy()
        end
        
        tool.Parent = player.Backpack
        return true
    else
        warn("Tool not found in ReplicatedStorage.Tools: " .. toolName)
        return false
    end
end

-- Batch clone multiple specific tools for efficiency
local function cloneSpecificTools(player, toolNames)
    local successCount = 0
    for _, toolName in ipairs(toolNames) do
        if cloneSpecificTool(player, toolName) then
            successCount = successCount + 1
        end
    end
    return successCount
end

-- Equipment assignment based on group membership and team
local function assignEquipment(player, groupId, equipmentFolder, teamRequirement)
    if Config.DEBUG_MODE then
        print("DEBUG: assignEquipment called for player:", player.Name)
        print("DEBUG: GroupId:", groupId)
        print("DEBUG: Equipment folder:", equipmentFolder and equipmentFolder.Name or "nil")
        print("DEBUG: Team requirement:", teamRequirement or "none")
        print("DEBUG: Player's current team:", player.Team and player.Team.Name or "no team")
    end
    
    if not player:IsInGroup(groupId) then
        if Config.DEBUG_MODE then
            print("DEBUG: Player", player.Name, "is NOT in group", groupId)
        end
        return false
    end
    
    if Config.DEBUG_MODE then
        print("DEBUG: Player", player.Name, "IS in group", groupId)
    end
    
    if teamRequirement and player.Team and player.Team.Name ~= teamRequirement then
        if Config.DEBUG_MODE then
            print("DEBUG: Team requirement not met. Required:", teamRequirement, "Actual:", player.Team.Name)
        end
        return false
    end
    
    if Config.DEBUG_MODE then
        print("DEBUG: All requirements met, proceeding to clone tools")
    end
    
    cloneToolsFromFolder(player, equipmentFolder)
    return true
end

-- Utility function to clear all tools from player backpack
local function clearPlayerTools(player)
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool:Destroy()
        end
    end
end

-- Initialize equipment configuration
local function initializeEquipment()
    if Config.DEBUG_MODE then
        print("DEBUG: Initializing equipment configuration...")
    end
    
    -- Load group configurations
    EquipmentConfig.EM.groups = GroupIds.EM
    EquipmentConfig.MARINA.groups = GroupIds.MARINA
    EquipmentConfig.FAM.groups = GroupIds.FAM
    EquipmentConfig.PFP.groups = GroupIds.GN
    EquipmentConfig.PM.groups = GroupIds.PM
    EquipmentConfig.FGR.groups = GroupIds.FGR or {} -- Handle missing FGR gracefully
    
    if Config.DEBUG_MODE then
        print("DEBUG: Group configurations loaded")
        print("DEBUG: Available groups:")
        for faction, config in pairs(EquipmentConfig) do
            print("  " .. faction .. ":", config.groups)
        end
    end
    
    -- Load equipment folders
    local EM = Equipment.EJMEX
    EquipmentConfig.EM.equipment = {
        main = EM.Main,
        gafe = EM.GAFE,
        nitro = EM.NITRO
    }
    
    local PFP = Equipment.PFP
    EquipmentConfig.PFP.equipment = {
        main = PFP.Main,
        gendarmeria = PFP.Gendarmeria,
        transito = PFP.Transito
    }
    
    local MAR = Equipment.MARINA
    EquipmentConfig.MARINA.equipment = {
        main = MAR.Main,
        unopes = MAR.UNOPES,
        pn = MAR.PN,
        fan = MAR.FAN
    }
    
    local FAM = Equipment.FAM
    EquipmentConfig.FAM.equipment = {
        main = FAM.Main,
        bfp = FAM.BFP
    }
    
    local FGR = Equipment:FindFirstChild("FGR")
    if FGR then
        EquipmentConfig.FGR.equipment = {
            main = FGR.MAIN
        }
    else
        EquipmentConfig.FGR.equipment = {}
        if Config.DEBUG_MODE then
            print("DEBUG: FGR equipment folder not found in ServerStorage.Equipment")
        end
    end
    
    local PM = Equipment.PM
    EquipmentConfig.PM.equipment = {
        main = PM.Main
    }
    
    if Config.DEBUG_MODE then
        print("DEBUG: Equipment folders loaded")
        print("DEBUG: Equipment configuration complete")
    end
end

-- Optimized player spawning function with improved organization
local function onPlayerSpawned(player)
    -- Small delay to ensure player is fully loaded
    task.wait(0.01)
    
    -- Validate player
    if not player or not player.Parent then
        if Config.DEBUG_MODE then
            warn("Invalid player provided to onPlayerSpawned")
        end
        return
    end
    
    -- Clear existing tools if configured
    if Config.CLEAR_TOOLS_ON_SPAWN then
        clearPlayerTools(player)
    end
    
    if Config.DEBUG_MODE then
        print("Assigning equipment for player: " .. player.Name)
    end
    
    -- EJERCITO (EM)
    assignEquipment(player, EquipmentConfig.EM.groups.MAIN.ID, EquipmentConfig.EM.equipment.main)
    
    -- Uncommented specialized EM equipment for future use
    -- assignEquipment(player, EquipmentConfig.EM.groups.GAFE.ID, EquipmentConfig.EM.equipment.gafe)
    -- assignEquipment(player, EquipmentConfig.EM.groups.NITRO.ID, EquipmentConfig.EM.equipment.nitro)
    
    -- MARINA
    assignEquipment(player, EquipmentConfig.MARINA.groups.MAIN.ID, EquipmentConfig.MARINA.equipment.main)
    assignEquipment(player, EquipmentConfig.MARINA.groups.UNOPES.ID, EquipmentConfig.MARINA.equipment.unopes)
    assignEquipment(player, EquipmentConfig.MARINA.groups.FES.ID, EquipmentConfig.MARINA.equipment.unopes)
    assignEquipment(player, EquipmentConfig.MARINA.groups.PN.ID, EquipmentConfig.MARINA.equipment.pn, "MARINA")
    
    -- FAM (Fuerza Aérea Mexicana)
    assignEquipment(player, EquipmentConfig.FAM.groups.MAIN.ID, EquipmentConfig.FAM.equipment.main)
    assignEquipment(player, EquipmentConfig.FAM.groups.BFP.ID, EquipmentConfig.FAM.equipment.bfp)
    
    -- PFP/GN (Guardia Nacional)
    assignEquipment(player, EquipmentConfig.PFP.groups.MAIN.ID, EquipmentConfig.PFP.equipment.main, "GN")
    assignEquipment(player, EquipmentConfig.PFP.groups.TRANSITO.ID, EquipmentConfig.PFP.equipment.transito)
    assignEquipment(player, EquipmentConfig.PFP.groups.GENDARMERIA.ID, EquipmentConfig.PFP.equipment.gendarmeria)
    
    -- PM (Policía Militar)
    assignEquipment(player, EquipmentConfig.PM.groups.MAIN.ID, EquipmentConfig.PM.equipment.main, "PM")
    
    -- FGR (Fiscalía General de la República)
    if EquipmentConfig.FGR.groups.MAIN then
        assignEquipment(player, EquipmentConfig.FGR.groups.MAIN.ID, EquipmentConfig.FGR.equipment.main)
    elseif Config.DEBUG_MODE then
        print("DEBUG: FGR.MAIN group not configured, skipping FGR equipment assignment")
    end
    
    if Config.DEBUG_MODE then
        print("Equipment assignment completed for player: " .. player.Name)
    end
end

-- Debug function to manually test equipment assignment for a player
local function debugPlayerEquipment(playerName)
    local player = Players:FindFirstChild(playerName)
    if not player then
        warn("DEBUG: Player not found:", playerName)
        return
    end
    
    print("DEBUG: Manual equipment test for player:", playerName)
    print("DEBUG: Player groups:")
    
    -- Check all group memberships
    for faction, config in pairs(EquipmentConfig) do
        if config.groups then
            for groupType, groupData in pairs(config.groups) do
                if groupData and groupData.ID then
                    if player:IsInGroup(groupData.ID) then
                        print("  ✅ " .. faction .. " " .. groupType .. " (ID: " .. groupData.ID .. ")")
                    else
                        print("  ❌ " .. faction .. " " .. groupType .. " (ID: " .. groupData.ID .. ")")
                    end
                end
            end
        else
            print("  ⚠️ " .. faction .. ": No group configuration")
        end
    end
    
    print("DEBUG: Player team:", player.Team and player.Team.Name or "No team")
    print("DEBUG: Current backpack tools:")
    local toolCount = 0
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            print("  - " .. tool.Name)
            toolCount = toolCount + 1
        end
    end
    print("DEBUG: Total tools in backpack:", toolCount)
    
    -- Force equipment assignment
    print("DEBUG: Forcing equipment assignment...")
    onPlayerSpawned(player)
end

-- Comprehensive system status check
local function debugSystemStatus()
    print("=== TOOL CLONER SYSTEM STATUS ===")
    print("Debug Mode:", Config.DEBUG_MODE)
    print("Clear Tools on Spawn:", Config.CLEAR_TOOLS_ON_SPAWN)
    print("Use Replicated Tools:", Config.USE_REPLICATED_TOOLS)
    
    print("\n=== EQUIPMENT CONFIGURATION ===")
    for faction, config in pairs(EquipmentConfig) do
        print(faction .. ":")
        print("  Groups:", config.groups and "✅ Configured" or "❌ Missing")
        print("  Equipment:", config.equipment and "✅ Configured" or "❌ Missing")
    end
    
    print("\n=== REPLICATED STORAGE TOOLS ===")
    local availableTools = ToolCloner.GetAvailableTools()
    print("Total tools available:", #availableTools)
    for i, toolName in ipairs(availableTools) do
        if i <= 10 then -- Show first 10 tools
            print("  -", toolName)
        elseif i == 11 then
            print("  ... and", #availableTools - 10, "more tools")
            break
        end
    end
end

-- Expose debug functions globally for testing
_G.DebugPlayerEquipment = debugPlayerEquipment
_G.DebugSystemStatus = debugSystemStatus

-- Initialize the equipment system
if Config.DEBUG_MODE then
    print("DEBUG: Starting ToolClonerCallback initialization...")
    -- Enable debug mode in ToolCloner module
    ToolCloner.SetDebugMode(true)
end

initializeEquipment()

if Config.DEBUG_MODE then
    print("DEBUG: ToolClonerCallback initialized successfully")
    print("DEBUG: Available tools in ReplicatedStorage.Tools:")
    local availableTools = ToolCloner.GetAvailableTools()
    for _, toolName in ipairs(availableTools) do
        print("  -", toolName)
    end
end

-- Connect player events with error handling
Players.PlayerAdded:Connect(function(player)
    if Config.DEBUG_MODE then
        print("DEBUG: Player added:", player.Name)
    end
    
    player.CharacterAdded:Connect(function()
        if Config.DEBUG_MODE then
            print("DEBUG: Character added for player:", player.Name)
        end
        
        -- Use pcall for error handling
        local success, error = pcall(onPlayerSpawned, player)
        if not success then
            warn("Error in onPlayerSpawned for player " .. player.Name .. ": " .. tostring(error))
        end
    end)
end)

-- Handle players already in game
for _, player in pairs(Players:GetPlayers()) do
    if Config.DEBUG_MODE then
        print("DEBUG: Processing existing player:", player.Name)
    end
    
    if player.Character then
        local success, error = pcall(onPlayerSpawned, player)
        if not success then
            warn("Error in onPlayerSpawned for existing player " .. player.Name .. ": " .. tostring(error))
        end
    end
    
    player.CharacterAdded:Connect(function()
        if Config.DEBUG_MODE then
            print("DEBUG: Character added for existing player:", player.Name)
        end
        
        local success, error = pcall(onPlayerSpawned, player)
        if not success then
            warn("Error in onPlayerSpawned for existing player " .. player.Name .. ": " .. tostring(error))
        end
    end)
end
