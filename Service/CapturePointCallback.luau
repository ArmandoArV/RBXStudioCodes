local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScript = game:WaitForChild("ServerScriptService")
local CapturePointHandler = require(ServerScript:WaitForChild("Handler"):WaitForChild("CapturePointHandler"))
local CapturePoint = require(ReplicatedStorage:WaitForChild("Classes"):WaitForChild("CapturePoint"))

-- Example: Assume all capture point parts are in workspace.CapturePoints
local capturePointsFolder = workspace:WaitForChild("CapturePoints")

for _, part in ipairs(capturePointsFolder:GetChildren()) do
	print("[DEBUG] Found part:", part.Name, part.ClassName)
	if part:IsA("BasePart") then
		print("[DEBUG] Setting up capture logic for part:", part.Name)
		-- Create a CapturePoint object for this part
		local moneyValue = 100 -- default
		local intVal = part:FindFirstChild("MoneyPerMinute")
		if intVal and intVal:IsA("IntValue") then
			moneyValue = intVal.Value
		end
		local cp = CapturePointHandler:CreateCapturePoint(part.Name, part.Position, moneyValue)
		-- Start monitoring (original logic)
		CapturePointHandler:MonitorCapturePointPart(part, cp)
	else
		print("[DEBUG] Skipping non-BasePart:", part.Name, part.ClassName)
	end
end

-- Initial replication after all capture points are created
CapturePointHandler:ReplicateCapturePoints()
print("[DEBUG] Initial capture points replication completed")