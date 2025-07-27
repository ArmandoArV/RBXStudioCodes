local CapturePointHandler = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScript = game:WaitForChild("ServerScriptService")
local WalletHandler = require(ServerScript:WaitForChild("Handler"):WaitForChild("WalletHandler"))

local CapturePointEvent = ReplicatedStorage:FindFirstChild("CapturePointEvent")
if not CapturePointEvent then
	CapturePointEvent = Instance.new("RemoteEvent")
	CapturePointEvent.Name = "CapturePointEvent"
	CapturePointEvent.Parent = ReplicatedStorage
end

-- Create SendNotification RemoteEvent if it doesn't exist
local SendNotification = ReplicatedStorage:FindFirstChild("SendNotification")
if not SendNotification then
	SendNotification = Instance.new("RemoteEvent")
	SendNotification.Name = "SendNotification"
	SendNotification.Parent = ReplicatedStorage
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
				wait(60)
				for _, player in ipairs(Players:GetPlayers()) do
					if player.Team == team then
						local amount = capturePoint.MoneyPerMinute or 100
						WalletHandler:AddFunds(player, amount)
						-- Send notification to player about money earned
						SendNotification:FireClient(player, {
							Title = "TERRITORIO",
							Text = "Ganaste $" .. amount .. " del territorio " .. capturePoint.Name,
							Icon = "rbxassetid://6022668892",
							Duration = 4
						})
					end
				end
				CapturePointEvent:FireAllClients("UpdateCapturePointUI", {
					Name = capturePoint.Name,
					Owner = team.Name,
					MoneyPerMinute = capturePoint.MoneyPerMinute or 100
				})
			else
				wait(1)
			end
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
						-- Use the proper OccupyCapturePoint method to trigger notifications and replication
						CapturePointHandler:OccupyCapturePoint(capturePoint, player.Team)
						-- Set the part color to the team color
						if part:IsA("BasePart") then
							part.BrickColor = player.Team.TeamColor
						end
						print("[CapturePoint] Point '" .. capturePoint.Name .. "' captured by group/team '" .. player.Team.Name .. "' (color: " .. tostring(player.Team.TeamColor) .. ")")
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



function CapturePointHandler:CreateCapturePoint(name, location, moneyPerMinute)
	local capturePoint = CapturePoint.new(name, location)
	capturePoint.MoneyPerMinute = moneyPerMinute or 100 -- default if not specified
	print("Capture Point Handler created a new capture point: " .. name .. ", MoneyPerMinute: " .. tostring(capturePoint.MoneyPerMinute))
	allCapturePoints[name] = capturePoint
	return capturePoint
end

function CapturePointHandler:OccupyCapturePoint(capturePoint, team)
	if not capturePoint:IsOccupied() then
		capturePoint:SetOccupied(team)
		print("Capture Point " .. capturePoint:GetName() .. " occupied by team: " .. team.Name)
		
		-- Send notification to all players about the capture
		for _, player in ipairs(Players:GetPlayers()) do
			SendNotification:FireClient(player, {
				Title = "TERRITORIO CAPTURADO",
				Text = "La gang " .. team.Name .. " ha capturado " .. capturePoint:GetName(),
				Icon = "rbxassetid://6022668892",
				Duration = 5
			})
		end
		
		-- Start money generation for this capture point
		startMoneyLoop(capturePoint)
		
		-- Update replication
		self:ReplicateCapturePoints()
	else
		print("Capture Point " .. capturePoint:GetName() .. " is already occupied by team: " .. capturePoint.OccupyingTeam.Name)
	end
end

function CapturePointHandler:ReleaseCapturePoint(capturePoint)
	if capturePoint:IsOccupied() then
		local previousTeam = capturePoint.OccupyingTeam
		capturePoint:Release()
		
		-- Stop money generation
		activeCaptureLoops[capturePoint] = nil
		
		-- Send notification about territory being lost
		if previousTeam then
			for _, player in ipairs(Players:GetPlayers()) do
				SendNotification:FireClient(player, {
					Title = "TERRITORIO PERDIDO",
					Text = "La gang " .. previousTeam.Name .. " ha perdido " .. capturePoint:GetName(),
					Icon = "rbxassetid://6022668892",
					Duration = 5
				})
			end
		end
		
		-- Update replication
		self:ReplicateCapturePoints()
		
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

-- Function to replicate capture points to ReplicatedStorage for client UI
function CapturePointHandler:ReplicateCapturePoints()
	local folder = ReplicatedStorage:FindFirstChild("CapturePoints")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "CapturePoints"
		folder.Parent = ReplicatedStorage
	end
	
	-- Clear old data
	for _, v in ipairs(folder:GetChildren()) do 
		v:Destroy() 
	end

	local capturePoints = self:GetAllCapturePoints()
	for _, cp in ipairs(capturePoints) do
		local info = cp:GetInfo()
		local cpValue = Instance.new("Folder")
		cpValue.Name = info.Name
		cpValue.Parent = folder
		
		local loc = Instance.new("StringValue")
		loc.Name = "Location"
		loc.Value = tostring(info.Location)
		loc.Parent = cpValue
		
		local occupied = Instance.new("BoolValue")
		occupied.Name = "Occupied"
		occupied.Value = info.Occupied
		occupied.Parent = cpValue
		
		local team = Instance.new("StringValue")
		team.Name = "Team"
		team.Value = info.OccupyingTeam or "None"
		team.Parent = cpValue
	end
end

return CapturePointHandler