local Shop = require(script.Parent.Shop)
local Car = require(script.Parent.Car)

local Dealership = setmetatable({}, { __index = Shop })
Dealership.__index = Dealership

function Dealership.new(model)
	local self = Shop.new("Car")
	self.Model = model
	return setmetatable(self, Dealership)
end

-- Car-specific filter by any boolean property on the Car object
function Dealership:GetCarsByProperty(property: string, value: any)
	return self:GetItemsByFilter(function(_, car)
		if type(car[property]) == "function" then
			return car[property](car) == value
		end
		return car[property] == value
	end)
end

function Dealership:GetCarsByOwnership(isOwned)    return self:GetCarsByProperty("isOwned", isOwned) end
function Dealership:GetCarsByLockStatus(isLocked)  return self:GetCarsByProperty("IsLocked", isLocked) end
function Dealership:GetCarsByRobuxStatus(isRobux)  return self:GetCarsByProperty("isRobux", isRobux) end
function Dealership:GetCarsBySpawnedStatus(isSpawned) return self:GetCarsByProperty("isSpawned", isSpawned) end

-- Aliases for backward compatibility
function Dealership:AddCar(model)
	if not self.Items[model] then
		self.Items[model] = Car.new(model)
		return true
	end
	warn("[Dealership:AddCar] Car already exists: " .. model)
	return false
end
function Dealership:RemoveCar(model)   return self:RemoveItem(model) end
function Dealership:GetCar(model)      return self:GetItem(model) end
function Dealership:GetAllCars()       return self:GetAllItems() end
function Dealership:UpdateCar(m, d)    return self:UpdateItem(m, d) end
function Dealership:ClearCars()        return self:ClearItems() end
function Dealership:HasCar(model)      return self:HasItem(model) end

return Dealership
