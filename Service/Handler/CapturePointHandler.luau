
local CapturePointHandler = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Wallet = require(ReplicatedStorage:WaitForChild("Classes"):WaitForChild("Wallet"))

local CapturePointEvent = ReplicatedStorage:FindFirstChild("CapturePointEvent")
if not CapturePointEvent then
    CapturePointEvent = Instance.new("RemoteEvent")
    CapturePointEvent.Name = "CapturePointEvent"
    CapturePointEvent.Parent = ReplicatedStorage
end

-- Settings
local MONEY_PER_SECOND = 10 -- Change as needed
local CAPTURE_RADIUS = 10 -- studs

-- Internal state for money generation
local activeCaptureLoops = {}

-- Utility: Find players on a capture point
local function getPlayersOnPoint(location)
    local playersOnPoint = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local dist = (character.HumanoidRootPart.Position - location).Magnitude
            if dist <= CAPTURE_RADIUS then
                table.insert(playersOnPoint, player)
            end
        end
    end
    return playersOnPoint
end

-- Start money generation for a capture point
local function startMoneyLoop(capturePoint)
    if activeCaptureLoops[capturePoint] then return end
    activeCaptureLoops[capturePoint] = true
    coroutine.wrap(function()
        while activeCaptureLoops[capturePoint] and capturePoint:IsOccupied() do
            local team = capturePoint.OccupyingTeam
            if team then
                -- Distribute money to all players on the team
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Team == team then
                        Wallet:AddMoney(player, MONEY_PER_SECOND)
                    end
                end
                -- Fire UI update
                CapturePointEvent:FireAllClients("UpdateCapturePointUI", {
                    Name = capturePoint.Name,
                    Owner = team.Name,
                    MoneyPerSecond = MONEY_PER_SECOND
                })
            end
            wait(1)
        end
    end)()
end

-- Stop money generation for a capture point
local function stopMoneyLoop(capturePoint)
    activeCaptureLoops[capturePoint] = nil
end


-- Public: Call this to monitor a capture point part
-- 15s capture logic: player must stay on part for 15s to capture
function CapturePointHandler:MonitorCapturePointPart(part, capturePoint)
    local capturingPlayers = {}

    local function isPlayerOnPart(player)
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local root = character.HumanoidRootPart
            local partPos = part.Position
            local dist = (root.Position - partPos).Magnitude
            -- Use a more generous buffer for easier testing
            return dist <= (math.max(part.Size.X, part.Size.Z)/2 + 5)
        end
        return false
    end

    part.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)
        if player and player.Team and not capturingPlayers[player] then
            if not capturePoint:IsOccupied() or capturePoint.OccupyingTeam ~= player.Team then
                capturingPlayers[player] = true
                print("[CapturePoint] " .. player.Name .. " is capturing point '" .. capturePoint.Name .. "' for team '" .. player.Team.Name .. "' (color: " .. tostring(player.Team.TeamColor) .. ")")
                -- Start 15s timer
                coroutine.wrap(function()
                    local elapsed = 0
                    print("[CapturePoint] Timer started for " .. player.Name)
                    while elapsed < 15 do
                        if not isPlayerOnPart(player) then
                            print("[CapturePoint] " .. player.Name .. " left the point early at " .. elapsed .. "s")
                            capturingPlayers[player] = nil
                            return -- Player left, cancel capture
                        end
                        print("[CapturePoint] " .. player.Name .. " still on point at " .. elapsed .. "s")
                        wait(1)
                        elapsed = elapsed + 1
                    end
                    -- After 15s, if still on part, capture
                    if isPlayerOnPart(player) and (not capturePoint:IsOccupied() or capturePoint.OccupyingTeam ~= player.Team) then
                        capturePoint:SetOccupied(player.Team)
                        -- Set the part color to the team color
                        if part:IsA("BasePart") then
                            part.BrickColor = player.Team.TeamColor
                        end
                        print("[CapturePoint] Point '" .. capturePoint.Name .. "' captured by group/team '" .. player.Team.Name .. "' (color: " .. tostring(player.Team.TeamColor) .. ")")
                        startMoneyLoop(capturePoint)
                    end
                    capturingPlayers[player] = nil
                end)()
            end
        end
    end)
end

-- Call this to release a capture point (e.g., when no players are present)
function CapturePointHandler:ReleaseCapturePointAndStop(capturePoint)
    stopMoneyLoop(capturePoint)
    capturePoint:Release()
    CapturePointEvent:FireAllClients("UpdateCapturePointUI", {
        Name = capturePoint.Name,
        Owner = "None",
        MoneyPerSecond = 0
    })
end

local Teams = game:GetService("Teams")
local CapturePoint = require(ReplicatedStorage:WaitForChild("Classes"):WaitForChild("CapturePoint"))
local capturePointFolder = ReplicatedStorage:FindFirstChild("CapturePointObjects")
if not capturePointFolder then
    capturePointFolder = Instance.new("Folder")
    capturePointFolder.Name = "CapturePointObjects"
    capturePointFolder.Parent = ReplicatedStorage
end
local allCapturePoints = {} -- hashmap: name -> capturePoint



function CapturePointHandler:CreateCapturePoint(name, location)
    local capturePoint = CapturePoint.new(name, location)
    print("Capture Point Handler created a new capture point: " .. name)
    allCapturePoints[name] = capturePoint
    return capturePoint
end

function CapturePointHandler:OccupyCapturePoint(capturePoint, team)
    if not capturePoint:IsOccupied() then
        capturePoint:SetOccupied(team)
        print("Capture Point " .. capturePoint:GetName() .. " occupied by team: " .. team.Name)
    else
        print("Capture Point " .. capturePoint:GetName() .. " is already occupied by team: " .. capturePoint.OccupyingTeam.Name)
    end
end

function CapturePointHandler:ReleaseCapturePoint(capturePoint)
    if capturePoint:IsOccupied() then
        capturePoint:Release()
        print("Capture Point " .. capturePoint:GetName() .. " has been released")
    else
        print("Capture Point " .. capturePoint:GetName() .. " is not occupied")
    end
end

function CapturePointHandler:GetCapturePointInfo(capturePoint)
    return capturePoint:GetInfo()
end

function CapturePointHandler:SetCapturePointLocation(capturePoint, location)
    capturePoint:SetLocation(location)
    print("Capture Point " .. capturePoint:GetName() .. " location updated to: " .. tostring(location))
end

function CapturePointHandler:SetCapturePointName(capturePoint, name)
    capturePoint:SetName(name)
    print("Capture Point name updated to: " .. capturePoint:GetName())
end

function CapturePointHandler:GetCapturePointLocation(capturePoint)
    return capturePoint:GetLocation()
end

function CapturePointHandler:GetCapturePointName(capturePoint)
    return capturePoint:GetName()
end



function CapturePointHandler:GetAllCapturePoints()
    local points = {}
    for _, cp in pairs(allCapturePoints) do
        table.insert(points, cp)
    end
    return points
end

function CapturePointHandler:PrintAllCapturePoints()
    local capturePoints = self:GetAllCapturePoints()
    for _, point in pairs(capturePoints) do
        print("Capture Point: " .. point:GetName() .. ", Location: " .. tostring(point:GetLocation()) .. ", Occupied: " .. tostring(point:IsOccupied()))
    end
end

function CapturePointHandler:ClearCapturePoints()
    local capturePoints = self:GetAllCapturePoints()
    for _, point in pairs(capturePoints) do
        point:Release()
        print("Capture Point " .. point:GetName() .. " has been cleared")
    end
end

function CapturePointHandler:ResetCapturePoints()
    self:ClearCapturePoints()
    print("All capture points have been reset")
end

function CapturePointHandler:InitializeCapturePoints()
    print("Initializing Capture Points...")
    -- Here you can add logic to create default capture points or load them from a configuration
end
function CapturePointHandler:DestroyCapturePoint(capturePoint)
    if capturePoint then
        capturePoint:Release()
        print("Capture Point " .. capturePoint:GetName() .. " has been destroyed")
    else
        print("No capture point provided to destroy")
    end
end

function CapturePointHandler:FindCapturePointByName(name)
    local capturePoints = self:GetAllCapturePoints()
    for _, point in pairs(capturePoints) do
        if point:GetName() == name then
            return point
        end
    end
    print("Capture Point with name " .. name .. " not found")
    return nil
end

function CapturePointHandler:FindCapturePointByLocation(location)
    local capturePoints = self:GetAllCapturePoints()
    for _, point in pairs(capturePoints) do
        if point:GetLocation() == location then
            return point
        end
    end
    print("Capture Point at location " .. tostring(location) .. " not found")
    return nil
end

function CapturePointHandler:UpdateCapturePointOccupancy(capturePoint, team)
    if capturePoint:IsOccupied() and capturePoint.OccupyingTeam == team then
        print("Capture Point " .. capturePoint:GetName() .. " is already occupied by the same team: " .. team.Name)
    elseif capturePoint:IsOccupied() then
        print("Capture Point " .. capturePoint:GetName() .. " is occupied by another team: " .. capturePoint.OccupyingTeam.Name)
    else
        self:OccupyCapturePoint(capturePoint, team)
    end
end

function CapturePointHandler:HandleCapturePointEvent(event, capturePoint, team)
    if event == "Occupy" then
        self:OccupyCapturePoint(capturePoint, team)
    elseif event == "Release" then
        self:ReleaseCapturePoint(capturePoint)
    elseif event == "UpdateLocation" then
        self:SetCapturePointLocation(capturePoint, team.Location)
    elseif event == "UpdateName" then
        self:SetCapturePointName(capturePoint, team.Name)
    else
        print("Unknown event: " .. event)
    end
end

function CapturePointHandler:LogCapturePointEvent(event, capturePoint, team)
    print("Event: " .. event .. ", Capture Point: " .. capturePoint:GetName() .. ", Team: " .. (team and team.Name or "None"))
end

function CapturePointHandler:CapturePointExists(capturePoint)
    return capturePoint and capturePoint:IsA("CapturePoint")
end

function CapturePointHandler:CapturePointIsOccupied(capturePoint)
    return capturePoint and capturePoint:IsOccupied()
end

function CapturePointHandler:CapturePointGetOccupyingTeam(capturePoint)
    return capturePoint and capturePoint.OccupyingTeam or nil
end

function CapturePointHandler:CapturePointGetInfo(capturePoint)
    return capturePoint and capturePoint:GetInfo() or nil
end

function CapturePointHandler:CapturePointGetLocation(capturePoint)
    return capturePoint and capturePoint:GetLocation() or nil
end

function CapturePointHandler:CapturePointGetName(capturePoint)
    return capturePoint and capturePoint:GetName() or nil
end

function CapturePointHandler:CapturePointSetLocation(capturePoint, location)
    if capturePoint then
        capturePoint:SetLocation(location)
    else
        print("No capture point provided to set location")
    end
end

function CapturePointHandler:CapturePointSetName(capturePoint, name)
    if capturePoint then
        capturePoint:SetName(name)
    else
        print("No capture point provided to set name")
    end
end

function CapturePointHandler:CapturePointReset(capturePoint)
    if capturePoint then
        capturePoint:Release()
        print("Capture Point " .. capturePoint:GetName() .. " has been reset")
    else
        print("No capture point provided to reset")
    end
end

function CapturePointHandler:CapturePointDestroy(capturePoint)
    if capturePoint then
        capturePoint:Release()
        print("Capture Point " .. capturePoint:GetName() .. " has been destroyed")
    else
        print("No capture point provided to destroy")
    end
end

return CapturePointHandler