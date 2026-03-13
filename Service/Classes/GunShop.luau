-- GunShop: Extends Shop to manage a collection of guns.
-- Gun data structure example:
-- {
--     Type = "Assault Rifle", -- "Sniper Rifle", "Shotgun", "Machine Gun", "Pistol", etc.
--     Price = 100,
--     Damage = 25,
--     Range = 50,
--     FireRate = 0.5,
--     AmmoCapacity = 30,
-- }

local Shop = require(script.Parent.Shop)

local GunShop = setmetatable({}, { __index = Shop })
GunShop.__index = GunShop

function GunShop.new()
	local self = Shop.new("Gun")
	return setmetatable(self, GunShop)
end

-- Gun-specific: filter by Type field
function GunShop:GetGunsByType(gunType: string)
	return self:GetItemsByFilter(function(_, data)
		return data.Type == gunType
	end)
end

-- Aliases kept for backward compatibility
function GunShop:AddGun(name, data)       return self:AddItem(name, data) end
function GunShop:RemoveGun(name)          return self:RemoveItem(name) end
function GunShop:GetGun(name)             return self:GetItem(name) end
function GunShop:GetAllGuns()             return self:GetAllItems() end
function GunShop:UpdateGun(name, data)    return self:UpdateItem(name, data) end
function GunShop:ClearGuns()              return self:ClearItems() end
function GunShop:HasGun(name)             return self:HasItem(name) end
function GunShop:GetGunNames()            return self:GetItemNames() end
function GunShop:PrintGuns()              return self:PrintItems() end

return GunShop
