local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local CapturePoint = require(ReplicatedStorage:WaitForChild("Classes"):WaitForChild("CapturePoint"))

local capturePointFolder = ReplicatedStorage:FindFirstChild("CapturePointObjects")
if not capturePointFolder then
    capturePointFolder = Instance.new("Folder")
    capturePointFolder.Name = "CapturePointObjects"
    capturePointFolder.Parent = ReplicatedStorage
end


local allCapturePoints = {} -- hashmap: name -> capturePoint
local CapturePointHandler = {}



function CapturePointHandler:CreateCapturePoint(name, location)
    local capturePoint = CapturePoint.new(name, location)
    print("Capture Point Handler created a new capture point: " .. name)
    allCapturePoints[name] = capturePoint
    return capturePoint
end

function CapturePointHandler:OccupyCapturePoint(capturePoint, team)
    if not capturePoint:IsOccupied() then
        capturePoint:SetOccupied(team)
        print("Capture Point " .. capturePoint:GetName() .. " occupied by team: " .. team.Name)
    else
        print("Capture Point " .. capturePoint:GetName() .. " is already occupied by team: " .. capturePoint.OccupyingTeam.Name)
    end
end

function CapturePointHandler:ReleaseCapturePoint(capturePoint)
    if capturePoint:IsOccupied() then
        capturePoint:Release()
        print("Capture Point " .. capturePoint:GetName() .. " has been released")
    else
        print("Capture Point " .. capturePoint:GetName() .. " is not occupied")
    end
end

function CapturePointHandler:GetCapturePointInfo(capturePoint)
    return capturePoint:GetInfo()
end

function CapturePointHandler:SetCapturePointLocation(capturePoint, location)
    capturePoint:SetLocation(location)
    print("Capture Point " .. capturePoint:GetName() .. " location updated to: " .. tostring(location))
end

function CapturePointHandler:SetCapturePointName(capturePoint, name)
    capturePoint:SetName(name)
    print("Capture Point name updated to: " .. capturePoint:GetName())
end

function CapturePointHandler:GetCapturePointLocation(capturePoint)
    return capturePoint:GetLocation()
end

function CapturePointHandler:GetCapturePointName(capturePoint)
    return capturePoint:GetName()
end



function CapturePointHandler:GetAllCapturePoints()
    local points = {}
    for _, cp in pairs(allCapturePoints) do
        table.insert(points, cp)
    end
    return points
end

function CapturePointHandler:PrintAllCapturePoints()
    local capturePoints = self:GetAllCapturePoints()
    for _, point in pairs(capturePoints) do
        print("Capture Point: " .. point:GetName() .. ", Location: " .. tostring(point:GetLocation()) .. ", Occupied: " .. tostring(point:IsOccupied()))
    end
end

function CapturePointHandler:ClearCapturePoints()
    local capturePoints = self:GetAllCapturePoints()
    for _, point in pairs(capturePoints) do
        point:Release()
        print("Capture Point " .. point:GetName() .. " has been cleared")
    end
end

function CapturePointHandler:ResetCapturePoints()
    self:ClearCapturePoints()
    print("All capture points have been reset")
end

function CapturePointHandler:InitializeCapturePoints()
    print("Initializing Capture Points...")
    -- Here you can add logic to create default capture points or load them from a configuration
end
function CapturePointHandler:DestroyCapturePoint(capturePoint)
    if capturePoint then
        capturePoint:Release()
        print("Capture Point " .. capturePoint:GetName() .. " has been destroyed")
    else
        print("No capture point provided to destroy")
    end
end

function CapturePointHandler:FindCapturePointByName(name)
    local capturePoints = self:GetAllCapturePoints()
    for _, point in pairs(capturePoints) do
        if point:GetName() == name then
            return point
        end
    end
    print("Capture Point with name " .. name .. " not found")
    return nil
end

function CapturePointHandler:FindCapturePointByLocation(location)
    local capturePoints = self:GetAllCapturePoints()
    for _, point in pairs(capturePoints) do
        if point:GetLocation() == location then
            return point
        end
    end
    print("Capture Point at location " .. tostring(location) .. " not found")
    return nil
end

function CapturePointHandler:UpdateCapturePointOccupancy(capturePoint, team)
    if capturePoint:IsOccupied() and capturePoint.OccupyingTeam == team then
        print("Capture Point " .. capturePoint:GetName() .. " is already occupied by the same team: " .. team.Name)
    elseif capturePoint:IsOccupied() then
        print("Capture Point " .. capturePoint:GetName() .. " is occupied by another team: " .. capturePoint.OccupyingTeam.Name)
    else
        self:OccupyCapturePoint(capturePoint, team)
    end
end

function CapturePointHandler:HandleCapturePointEvent(event, capturePoint, team)
    if event == "Occupy" then
        self:OccupyCapturePoint(capturePoint, team)
    elseif event == "Release" then
        self:ReleaseCapturePoint(capturePoint)
    elseif event == "UpdateLocation" then
        self:SetCapturePointLocation(capturePoint, team.Location)
    elseif event == "UpdateName" then
        self:SetCapturePointName(capturePoint, team.Name)
    else
        print("Unknown event: " .. event)
    end
end

function CapturePointHandler:LogCapturePointEvent(event, capturePoint, team)
    print("Event: " .. event .. ", Capture Point: " .. capturePoint:GetName() .. ", Team: " .. (team and team.Name or "None"))
end

function CapturePointHandler:CapturePointExists(capturePoint)
    return capturePoint and capturePoint:IsA("CapturePoint")
end

function CapturePointHandler:CapturePointIsOccupied(capturePoint)
    return capturePoint and capturePoint:IsOccupied()
end

function CapturePointHandler:CapturePointGetOccupyingTeam(capturePoint)
    return capturePoint and capturePoint.OccupyingTeam or nil
end

function CapturePointHandler:CapturePointGetInfo(capturePoint)
    return capturePoint and capturePoint:GetInfo() or nil
end

function CapturePointHandler:CapturePointGetLocation(capturePoint)
    return capturePoint and capturePoint:GetLocation() or nil
end

function CapturePointHandler:CapturePointGetName(capturePoint)
    return capturePoint and capturePoint:GetName() or nil
end

function CapturePointHandler:CapturePointSetLocation(capturePoint, location)
    if capturePoint then
        capturePoint:SetLocation(location)
    else
        print("No capture point provided to set location")
    end
end

function CapturePointHandler:CapturePointSetName(capturePoint, name)
    if capturePoint then
        capturePoint:SetName(name)
    else
        print("No capture point provided to set name")
    end
end

function CapturePointHandler:CapturePointReset(capturePoint)
    if capturePoint then
        capturePoint:Release()
        print("Capture Point " .. capturePoint:GetName() .. " has been reset")
    else
        print("No capture point provided to reset")
    end
end

function CapturePointHandler:CapturePointDestroy(capturePoint)
    if capturePoint then
        capturePoint:Release()
        print("Capture Point " .. capturePoint:GetName() .. " has been destroyed")
    else
        print("No capture point provided to destroy")
    end
end

return CapturePointHandler