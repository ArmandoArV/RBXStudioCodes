local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Wallet = require(ServerScriptService:WaitForChild("Classes"):WaitForChild("Wallet"))
local WalletStore = DataStoreService:GetDataStore("WalletStore")

local REMOTE_EVENT_NAME = "WalletBalanceChanged"
local remoteEvent = ReplicatedStorage:FindFirstChild(REMOTE_EVENT_NAME)
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = REMOTE_EVENT_NAME
	remoteEvent.Parent = ReplicatedStorage
end

local WalletHandler = {}

local playerWallets = {}

function WalletHandler:InitializePlayerWallet(player)
	local wallet = Wallet.new(player, remoteEvent)
	playerWallets[player.UserId] = wallet

	local success, storedData = pcall(function()
		return WalletStore:GetAsync(player.UserId)
	end)

	if success and storedData then
		wallet:SetBalance(storedData.Wallet or 0)
		wallet:SetBankBalance(storedData.Bank or 0)
	else
		wallet:Reset()
	end

	print("Initialized wallet for " .. player.Name .. ": Wallet = " .. wallet:GetBalance() .. ", Bank = " .. wallet:GetBankBalance())
end

function WalletHandler:SavePlayerWallet(player)
	local wallet = playerWallets[player.UserId]
	if not wallet then
		warn("No wallet to save for " .. player.Name)
		return
	end

	local success, err = pcall(function()
		WalletStore:SetAsync(player.UserId, {
			Wallet = wallet:GetBalance(),
			Bank = wallet:GetBankBalance()
		})
	end)

	if success then
		print("Saved wallet for " .. player.Name)
	else
		warn("Failed to save wallet for " .. player.Name .. ": " .. tostring(err))
	end
end

function WalletHandler:DestroyPlayerWallet(player)
	local wallet = playerWallets[player.UserId]
	if wallet then
		wallet:Destroy()
		playerWallets[player.UserId] = nil
	end
end

function WalletHandler:GetWalletForPlayer(player)
	return playerWallets[player.UserId]
end

function WalletHandler:AddFunds(player, amount)
	local wallet = self:GetWalletForPlayer(player)
	if wallet then
		wallet:AddFunds(amount)
		return true
	else
		warn("[WalletHandler:AddFunds] No wallet for " .. player.Name)
		return false
	end
end

function WalletHandler:RemoveFunds(player, amount)
	local wallet = self:GetWalletForPlayer(player)
	if wallet then
		wallet:RemoveFunds(amount)
		return true
	else
		warn("[WalletHandler:RemoveFunds] No wallet for " .. player.Name)
		return false
	end
end

function WalletHandler:SetFunds(player, amount)
	local wallet = self:GetWalletForPlayer(player)
	if wallet then
		wallet:SetBalance(amount)
		return true
	else
		warn("[WalletHandler:SetFunds] No wallet for " .. player.Name)
		return false
	end
end

function WalletHandler:AddBankFunds(player, amount)
	local wallet = self:GetWalletForPlayer(player)
	if wallet then
		wallet:AddBankFunds(amount)
		return true
	else
		warn("[WalletHandler:AddBankFunds] No wallet for " .. player.Name)
		return false
	end
end

function WalletHandler:RemoveBankFunds(player, amount)
	local wallet = self:GetWalletForPlayer(player)
	if wallet then
		wallet:RemoveBankFunds(amount)
		return true
	else
		warn("[WalletHandler:RemoveBankFunds] No wallet for " .. player.Name)
		return false
	end
end

function WalletHandler:SetBankFunds(player, amount)
	local wallet = self:GetWalletForPlayer(player)
	if wallet then
		wallet:SetBankBalance(amount)
		return true
	else
		warn("[WalletHandler:SetBankFunds] No wallet for " .. player.Name)
		return false
	end
end

function WalletHandler:Setup()
	Players.PlayerAdded:Connect(function(player)
		self:InitializePlayerWallet(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:SavePlayerWallet(player)
		self:DestroyPlayerWallet(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:InitializePlayerWallet(player)
	end
end

return WalletHandler
