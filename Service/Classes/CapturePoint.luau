local CapturePoint = {}
CapturePoint.__index = CapturePoint

function CapturePoint.new(name, location)
    local self = setmetatable({}, CapturePoint)
    self.Name = name
    self.Location = location -- Vector3 or CFrame for the capture point's position
    self.Occupied = false -- Whether the capture point is currently occupied
    self.OccupyingTeam = nil -- Team currently occupying the capture point
    print("Capture Point created: " .. self.Name .. " at location: " .. tostring(location))
    return self
end

function CapturePoint:SetOccupied(team)
    self.Occupied = true
    self.OccupyingTeam = team
    print("Capture Point " .. self.Name .. " is now occupied by team: " .. team.Name)
end

function CapturePoint:Release()
    self.Occupied = false
    self.OccupyingTeam = nil
    print("Capture Point " .. self.Name .. " has been released")
end

function CapturePoint:IsOccupied()
    return self.Occupied
end

function CapturePoint:GetInfo()
    return {
        Name = self.Name,
        Location = self.Location,
        Occupied = self.Occupied,
        OccupyingTeam = self.OccupyingTeam and self.OccupyingTeam.Name or "None"
    }
end

function CapturePoint:GetLocation()
    return self.Location
end

function CapturePoint:SetLocation(location)
    self.Location = location
    print("Capture Point " .. self.Name .. " location set to: " .. tostring(location))
end

function CapturePoint:GetName()
    return self.Name
end

function CapturePoint:SetName(name)
    self.Name = name
    print("Capture Point name set to: " .. self.Name)
end

return CapturePoint