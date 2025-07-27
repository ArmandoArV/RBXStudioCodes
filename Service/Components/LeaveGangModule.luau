local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LeaveGangModule = {}

-- ================
-- Configuration
-- ================
local REMOTE_EVENT_NAME = "GangRemoteEvent"
local DEBUG_PREFIX = "[LeaveGangModule]"

-- Get the RemoteEvent
local remoteEvent = ReplicatedStorage:WaitForChild(REMOTE_EVENT_NAME)

-- ================
-- Utility Functions
-- ================
local function debugLog(...)
	print(DEBUG_PREFIX, ...)
end

-- ================
-- Client-Side Functions
-- ================

--[[
	Requests to leave the current gang
	@param callback: Optional callback function that receives (success: boolean, data: any)
]]
function LeaveGangModule.RequestLeaveGang(callback)
	debugLog("Requesting to leave gang")
	
	local player = Players.LocalPlayer
	if not player then
		debugLog("No local player found")
		if callback then
			callback(false, "No local player found")
		end
		return
	end

	-- Check if player is in a team before making the request
	if not player.Team then
		debugLog("Player is not in any gang")
		if callback then
			callback(false, "You are not in any gang")
		end
		return
	end

	local currentGangName = player.Team.Name
	debugLog("Attempting to leave gang:", currentGangName)

	-- Set up response handlers if callback is provided
	if callback then
		local connections = {}
		
		-- Success handler
		connections.success = remoteEvent.OnClientEvent:Connect(function(action, data)
			if action == "GangLeft" then
				debugLog("Successfully left gang:", data.previousGang)
				callback(true, data)
				
				-- Clean up connections
				for _, connection in pairs(connections) do
					connection:Disconnect()
				end
			end
		end)
		
		-- Failure handler
		connections.failure = remoteEvent.OnClientEvent:Connect(function(action, data)
			if action == "GangLeaveFailed" then
				debugLog("Failed to leave gang:", data)
				callback(false, data)
				
				-- Clean up connections
				for _, connection in pairs(connections) do
					connection:Disconnect()
				end
			end
		end)
	end

	-- Send the request to server
	remoteEvent:FireServer("LeaveGang", {})
end

--[[
	Gets the current gang information for the local player
	@return table: Gang info or nil if not in a gang
]]
function LeaveGangModule.GetCurrentGang()
	local player = Players.LocalPlayer
	if not player or not player.Team then
		return nil
	end

	local team = player.Team
	local teamColor = team.TeamColor.Color
	
	return {
		name = team.Name,
		color = {
			r = teamColor.R,
			g = teamColor.G,
			b = teamColor.B
		},
		groupId = team:GetAttribute("GroupId")
	}
end

--[[
	Checks if the local player is currently in a gang
	@return boolean: True if in a gang, false otherwise
]]
function LeaveGangModule.IsInGang()
	local player = Players.LocalPlayer
	return player and player.Team ~= nil
end

-- ================
-- Server-Side Functions (for server scripts)
-- ================

--[[
	Server-side function to force a player to leave their gang
	@param player: Player instance to remove from gang
	@param gangHandler: The GangHandler instance
]]
function LeaveGangModule.ForceLeaveGang(player, gangHandler)
	debugLog("Force leaving gang for player:", player.Name)
	
	if not player or not gangHandler then
		debugLog("Invalid player or gangHandler provided")
		return false
	end

	-- Call the handler directly
	gangHandler:HandleLeaveGang(player, {})
	return true
end

--[[
	Server-side function to check if a player can leave their current gang
	@param player: Player instance to check
	@return boolean: True if player can leave, false otherwise
	@return string: Reason if cannot leave
]]
function LeaveGangModule.CanLeaveGang(player)
	if not player then
		return false, "Invalid player"
	end
	
	if not player.Team then
		return false, "Player is not in any gang"
	end
	
	-- Add any additional logic here for special conditions
	-- For example, check if player is in a protected gang, raid, etc.
	
	return true, "Can leave gang"
end

return LeaveGangModule
