-- GunShopPurchaseHandler.luau
-- Place this Script in ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ToolCloner = require(ReplicatedStorage:WaitForChild("Components"):WaitForChild("ToolCloner"))
local GunPrices = require(ReplicatedStorage:WaitForChild("Components"):WaitForChild("GunPrices"))
local WalletHandler = require(game:GetService("ServerScriptService"):WaitForChild("Handler"):WaitForChild("WalletHandler"))

local GunShopPurchaseEvent = ReplicatedStorage:WaitForChild("GunShopPurchase")

GunShopPurchaseEvent.OnServerEvent:Connect(function(player, gunName)
    if not gunName then
        GunShopPurchaseEvent:FireClient(player, "not_found", gunName)
        return
    end
    local price = GunPrices.GetPrice(gunName)
    if price <= 0 then
        GunShopPurchaseEvent:FireClient(player, "not_found", gunName)
        return
    end
    local wallet = WalletHandler:GetWalletForPlayer(player)
    if not wallet then
        GunShopPurchaseEvent:FireClient(player, "not_found", gunName)
        return
    end
    local balance = wallet:GetBalance()
    if balance < price then
        GunShopPurchaseEvent:FireClient(player, "too_expensive", gunName)
        return
    end
    local success = WalletHandler:RemoveFunds(player, price)
    if not success then
        GunShopPurchaseEvent:FireClient(player, "too_expensive", gunName)
        return
    end
    -- Give the tool
    local tool = ToolCloner.CloneTool(gunName)
    if tool then
        tool.Parent = player.Backpack
        GunShopPurchaseEvent:FireClient(player, "success", gunName)
    else
        GunShopPurchaseEvent:FireClient(player, "not_found", gunName)
    end
end)
