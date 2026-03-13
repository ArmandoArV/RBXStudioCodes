local ServerScript = game:WaitForChild("ServerScriptService")
local Managers = ServerScript:WaitForChild("Manager")
local CapturePointTerminalManager = require(Managers:WaitForChild("CapturePointTerminalManager"))
local manager = CapturePointTerminalManager.new()

local folder = workspace:FindFirstChild("CapturePoint")
if not folder then
	warn("No folder named 'CapturePoint' found in workspace.")
	return
end

for _, part in ipairs(folder:GetChildren()) do
	if part:IsA("BasePart") then
		-- You can set mode per part, or default to Easy
		manager:AddTerminal(part.Name, part.Position, "Easy")
	end
end