local Human = {}
Human.__index = Human

function Human.new(model)
    local self = setmetatable({}, Human)
    self.Model = model
    self.Humanoid = model:FindFirstChildOfClass("Humanoid") or nil
    self.Head = model:FindFirstChild("Head") or nil
    self.LeftUpperArm = model:FindFirstChild("LeftUpperArm") or nil
    self.RightUpperArm = model:FindFirstChild("RightUpperArm") or nil
    self.LeftUpperLeg = model:FindFirstChild("LeftUpperLeg") or nil
    self.RightUpperLeg = model:FindFirstChild("RightUpperLeg") or nil
    self.LeftHand = model:FindFirstChild("LeftHand") or nil
    self.RightHand = model:FindFirstChild("RightHand") or nil
    self.LeftFoot = model:FindFirstChild("LeftFoot") or nil
    self.RightFoot = model:FindFirstChild("RightFoot") or nil
    self.LeftLowerArm = model:FindFirstChild("LeftLowerArm") or nil
    self.RightLowerArm = model:FindFirstChild("RightLowerArm") or nil
    self.LeftLowerLeg = model:FindFirstChild("LeftLowerLeg") or nil
    self.RightLowerLeg = model:FindFirstChild("RightLowerLeg") or nil
    self.UpperTorso = model:FindFirstChild("UpperTorso") or nil
    self.LowerTorso = model:FindFirstChild("LowerTorso") or nil
end

function Human:Update()
    self.Humanoid = self.Model:FindFirstChildOfClass("Humanoid") or nil
    self.Head = self.Model:FindFirstChild("Head") or nil
    self.LeftUpperArm = self.Model:FindFirstChild("LeftUpperArm") or nil
    self.RightUpperArm = self.Model:FindFirstChild("RightUpperArm") or nil
    self.LeftUpperLeg = self.Model:FindFirstChild("LeftUpperLeg") or nil
    self.RightUpperLeg = self.Model:FindFirstChild("RightUpperLeg") or nil
    self.LeftHand = self.Model:FindFirstChild("LeftHand") or nil
    self.RightHand = self.Model:FindFirstChild("RightHand") or nil
    self.LeftFoot = self.Model:FindFirstChild("LeftFoot") or nil
    self.RightFoot = self.Model:FindFirstChild("RightFoot") or nil
    self.LeftLowerArm = self.Model:FindFirstChild("LeftLowerArm") or nil
    self.RightLowerArm = self.Model:FindFirstChild("RightLowerArm") or nil
    self.LeftLowerLeg = self.Model:FindFirstChild("LeftLowerLeg") or nil
    self.RightLowerLeg = self.Model:FindFirstChild("RightLowerLeg") or nil
    self.UpperTorso = self.Model:FindFirstChild("UpperTorso") or nil
    self.LowerTorso = self.Model:FindFirstChild("LowerTorso") or nil
end

-- Update methods for each body part
function Human:UpdateHead(newHead)
    if newHead then
        self.Head = newHead
        self.Model.Head = newHead
    else
        self.Head = nil
        self.Model.Head = nil
    end
end

function Human:UpdateLeftUpperArm(newLeftUpperArm)
    if newLeftUpperArm then
        self.LeftUpperArm = newLeftUpperArm
        self.Model.LeftUpperArm = newLeftUpperArm
    else
        self.LeftUpperArm = nil
        self.Model.LeftUpperArm = nil
    end
end

function Human:UpdateRightUpperArm(newRightUpperArm)
    if newRightUpperArm then
        self.RightUpperArm = newRightUpperArm
        self.Model.RightUpperArm = newRightUpperArm
    else
        self.RightUpperArm = nil
        self.Model.RightUpperArm = nil
    end
end

function Human:UpdateLeftUpperLeg(newLeftUpperLeg)
    if newLeftUpperLeg then
        self.LeftUpperLeg = newLeftUpperLeg
        self.Model.LeftUpperLeg = newLeftUpperLeg
    else
        self.LeftUpperLeg = nil
        self.Model.LeftUpperLeg = nil
    end
end

function Human:UpdateRightUpperLeg(newRightUpperLeg)
    if newRightUpperLeg then
        self.RightUpperLeg = newRightUpperLeg
        self.Model.RightUpperLeg = newRightUpperLeg
    else
        self.RightUpperLeg = nil
        self.Model.RightUpperLeg = nil
    end
end

function Human:UpdateLeftHand(newLeftHand)
    if newLeftHand then
        self.LeftHand = newLeftHand
        self.Model.LeftHand = newLeftHand
    else
        self.LeftHand = nil
        self.Model.LeftHand = nil
    end
end

function Human:UpdateRightHand(newRightHand)
    if newRightHand then
        self.RightHand = newRightHand
        self.Model.RightHand = newRightHand
    else
        self.RightHand = nil
        self.Model.RightHand = nil
    end
end

function Human:UpdateLeftFoot(newLeftFoot)
    if newLeftFoot then
        self.LeftFoot = newLeftFoot
        self.Model.LeftFoot = newLeftFoot
    else
        self.LeftFoot = nil
        self.Model.LeftFoot = nil
    end
end

function Human:UpdateRightFoot(newRightFoot)
    if newRightFoot then
        self.RightFoot = newRightFoot
        self.Model.RightFoot = newRightFoot
    else
        self.RightFoot = nil
        self.Model.RightFoot = nil
    end
end

function Human:UpdateLeftLowerArm(newLeftLowerArm)
    if newLeftLowerArm then
        self.LeftLowerArm = newLeftLowerArm
        self.Model.LeftLowerArm = newLeftLowerArm
    else
        self.LeftLowerArm = nil
        self.Model.LeftLowerArm = nil
    end
end

function Human:UpdateRightLowerArm(newRightLowerArm)
    if newRightLowerArm then
        self.RightLowerArm = newRightLowerArm
        self.Model.RightLowerArm = newRightLowerArm
    else
        self.RightLowerArm = nil
        self.Model.RightLowerArm = nil
    end
end

function Human:UpdateLeftLowerLeg(newLeftLowerLeg)
    if newLeftLowerLeg then
        self.LeftLowerLeg = newLeftLowerLeg
        self.Model.LeftLowerLeg = newLeftLowerLeg
    else
        self.LeftLowerLeg = nil
        self.Model.LeftLowerLeg = nil
    end
end

function Human:UpdateRightLowerLeg(newRightLowerLeg)
    if newRightLowerLeg then
        self.RightLowerLeg = newRightLowerLeg
        self.Model.RightLowerLeg = newRightLowerLeg
    else
        self.RightLowerLeg = nil
        self.Model.RightLowerLeg = nil
    end
end

function Human:UpdateUpperTorso(newUpperTorso)
    if newUpperTorso then
        self.UpperTorso = newUpperTorso
        self.Model.UpperTorso = newUpperTorso
    else
        self.UpperTorso = nil
        self.Model.UpperTorso = nil
    end
end

function Human:UpdateLowerTorso(newLowerTorso)
    if newLowerTorso then
        self.LowerTorso = newLowerTorso
        self.Model.LowerTorso = newLowerTorso
    else
        self.LowerTorso = nil
        self.Model.LowerTorso = nil
    end
end

return Human