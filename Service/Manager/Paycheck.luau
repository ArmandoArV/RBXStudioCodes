local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local WalletHandler = require(ServerScriptService:WaitForChild("Handler"):WaitForChild("WalletHandler"))

local SendNotification = ReplicatedStorage:WaitForChild("SendNotification")

local PAYCHECK_INTERVAL = 15 * 60 -- 15 minutes in seconds
local MIN_PAY = 100
local MAX_PAY = 700


local function givePaycheck(player)
	local amount = math.random(MIN_PAY, MAX_PAY)
	WalletHandler:AddFunds(player, amount)
	SendNotification:FireClient(player, {
		Title = "CHEQUE",
		Text = "Recibiste un pago de $" .. amount .. "",
		Icon = "rbxassetid://6022668892", -- Set an icon asset id if desired
		Duration = 5
	})
end

local function giveFirstJoinBonus(player)
	-- Use DataStore to check if this is the user's first join
	local DataStoreService = game:GetService("DataStoreService")
	local joinStore = DataStoreService:GetDataStore("PlayerFirstJoinStore")
	local key = "FirstJoin_" .. player.UserId
	local success, hasJoined = pcall(function()
		return joinStore:GetAsync(key)
	end)
	if success and not hasJoined then
		-- First join, give bonus
		WalletHandler:AddFunds(player, 3500)
		SendNotification:FireClient(player, {
			Title = "BONO DE BIENVENIDA",
			Text = "Recibiste $3500 por ser nuevo",
			Icon = "rbxassetid://6022668892",
			Duration = 6
		})
		pcall(function()
			joinStore:SetAsync(key, true)
		end)
	end
end

local function startPaycheckLoop()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			givePaycheck(player)
		end
		wait(PAYCHECK_INTERVAL)
	end
end


Players.PlayerAdded:Connect(function(player)
	giveFirstJoinBonus(player)
	givePaycheck(player)
end)

task.spawn(startPaycheckLoop)
