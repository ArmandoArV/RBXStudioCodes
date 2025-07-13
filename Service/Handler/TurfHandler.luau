local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GangRemoteEvent = "TurfRemoteEvent"
local Turf = require(ReplicatedStorage:WaitForChild("Classes"):WaitForChild("Turf"))
-- Ensure the RemoteEvent exists
local remoteEvent = ReplicatedStorage:FindFirstChild(GangRemoteEvent)
if not remoteEvent then
    remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Name = GangRemoteEvent
    remoteEvent.Parent = ReplicatedStorage
end

local TurfHandler = {}

local TurfRemoteEvent = ReplicatedStorage:FindFirstChild(GangRemoteEvent)

TurfRemoteEvent.OnServerEvent:Connect(function(player, action, ...)
    local turfHandler = require(ReplicatedStorage:WaitForChild("Handler"):WaitForChild("TurfHandler"))
    local turf = turfHandler:GetTurfByPlayer(player)

    if not turf then
        warn("Player " .. player.Name .. " is not in a turf.")
        return
    end

    if action == "SetOwner" then
        local newOwner = ...
        turfHandler:SetOwner(turf, newOwner)
    elseif action == "AddDefender" then
        local defender = ...
        turfHandler:AddDefender(turf, defender)
    elseif action == "RemoveDefender" then
        local defender = ...
        turfHandler:RemoveDefender(turf, defender)
    elseif action == "GetInfo" then
        return turfHandler:GetTurfInfo(turf)
    end
end)

-- Update the turf info in ReplicatedStorage
local function updateTurfInfo(turf)
    local turfFolder = ReplicatedStorage:FindFirstChild("Turfs")
    if not turfFolder then
        turfFolder = Instance.new("Folder")
        turfFolder.Name = "Turfs"
        turfFolder.Parent = ReplicatedStorage
    end

    local turfInfo = turf:GetInfo()
    local turfInstance = turfFolder:FindFirstChild(turfInfo.Name)

    if not turfInstance then
        turfInstance = Instance.new("Folder")
        turfInstance.Name = turfInfo.Name
        turfInstance.Parent = turfFolder
    end

    -- Update owner and defenders
    local ownerValue = Instance.new("ObjectValue")
    ownerValue.Name = "Owner"
    ownerValue.Value = turfInfo.Owner
    ownerValue.Parent = turfInstance

    for _, defender in pairs(turfInfo.Defenders) do
        local defenderValue = Instance.new("ObjectValue")
        defenderValue.Name = defender.Name
        defenderValue.Value = defender
        defenderValue.Parent = turfInstance
    end

    print("Turf info updated for: " .. turfInfo.Name)
end


TurfHandler.UpdateTurfInfo = updateTurfInfo

function TurfHandler:CreateTurf(name, location, owner)
    local turf = Turf.new(name, location, owner)
    updateTurfInfo(turf)
    return turf
end

function TurfHandler:GetTurfByPlayer(player)
    local turfFolder = ReplicatedStorage:FindFirstChild("Turfs")
    if not turfFolder then return nil end

    for _, turfInstance in pairs(turfFolder:GetChildren()) do
        local ownerValue = turfInstance:FindFirstChild("Owner")
        if ownerValue and ownerValue.Value == player then
            return turfInstance
        end
    end

    return nil
end

function TurfHandler:SetOwner(turf, player)
    if turf and player then
        turf:SetOwner(player)
        updateTurfInfo(turf)
    else
        warn("Invalid turf or player.")
    end
end

function TurfHandler:AddDefender(turf, player)
    if turf and player then
        turf:AddDefender(player)
        updateTurfInfo(turf)
    else
        warn("Invalid turf or player.")
    end
end

function TurfHandler:RemoveDefender(turf, player)
    if turf and player then
        turf:RemoveDefender(player)
        updateTurfInfo(turf)
    else
        warn("Invalid turf or player.")
    end
end

function TurfHandler:GetTurfInfo(turf)
    if turf then
        return turf:GetInfo()
    else
        warn("Invalid turf.")
        return nil
    end
end

return TurfHandler