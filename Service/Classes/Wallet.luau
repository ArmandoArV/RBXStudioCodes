local Wallet = {}
Wallet.__index = Wallet

function Wallet.new(player, remoteEvent)
    local self = setmetatable({}, Wallet)
    self.Player = player
    self.Balance = 0
    self.BankBalance = 0
    self._remoteEvent = remoteEvent
    return self
end

function Wallet:_fireUpdate()
    if self._remoteEvent and self.Player then
        self._remoteEvent:FireClient(self.Player, self.Balance, self.BankBalance)
    end
end

function Wallet:AddFunds(amount)
    if amount > 0 then
        self.Balance = self.Balance + amount
        print("Added " .. amount .. " to " .. self.Player.Name .. "'s wallet. New balance: " .. self.Balance)
        self:_fireUpdate()
    else
        warn("Cannot add a negative or zero amount.")
    end
end

function Wallet:RemoveFunds(amount)
    if amount > 0 and amount <= self.Balance then
        self.Balance = self.Balance - amount
        print("Removed " .. amount .. " from " .. self.Player.Name .. "'s wallet. New balance: " .. self.Balance)
        self:_fireUpdate()
    elseif amount > self.Balance then
        warn("Insufficient funds.")
    else
        warn("Cannot remove a negative or zero amount.")
    end
end

function Wallet:AddBankFunds(amount)
    if amount > 0 then
        self.BankBalance = self.BankBalance + amount
        print("Added " .. amount .. " to " .. self.Player.Name .. "'s bank. New bank balance: " .. self.BankBalance)
        self:_fireUpdate()
    else
        warn("Cannot add a negative or zero amount to bank.")
    end
end

function Wallet:RemoveBankFunds(amount)
    if amount > 0 and amount <= self.BankBalance then
        self.BankBalance = self.BankBalance - amount
        print("Removed " .. amount .. " from " .. self.Player.Name .. "'s bank. New bank balance: " .. self.BankBalance)
        self:_fireUpdate()
    elseif amount > self.BankBalance then
        warn("Insufficient bank funds.")
    else
        warn("Cannot remove a negative or zero amount from bank.")
    end
end

function Wallet:GetBalance()
    return self.Balance
end

function Wallet:GetBankBalance()
    return self.BankBalance
end

function Wallet:SetBalance(amount)
    if amount >= 0 then
        self.Balance = amount
        print("Set " .. self.Player.Name .. "'s wallet balance to: " .. self.Balance)
        self:_fireUpdate()
    else
        warn("Cannot set a negative wallet balance.")
    end
end

function Wallet:SetBankBalance(amount)
    if amount >= 0 then
        self.BankBalance = amount
        print("Set " .. self.Player.Name .. "'s bank balance to: " .. self.BankBalance)
        self:_fireUpdate()
    else
        warn("Cannot set a negative bank balance.")
    end
end

function Wallet:Reset()
    self.Balance = 0
    self.BankBalance = 0
    print("Reset " .. self.Player.Name .. "'s wallet and bank balances to 0.")
    self:_fireUpdate()
end

function Wallet:Destroy()
    print("Destroying " .. self.Player.Name .. "'s wallet.")
    self.Player = nil
    self.Balance = nil
    self.BankBalance = nil
    self._remoteEvent = nil
end

return Wallet
