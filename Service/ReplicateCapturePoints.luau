-- ServerScriptService/ReplicateCapturePoints.luau
-- Replicates capture point data to ReplicatedStorage for client UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScript = game:WaitForChild("ServerScriptService")
local CapturePointHandler = require(ServerScript:WaitForChild("Handler"):WaitForChild("CapturePointHandler"))

local function replicateCapturePoints()
	print("[ReplicateCapturePoints] Running replication...")
	local folder = ReplicatedStorage:FindFirstChild("CapturePoints")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "CapturePoints"
		folder.Parent = ReplicatedStorage
		print("[ReplicateCapturePoints] Created CapturePoints folder in ReplicatedStorage")
	end
	-- Clear old
	for _, v in ipairs(folder:GetChildren()) do v:Destroy() end

	local capturePoints = CapturePointHandler:GetAllCapturePoints()
	print("[ReplicateCapturePoints] Found", #capturePoints, "capture points")
	for _, cp in ipairs(capturePoints) do
		local info = cp:GetInfo()
		print("[ReplicateCapturePoints] Replicating:", info.Name, info.Location, info.Occupied, info.OccupyingTeam)
		local cpValue = Instance.new("Folder")
		cpValue.Name = info.Name
		cpValue.Parent = folder
		local loc = Instance.new("StringValue")
		loc.Name = "Location"
		loc.Value = tostring(info.Location)
		loc.Parent = cpValue
		local occupied = Instance.new("BoolValue")
		occupied.Name = "Occupied"
		occupied.Value = info.Occupied
		occupied.Parent = cpValue
		local team = Instance.new("StringValue")
		team.Name = "Team"
		team.Value = info.OccupyingTeam or "None"
		team.Parent = cpValue
	end
end


return replicateCapturePoints
