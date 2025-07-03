local Locker = {}
Locker.__index = Locker

function Locker.new(model)
    local self = setmetatable({}, Locker)
    self.Model = model

    return self
end

function Locker:Open()
    if self.Model and self.Model:FindFirstChild("Walls") then
        for _, wall in ipairs(self.Model.Walls:GetChildren()) do
            if wall:IsA("BasePart") then
                wall.CanCollide = false
            end
        end
    end
end

function Locker:Close()
    if self.Model and self.Model:FindFirstChild("Walls") then
        for _, wall in ipairs(self.Model.Walls:GetChildren()) do
            if wall:IsA("BasePart") then
                wall.CanCollide = true
            end
        end
    end
end

return Locker