-- ServerScriptService/ReplicateCapturePoints.luau
-- Replicates capture point data to ReplicatedStorage for client UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScript = game:WaitForChild("ServerScriptService")
local CapturePointHandler = require(ServerScript:WaitForChild("Handler"):WaitForChild("CapturePointHandler"))

local function replicateCapturePoints()
	print("[ReplicateCapturePoints] Running replication using CapturePointHandler...")
	-- Use the new method from CapturePointHandler
	CapturePointHandler:ReplicateCapturePoints()
	print("[ReplicateCapturePoints] Replication completed")
end

return replicateCapturePoints
