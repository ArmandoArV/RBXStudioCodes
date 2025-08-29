local Dealership = {}
Dealership.__index = Dealership

-- Import Car class
local Car = require(script.Parent.Car)

function Dealership.new(model)
    local self = setmetatable({}, Dealership)
    self.Model = model
    self.Cars = {} -- Table to hold car instances
    return self
end

function Dealership:AddCar(model)
    if not self.Cars[model] then
        local car = Car.new(model)
        self.Cars[model] = car
        return true
    else
        warn("[Dealership:AddCar] Car already exists: " .. model)
        return false
    end
end

function Dealership:RemoveCar(model)
    if self.Cars[model] then
        self.Cars[model] = nil
        return true
    else
        warn("[Dealership:RemoveCar] Car not found: " .. model)
        return false
    end
end

function Dealership:GetCar(model)
    return self.Cars[model] or nil
end

function Dealership:GetAllCars()
    return self.Cars
end

function Dealership:UpdateCar(model, carData)
    if self.Cars[model] then
        self.Cars[model] = carData
        return true
    else
        warn("[Dealership:UpdateCar] Car not found: " .. model)
        return false
    end
end

function Dealership:ClearCars()
    self.Cars = {}
end

function Dealership:HasCar(model)
    return self.Cars[model] ~= nil
end

function Dealership:GetCarsByOwnership(isOwned)
    local carsByOwnership = {}
    for model, car in pairs(self.Cars) do
        if car:IsOwned() == isOwned then
            carsByOwnership[model] = car
        end
    end
    return carsByOwnership
end

function Dealership:GetCarsByLockStatus(isLocked)
    local carsByLockStatus = {}
    for model, car in pairs(self.Cars) do
        if car:IsLocked() == isLocked then
            carsByLockStatus[model] = car
        end
    end
    return carsByLockStatus
end

function Dealership:GetCarsByRobuxStatus(isRobux)
    local carsByRobuxStatus = {}
    for model, car in pairs(self.Cars) do
        if car:IsRobux() == isRobux then
            carsByRobuxStatus[model] = car
        end
    end
    return carsByRobuxStatus
end

function Dealership:GetCarsBySpawnedStatus(isSpawned)
    local carsBySpawnedStatus = {}
    for model, car in pairs(self.Cars) do
        if car:IsSpawned() == isSpawned then
            carsBySpawnedStatus[model] = car
        end
    end
    return carsBySpawnedStatus
end

return Dealership
