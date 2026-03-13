-- CapturePointEventSystem.luau
-- Sets up event system for backend <-> UI communication

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent = ReplicatedStorage:FindFirstChild("CapturePointEvent")
if not remoteEvent then
    remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Name = "CapturePointEvent"
    remoteEvent.Parent = ReplicatedStorage
end

local EventSystem = {}
EventSystem.__index = EventSystem

function EventSystem:FireUpdate(info)
    remoteEvent:FireAllClients("UpdateCapturePointUI", info)
end

function EventSystem:OnUpdate(callback)
    remoteEvent.OnClientEvent:Connect(function(action, info)
        if action == "UpdateCapturePointUI" then
            callback(info)
        end
    end)
end

return EventSystem
