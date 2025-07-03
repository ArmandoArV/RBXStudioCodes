local Human = require(script.Parent.Human)
local Outfit = {}
Outfit.__index = Outfit
-- Add inheritance from Human
setmetatable(Outfit, {
    __index = Human
})

-- Helper function to extract clothing/accessory info
local function getClothingValue(instance, className, propertyName)
    if not instance then
        return nil
    end
    if instance:IsA(className) then
        return instance[propertyName]
    elseif instance:IsA("StringValue") or instance:IsA("ObjectValue") then
        return instance.Value
    else
        return nil
    end
end

-- Constructor for Outfit
function Outfit.new(model)
    if not model or typeof(model) ~= "Instance" or not model:IsA("Model") then
        error("Outfit.new: model is not a valid Model instance")
    end
    local human
    local success, err = pcall(function()
        human = Human.new(model)
    end)
    if not success then
        error("Failed to create Human instance for Outfit: " .. tostring(err))
    end
    local self = setmetatable(human, Outfit)
    self.Model = model

    -- Hat, Helmet, Gloves, Glasses, Vest may be Accessories or Parts or ValueObjects
    self.hat = model:FindFirstChild("Hat") or nil
    self.helmet = model:FindFirstChild("Helmet") or nil
    self.gloves = model:FindFirstChild("Gloves") or nil
    self.glasses = model:FindFirstChild("Glasses") or nil
    self.vest = model:FindFirstChild("Vest") or nil

    -- Shirt and Pants are usually Shirt/Pants instances, or ValueObjects
    local shirtObj = model:FindFirstChild("Shirt")
    if shirtObj then
        self.shirt = getClothingValue(shirtObj, "Shirt", "ShirtTemplate")
    else
        self.shirt = nil
    end

    local pantsObj = model:FindFirstChild("Pants")
    if pantsObj then
        self.pants = getClothingValue(pantsObj, "Pants", "PantsTemplate")
    else
        self.pants = nil
    end

    return self
end

function Outfit:UpdateHelmet(newHelmet)
    if newHelmet then
        self.helmet = newHelmet
        self.Head = newHelmet -- Helmet goes on the head
    else
        self.helmet = nil
        self.Head = nil
    end
end

function Outfit:UpdateGloves(newGloves)
    if newGloves then
        self.gloves = newGloves
        self.LeftHand = newGloves
        self.RightHand = newGloves
    else
        self.gloves = nil
        self.LeftHand = nil
        self.RightHand = nil
    end
end

function Outfit:UpdateVest(newVest)
    if newVest then
        self.vest = newVest
        self.UpperTorso = newVest
    else
        self.vest = nil
        self.UpperTorso = nil
    end
end

return Outfit

