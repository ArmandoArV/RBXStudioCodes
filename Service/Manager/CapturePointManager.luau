local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local ServerScript = game:WaitForChild("ServerScriptService")
local CapturePointHandler = require(ServerScript:WaitForChild("Handler"):WaitForChild("CapturePointHandler"))

local CapturePointManager = {}
CapturePointManager.CapturePoints = {}

local remoteEvent = ReplicatedStorage:WaitForChild("CapturePointEvent")

-- Detect when a player is occupying a capture point
remoteEvent.OnServerEvent:Connect(function(player, action, capturePointName, teamName)
	local team = Teams:FindFirstChild(teamName)
	if not team then
		warn("Team not found: " .. teamName)
		return
	end

	local capturePoint = CapturePointManager.CapturePoints[capturePointName]
	if not capturePoint then
		warn("Capture Point not found: " .. capturePointName)
		return
	end

	if action == "Occupy" then
		CapturePointHandler:OccupyCapturePoint(capturePoint, team, nil)
	elseif action == "Release" then
		CapturePointHandler:ReleaseCapturePoint(capturePoint)
	else
		warn("Unknown action: " .. action)
	end
end)

-- Initialize capture points
function CapturePointManager:InitializeCapturePoints()
	for _, team in pairs(Teams:GetTeams()) do
		for _, point in pairs(team:GetChildren()) do
			if point:IsA("CapturePoint") then
				CapturePointManager.CapturePoints[point.Name] = point
				print("Capture Point initialized: " .. point.Name)
			end
		end
	end
end

-- Update UI with capture point information
function CapturePointManager:UpdateCapturePointUI()
	for _, point in pairs(CapturePointManager.CapturePoints) do
		local info = CapturePointHandler:GetCapturePointInfo(point)
		remoteEvent:FireAllClients("UpdateCapturePointUI", info)
	end
end

