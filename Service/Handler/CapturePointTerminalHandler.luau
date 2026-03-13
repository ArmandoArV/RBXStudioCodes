-- CapturePointTerminalHandler.luau
-- Handler for CapturePointTerminalManager integration and event logic

local CapturePointTerminalManager = require(game.ReplicatedStorage.Service.Manager.CapturePointTerminalManager)
local manager = CapturePointTerminalManager.new()

local CapturePointTerminalHandler = {}

-- Add a capture point from a part
function CapturePointTerminalHandler:AddCapturePointFromPart(part, mode)
    if part and part:IsA("BasePart") then
        manager:AddTerminal(part.Name, part.Position, mode or "Easy")
    end
end

-- Capture logic: call when a team captures a point
function CapturePointTerminalHandler:CapturePoint(name, team)
    manager:CaptureTerminal(name, team)
end

-- Get info for all capture points
function CapturePointTerminalHandler:GetAllCapturePointInfo()
    return manager:GetAllTerminalInfo()
end

return CapturePointTerminalHandler
