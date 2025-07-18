-- TurfClient.luau
-- Client-safe module to get turf info from ReplicatedStorage

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TurfClient = {}

-- Returns a table of all turfs and their info
function TurfClient:GetAllTurfs()
    local turfs = {}
    local turfFolder = ReplicatedStorage:FindFirstChild("Turfs")
    if not turfFolder then return turfs end
    for _, turfInstance in ipairs(turfFolder:GetChildren()) do
        local info = {
            Name = turfInstance.Name,
            Owner = nil,
            Defenders = {},
        }
        local ownerValue = turfInstance:FindFirstChild("Owner")
        if ownerValue and ownerValue.Value then
            info.Owner = ownerValue.Value
        end
        for _, obj in ipairs(turfInstance:GetChildren()) do
            if obj:IsA("ObjectValue") and obj.Name ~= "Owner" and obj.Value then
                table.insert(info.Defenders, obj.Value)
            end
        end
        table.insert(turfs, info)
    end
    return turfs
end

-- Returns the turf info for a given team (by owner)
function TurfClient:GetTurfByTeam(team)
    local turfFolder = ReplicatedStorage:FindFirstChild("Turfs")
    if not turfFolder then return nil end
    for _, turfInstance in ipairs(turfFolder:GetChildren()) do
        local ownerValue = turfInstance:FindFirstChild("Owner")
        if ownerValue and ownerValue.Value == team then
            return turfInstance
        end
    end
    return nil
end

return TurfClient
