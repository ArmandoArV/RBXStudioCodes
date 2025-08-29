local Car = {}
Car.__index = Car

function Car.new(model)
    local self = setmetatable({}, Car)
    self.Model = model
    self.IsLocked = false
    self.isRobux = false
    self.isOwned = false
    self.isSpawned = false
    self.cost = 0
    self.color = "Default"
    self.isGroupOnly = false

    return self
end

function Car:Lock()
    self.IsLocked = true
end

function Car:Unlock()
    self.IsLocked = false
end

function Car:IsLocked()
    return self.IsLocked
end

function Car:SetRobuxStatus(status)
    self.isRobux = status
end

function Car:IsRobux()
    return self.isRobux
end

function Car:SetOwnership(status)
    self.isOwned = status
end

function Car:IsOwned()
    return self.isOwned
end

function Car:SetSpawned(status)
    self.isSpawned = status
end

function Car:IsSpawned()
    return self.isSpawned
end

function Car:SetCost(cost)
    self.cost = cost
end

function Car:GetCost()
    return self.cost
end

function Car:SetColor(color)
    self.color = color
end

function Car:GetColor()
    return self.color
end

function Car:SetGroupOnly(status)
    self.isGroupOnly = status
end

function Car:IsGroupOnly()
    return self.isGroupOnly
end

return Car
