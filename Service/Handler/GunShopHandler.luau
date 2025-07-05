local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReadModule = require(ServerScriptService:WaitForChild("Components"):WaitForChild("ReadModule"))
local GunShop = require(ReplicatedStorage:WaitForChild("Classes"):WaitForChild("GunShop"))
local GunConfigs = game:GetService("ReplicatedStorage"):WaitForChild("GunEngineShared").Configuration
local GunShop = GunShop.new()
local WalletHandler = require(ServerScriptService:WaitForChild("Handler"):WaitForChild("WalletHandler"))
local GunShopRemote = "GunShopRemote"
local remoteEvent = ReplicatedStorage:FindFirstChild(GunShopRemote)
if not remoteEvent then
    remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Name = GunShopRemote
    remoteEvent.Parent = ReplicatedStorage
end

local GunShopHandler = {}

function GunShopHandler:InitializeGunShop()
    local gunModules = GunConfigs:GetChildren()
    for _, module in pairs(gunModules) do
        if module:IsA("ModuleScript") then
            local gunData = ReadModule.read(module)
            if gunData and gunData.Name then
                -- Set price from IntValue child if it exists
                local priceValue = module:FindFirstChild("Price")
                if priceValue and priceValue:IsA("IntValue") then
                    gunData.Price = priceValue.Value
                end
                GunShop:AddGun(module.Name, gunData)
            else
                warn("[GunShopHandler:InitializeGunShop] Invalid gun data in module: " .. module.Name)
            end
        end
    end
end

function GunShopHandler:GetGun(name)
    return GunShop:GetGun(name)
end

function GunShopHandler:GetAllGuns()
    return GunShop:GetAllGuns()
end

function GunShopHandler:AddGun(name, data)
    return GunShop:AddGun(name, data)
end

function GunShopHandler:RemoveGun(name)
    return GunShop:RemoveGun(name)
end

function GunShopHandler:UpdateGun(name, data)
    return GunShop:UpdateGun(name, data)
end

function GunShopHandler:ClearGuns()
    GunShop:ClearGuns()
end

function GunShopHandler:HasGun(name)
    return GunShop:HasGun(name)
end

function GunShopHandler:GetGunsByType(gunType)
    return GunShop:GetGunsByType(gunType)
end

function GunShopHandler:PrintGuns()
    GunShop:PrintGuns()
end

function GunShopHandler:SaveGunShopData()
    local success, err = pcall(function()
        local dataStore = DataStoreService:GetDataStore("GunShopData")
        dataStore:SetAsync("Guns", GunShop:GetAllGuns())
    end)
    if not success then
        warn("[GunShopHandler:SaveGunShopData] Failed to save gun shop data: " .. tostring(err))
    end
end

function GunShopHandler:LoadGunShopData()
    local dataStore = DataStoreService:GetDataStore("GunShopData")
    local success, data = pcall(function()
        return dataStore:GetAsync("Guns")
    end)
    if success and data then
        for name, gunData in pairs(data) do
            GunShop:AddGun(name, gunData)
        end
    else
        warn("[GunShopHandler:LoadGunShopData] Failed to load gun shop data: " .. tostring(data))
    end
end

function GunShopHandler:OnPlayerAdded(player)
    self:InitializeGunShop()
    self:LoadGunShopData()
    remoteEvent:FireClient(player, GunShop:GetAllGuns())
end

function GunShopHandler:OnPlayerRemoving(player)
    self:SaveGunShopData()
end

function GunShopHandler:ConnectPlayerEvents(player)
    player.CharacterAdded:Connect(function()
        self:OnPlayerAdded(player)
    end)
    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            self:OnPlayerRemoving(player)
        end
    end)
end

function GunShopHandler:Initialize()
    game.Players.PlayerAdded:Connect(function(player)
        self:ConnectPlayerEvents(player)
        self:OnPlayerAdded(player)
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerRemoving(player)
    end)

    -- Load existing gun shop data on server start
    self:LoadGunShopData()
end

function GunShopHandler:Destroy()
    -- Cleanup if necessary
    GunShop:ClearGuns()
end

function GunShopHandler:BuyGun(player, gunName)
    local gun = GunShop:GetGun(gunName)
    if not gun then
        warn("[GunShopHandler:BuyGun] Gun not found: " .. tostring(gunName))
        return false, "Gun not found"
    end

    -- Attempt to remove funds using WalletHandler
    local success = WalletHandler:RemoveFunds(player, gun.Price)
    if success then
        -- You should add logic here to give the gun to the player, e.g. add to inventory
        -- Example: player:AddGunToInventory(gunName)
        print("[GunShopHandler:BuyGun] " .. player.Name .. " bought " .. gunName .. " for " .. tostring(gun.Price))
        return true
    else
        warn("[GunShopHandler:BuyGun] Not enough funds for " .. player.Name .. " to buy " .. gunName)
        return false, "Not enough funds"
    end
end

return GunShopHandler

