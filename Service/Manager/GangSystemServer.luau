local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local HttpService = game:GetService("HttpService")

-- Create RemoteEvent if it doesn't exist
local GangRemoteEvent = ReplicatedStorage:FindFirstChild("GangRemoteEvent") or Instance.new("RemoteEvent")
GangRemoteEvent.Name = "GangRemoteEvent"
GangRemoteEvent.Parent = ReplicatedStorage

-- Gang creation handler
GangRemoteEvent.OnServerEvent:Connect(function(player, action, data)
	if action ~= "CreateGang" then
		return
	end

	print("[Server] Gang creation request from:", player.Name)

	-- Validate request
	if not data or typeof(data) ~= "table" then
		GangRemoteEvent:FireClient(player, "GangCreateFailed", "Invalid data: not a table")
		return
	end

	if type(data.name) ~= "string" or #data.name < 2 then
		GangRemoteEvent:FireClient(player, "GangCreateFailed", "Gang name must be at least 2 characters")
		return
	end

	if type(data.groupId) ~= "number" then
		GangRemoteEvent:FireClient(player, "GangCreateFailed", "Invalid groupId")
		return
	end

	if not data.color or type(data.color) ~= "table" then
		GangRemoteEvent:FireClient(player, "GangCreateFailed", "Invalid color data")
		return
	end

	local r, g, b = data.color.r, data.color.g, data.color.b
	if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
		GangRemoteEvent:FireClient(player, "GangCreateFailed", "Invalid color components")
		return
	end

	-- Check if gang exists
	if Teams:FindFirstChild(data.name) then
		GangRemoteEvent:FireClient(player, "GangCreateFailed", "Gang name already exists")
		return
	end

	-- Create new Team
	local newTeam = Instance.new("Team")
	newTeam.Name = data.name
	newTeam.TeamColor = BrickColor.new(Color3.new(r, g, b))
	newTeam.Parent = Teams

	player.Team = newTeam

	-- Send success to client
	GangRemoteEvent:FireClient(player, "GangCreated", {
		name = data.name,
		groupId = data.groupId,
		color = {
			r = newTeam.TeamColor.Color.R,
			g = newTeam.TeamColor.Color.G,
			b = newTeam.TeamColor.Color.B
		}
	})

	print(string.format("[Server] Gang '%s' created for %s (Color: %s)", data.name, player.Name, newTeam.TeamColor.Name))
end)

print("GangSystemServer initialized")
