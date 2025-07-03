local rs = game:GetService("ReplicatedStorage")
local dataStore = game:GetService("DataStoreService")
local saveSlot = rs.SaveSlot
local loadSlot = rs.LoadSlot
local loadslotserver = rs.LoadEvent
local slotStore = dataStore:GetDataStore("SlotStore")

function weldParts(part0, part1)
    local newWeld = Instance.new("Weld")
    newWeld.Part0 = part0
    newWeld.Part1 = part1
    newWeld.C0 = CFrame.new()
    newWeld.C1 = part1.CFrame:toObjectSpace(part0.CFrame)
    newWeld.Parent = part0
end

local function equipItem(player, itemName, partName, alreadyselected)
    local team = player.Team.Name
    local lockerStorage = rs:WaitForChild("Locker"):WaitForChild(team)
    local character = player.Character or player.CharacterAdded:Wait()
    if not partName or not itemName then
        return
    end
    local bodyPart = character:FindFirstChild(partName)
    if not bodyPart then
        return
    end

    local partFolder = lockerStorage:FindFirstChild(partName)

    local item = partFolder:FindFirstChild(itemName)
    local subfolderName = nil

    if not item then
        for _, subfolder in pairs(partFolder:GetChildren()) do
            if subfolder:IsA("Folder") then
                item = subfolder:FindFirstChild(itemName)
                if item then
                    subfolderName = subfolder.Name
                    break
                end
            end
        end
    end

    local newModel = item:Clone()

    if newModel:IsA("Model") then
        if alreadyselected == true then
            for i, v in pairs(character:GetChildren()) do
                if v:IsA("Model") and
                    (v.Name == partName .. " Accessory" or (subfolderName and v.Name == subfolderName .. " Accessory")) then
                    v:Destroy()
                end
            end

            for _, part in pairs(newModel:GetChildren()) do
                if part:IsA("ScreenGui") and player.PlayerGui:FindFirstChild(part.Name) then
                    player.PlayerGui:FindFirstChild(part.Name):Destroy()
                end
            end
        else
            local ogname = Instance.new("StringValue")
            ogname.Value = newModel.Name
            ogname.Name = "OGName"
            ogname.Parent = newModel

            local ogteam = Instance.new("StringValue")
            ogteam.Value = team
            ogteam.Name = "OGTeam"
            ogteam.Parent = newModel

            newModel.Name = subfolderName and (subfolderName .. " Accessory") or (partName .. " Accessory")

            for i, v in pairs(character:GetChildren()) do
                if v:IsA("Model") and
                    (v.Name == partName .. " Accessory" or (subfolderName and v.Name == subfolderName .. " Accessory")) then
                    v:Destroy()
                end
            end

            newModel.PrimaryPart = newModel:FindFirstChild(partName)
            if newModel.PrimaryPart then
                newModel:SetPrimaryPartCFrame(bodyPart.CFrame)
                newModel.PrimaryPart:Destroy()

                for _, part in pairs(newModel:GetChildren()) do
                    if part:IsA("BasePart") then
                        weldParts(bodyPart, part)
                        part.CanCollide = false
                        part.Anchored = false
                    elseif part:IsA("ScreenGui") then
                        if player.PlayerGui:FindFirstChild(part.Name) then
                            player.PlayerGui:FindFirstChild(part.Name):Destroy()
                        end
                        part.Parent = player.PlayerGui
                    end
                end

                newModel.Parent = character

                if partName == "UpperTorso" then
                    if character:FindFirstChild("TorsoProtectMultiplier") then
                        character.TorsoProtectMultiplier:Destroy()
                    end
                    local TorsoProtectMultiplier = Instance.new("NumberValue")
                    TorsoProtectMultiplier.Name = "TorsoProtectMultiplier"
                    TorsoProtectMultiplier.Value = 0.6
                    TorsoProtectMultiplier.Parent = character
                elseif partName == "Head" then
                    if character:FindFirstChild("HeadProtectMultiplier") then
                        character.HeadProtectMultiplier:Destroy()
                    end
                    local HeadProtectMultiplier = Instance.new("NumberValue")
                    HeadProtectMultiplier.Name = "HeadProtectMultiplier"
                    HeadProtectMultiplier.Value = 0.3
                    HeadProtectMultiplier.Parent = character
                end
            end
        end
    elseif newModel:IsA("Shirt") then
        for i, v in pairs(character:GetChildren()) do
            if v:IsA("Shirt") or v:IsA("ShirtGraphic") then
                v:Destroy()
            end
        end
        newModel.Parent = character
    elseif newModel:IsA("Pants") then
        for i, v in pairs(character:GetChildren()) do
            if v:IsA("Pants") then
                v:Destroy()
            end
        end
        newModel.Parent = character
    end
end

rs:WaitForChild("LockerEvent").OnServerEvent:Connect(function(player, itemName, partName, alreadyselected)
    equipItem(player, itemName, partName, alreadyselected)
end)
rs:WaitForChild("PreviewEvent").OnServerEvent:Connect(function(player)
    player.PlayerGui:WaitForChild("LockerSystem"):WaitForChild("MainFrame").Visible = false
end)

local function getFormattedDateTime()
    return os.date("%d/%m/%Y - %H:%M")
end

local function savePlayerData(player, slotName, equippedAccessories, team)
    local key = player.UserId .. "_" .. slotName .. "_" .. team
    local data = {
        equippedAccessories = equippedAccessories,
        lastSaved = getFormattedDateTime()
    }
    local success, errorMessage = pcall(function()
        slotStore:SetAsync(key, data)
    end)
    if not success then
        warn("Failed to save data for", player.Name, ":", errorMessage)
    end
end

local function loadPlayerData(player, slotName, team)
    local key = player.UserId .. "_" .. slotName .. "_" .. team
    local data = slotStore:GetAsync(key)
    return data
end

saveSlot.OnServerEvent:Connect(function(player, slotName, equippedAccessories, team)
    savePlayerData(player, slotName, equippedAccessories, team)
end)

loadSlot.OnServerInvoke = function(player, slotName, team)
    return loadPlayerData(player, slotName, team)
end

loadslotserver.OnServerEvent:Connect(function(player, slotName, team)
    local data = loadPlayerData(player, slotName, team)
    if data and data.equippedAccessories then
        for partName, itemName in pairs(data.equippedAccessories) do
            equipItem(player, itemName, partName, false)
        end
    end
end)

game.Players.PlayerAdded:Connect(function(player)
    local function removeMeshes(char)
        local humanoid = char:WaitForChild("Humanoid")
        wait()
        local currentDescription = humanoid:GetAppliedDescription()

        -- Set all body part mesh IDs to 0 to remove custom meshes
        currentDescription.Head = 0
        currentDescription.Torso = 0
        currentDescription.LeftArm = 0
        currentDescription.RightArm = 0
        currentDescription.LeftLeg = 0
        currentDescription.RightLeg = 0

        humanoid:ApplyDescription(currentDescription)
    end

    -- Connect the removeMeshes function to CharacterAppearanceLoaded
    player.CharacterAppearanceLoaded:Connect(removeMeshes)
end)
