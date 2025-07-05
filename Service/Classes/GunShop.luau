local GunShop = {}
-- GunShop: A class to manage a collection of guns in a game

GunShop.__index = GunShop

function GunShop.new()
    local self = setmetatable({}, GunShop)
    self.Guns = {
        -- Example gun data structure
        -- ["GunName"] = {
        -- Type = "Assault Rifle", -- or "Sniper Rifle", "Shotgun", "Machine Gun", "Pistol", etc.
        --     Price = 100,
        --     Damage = 25,
        --     Range = 50,
        --     FireRate = 0.5,
        --     AmmoCapacity = 30,
        -- }
    }
    return self
end

function GunShop:AddGun(name, data)
    if not self.Guns[name] then
        self.Guns[name] = data
        return true
    else
        warn("[GunShop:AddGun] Gun already exists: " .. name)
        return false
    end
end

function GunShop:RemoveGun(name)
    if self.Guns[name] then
        self.Guns[name] = nil
        return true
    else
        warn("[GunShop:RemoveGun] Gun not found: " .. name)
        return false
    end
end

function GunShop:GetGun(name)
    return self.Guns[name] or nil
end

function GunShop:GetAllGuns()
    return self.Guns
end

function GunShop:UpdateGun(name, data)
    if self.Guns[name] then
        self.Guns[name] = data
        return true
    else
        warn("[GunShop:UpdateGun] Gun not found: " .. name)
        return false
    end
end

function GunShop:ClearGuns()
    self.Guns = {}
end

function GunShop:HasGun(name)
    return self.Guns[name] ~= nil
end

-- Get gun by type
function GunShop:GetGunsByType(gunType)
    local gunsByType = {}
    for name, data in pairs(self.Guns) do
        if data.Type == gunType then
            gunsByType[name] = data
        end
    end
    return gunsByType
end

function GunShop:PrintGuns()
    for name, data in pairs(self.Guns) do
        print("Gun Name: " .. name)
        for key, value in pairs(data) do
            print("  " .. key .. ": " .. tostring(value))
        end
    end
end

function GunShop:GetGunNames()
    local names = {}
    for name in pairs(self.Guns) do
        table.insert(names, name)
    end
    return names
end

return GunShop
