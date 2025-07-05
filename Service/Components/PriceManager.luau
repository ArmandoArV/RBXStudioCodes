-- PriceManager.luau
-- ModuleScript for managing Price IntValues in tools in ReplicatedStorage.Tools

local PriceManager = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GunFolder = ReplicatedStorage:WaitForChild("Tools")

-- Ensures every tool in GunFolder (and subfolders) has a Price IntValue, using the given priceMap (toolName -> price)
function PriceManager.EnsurePrices(priceMap)
    for _, tool in pairs(GunFolder:GetDescendants()) do
        if tool:IsA("Tool") then
            local price = priceMap[tool.Name] or 0
            local priceValue = tool:FindFirstChild("Price")
            if not priceValue then
                priceValue = Instance.new("IntValue")
                priceValue.Name = "Price"
                priceValue.Parent = tool
            end
            priceValue.Value = price
        end
    end
end

-- Updates prices for tools using a hashmap (toolName -> price)
function PriceManager.UpdatePrices(priceMap)
    for _, tool in pairs(GunFolder:GetDescendants()) do
        if tool:IsA("Tool") then
            local priceValue = tool:FindFirstChild("Price")
            if priceValue and priceMap[tool.Name] then
                priceValue.Value = priceMap[tool.Name]
            end
        end
    end
end

-- Returns a hashmap of all tool prices (toolName -> price)
function PriceManager.GetAllPrices()
    local prices = {}
    for _, tool in pairs(GunFolder:GetDescendants()) do
        if tool:IsA("Tool") then
            local priceValue = tool:FindFirstChild("Price")
            if priceValue then
                prices[tool.Name] = priceValue.Value
            end
        end
    end
    return prices
end

return PriceManager
