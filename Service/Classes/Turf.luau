local Turf = {}
Turf.__index = Turf

function Turf.new(name, owner, location)
    local self = setmetatable({}, Turf)
    self.Name = name
    self.payment = 0 -- Initial payment for the turf
    self.Owner = owner -- Player who owns the turf
    self.Location = location -- Vector3 or CFrame for the turf's position
    self.Occupied = false -- Whether the turf is currently occupied
    self.Defenders = {} -- List of players defending the turf
    print("Turf created: " .. self.Name .. " owned by: " .. owner.Name)
    return self
end

function Turf:SetOwner(player)
    self.Owner = player
    print(player.Name .. " is now the owner of the turf: " .. self.Name)
end

function Turf:AddDefender(player)
    if not self.Defenders[player.UserId] then
        self.Defenders[player.UserId] = player
        print(player.Name .. " is now defending the turf: " .. self.Name)
    else
        warn(player.Name .. " is already defending the turf: " .. self.Name)
    end
end

function Turf:RemoveDefender(player)
    if self.Defenders[player.UserId] then
        self.Defenders[player.UserId] = nil
        print(player.Name .. " has stopped defending the turf: " .. self.Name)
    else
        warn(player.Name .. " is not defending the turf: " .. self.Name)
    end
end

function Turf:IsDefender(player)
    return self.Defenders[player.UserId] ~= nil
end

function Turf:GetDefenders()
    local defenderList = {}
    for _, defender in pairs(self.Defenders) do
        table.insert(defenderList, defender)
    end
    return defenderList
end

function Turf:GetInfo()
    return {
        Name = self.Name,
        Owner = self.Owner and self.Owner.Name or "None",
        Location = self.Location,
        Occupied = self.Occupied,
        Defenders = self:GetDefenders()
    }
end

function Turf:SetOccupied(status)
    self.Occupied = status
    print("Turf " .. self.Name .. " is now " .. (status and "occupied" or "not occupied"))
end

function Turf:SetPayment(amount)
    self.payment = amount
    print("Payment for turf " .. self.Name .. " set to $" .. amount)
end

function Turf:GetPayment()
    return self.payment
end

function Turf:Reset()
    self.Occupied = false
    self.Defenders = {}
    print("Turf " .. self.Name .. " has been reset")
end

return Turf
