local CapturePoint = {}
CapturePoint.__index = CapturePoint

-- Modes definition
local MODES = {
    Easy = {name = "Easy", duration = 1200, onCapture = function(self, isNewTeam)
        if isNewTeam then
            self.Score = math.max(0, self.Score - 1)
        else
            self.Score = self.Score + 1
        end
    end},
    Medium = {name = "Medium", duration = 1500, onCapture = function(self, isNewTeam)
        if isNewTeam then
            self.Score = math.max(0, self.Score - 2)
        else
            self.Score = self.Score + 1
        end
    end},
    Hard = {name = "Hard", duration = 1500, onCapture = function(self, isNewTeam)
        if isNewTeam then
            self.Score = 0
        else
            self.Score = self.Score + 1
        end
    end}
}

function CapturePoint.new(name, location, mode)
    local self = setmetatable({}, CapturePoint)
    self.Name = name
    self.Location = location -- Vector3 or CFrame for the capture point's position
    self.Occupied = false -- Whether the capture point is currently occupied
    self.OccupyingTeam = nil -- Team currently occupying the capture point
    self.Mode = MODES[mode] or MODES.Easy
    self.Score = 0
    self.Timer = self.Mode.duration
    print("Capture Point created: " .. self.Name .. " at location: " .. tostring(location) .. " | Mode: " .. self.Mode.name)
    return self
end

-- Capture logic with scoring
function CapturePoint:Capture(newTeam)
    local isNewTeam = (self.OccupyingTeam ~= newTeam)
    self.Mode.onCapture(self, isNewTeam)
    self.Occupied = true
    self.OccupyingTeam = newTeam
    print("Capture Point " .. self.Name .. " captured by team: " .. newTeam.Name .. " | Score: " .. tostring(self.Score))
    -- TODO: Fire event for UI update
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
        OccupyingTeam = self.OccupyingTeam and self.OccupyingTeam.Name or "None",
        Mode = self.Mode.name,
        Score = self.Score,
        Timer = self.Timer
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