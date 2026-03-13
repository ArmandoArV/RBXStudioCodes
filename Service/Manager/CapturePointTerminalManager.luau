-- CapturePointTerminalManager.luau
-- Manages capture point terminals, integrates with CapturePointManager, and handles UI events

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CapturePointManager = require(script.Parent.CapturePointManager)

local remoteEvent = ReplicatedStorage:FindFirstChild("CapturePointEvent")
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "CapturePointEvent"
	remoteEvent.Parent = ReplicatedStorage
end

local TerminalManager = {}
TerminalManager.__index = TerminalManager

function TerminalManager.new()
	local self = setmetatable({}, TerminalManager)
	self.Manager = CapturePointManager.new()
	return self
end

function TerminalManager:AddTerminal(name, location, mode)
	return self.Manager:AddPoint(name, location, mode)
end

function TerminalManager:CaptureTerminal(name, team)
	local point = self.Manager:CapturePoint(name, team)
	if point then
		remoteEvent:FireAllClients("UpdateCapturePointUI", point:GetInfo())
	end
	return point
end

function TerminalManager:GetAllTerminalInfo()
	return self.Manager:GetAllCapturePointInfo()
end

return TerminalManager
