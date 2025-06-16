local Podium = {}
Podium.__index = Podium

function Podium.new(model)
    local self = setmetatable({}, Podium)
    self.Model = model
    self.Id = model:FindFirstChild("PodiumNumber") and model.PodiumNumber.Value or nil
    self.Owner = model:FindFirstChild("Owner") and model.Owner.Value or nil
    self.IsOpen = model:FindFirstChild("IsOpen") and model.IsOpen.Value or nil
    return self
end

function Podium:Update()
    self.Owner = self.Model:FindFirstChild("Owner") and self.Model.Owner.Value or nil
    self.IsOpen = self.Model:FindFirstChild("IsOpen") and self.Model.IsOpen.Value or nil
end

function Podium:PrintInfo()
    print("Podium ID:", self.Id, "Owner:", self.Owner, "IsOpen:", self.IsOpen)
end

return Podium