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

-- Group bonus configuration
local TARGET_GROUP_ID = 5101519 -- Group ID that gets capture bonuses
local BONUS_PER_CAPTURE_POINT = 500 -- Money bonus per captured point

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

-- Function to create or update UI for a capture point
local function createCapturePointUI(part, capturePoint)
	-- Remove existing UI if it exists
	local existingUI = part:FindFirstChild("CapturePointUI")
	if existingUI then
		existingUI:Destroy()
	end
	
	-- Create BillboardGui
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "CapturePointUI"
	billboardGui.Size = UDim2.new(0, 200, 0, 100)
	billboardGui.StudsOffset = Vector3.new(0, part.Size.Y/2 + 3, 0)
	billboardGui.Parent = part
	billboardGui.MaxDistance = 50
	-- Create main frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Parent = billboardGui
	
	-- Add corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
	
	-- Create stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 2
	stroke.Parent = frame
	
	-- Create title label (capture point name)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = capturePoint:GetName()
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = frame
	
	-- Create owner label
	local ownerLabel = Instance.new("TextLabel")
	ownerLabel.Name = "OwnerLabel"
	ownerLabel.Size = UDim2.new(1, 0, 0.5, 0)
	ownerLabel.Position = UDim2.new(0, 0, 0.5, 0)
	ownerLabel.BackgroundTransparency = 1
	ownerLabel.Text = capturePoint:IsOccupied() and capturePoint.OccupyingTeam.Name or "Disponible"
	ownerLabel.TextColor3 = capturePoint:IsOccupied() and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(255, 85, 85)
	ownerLabel.TextScaled = true
	ownerLabel.Font = Enum.Font.Gotham
	ownerLabel.Parent = frame
	
	print("[CapturePointHandler] Created UI for capture point: " .. capturePoint:GetName())
	return billboardGui
end

-- Function to update capture point UI
local function updateCapturePointUI(part, capturePoint)
	local ui = part:FindFirstChild("CapturePointUI")
	if ui then
		local frame = ui:FindFirstChild("Frame")
		if frame then
			local ownerLabel = frame:FindFirstChild("OwnerLabel")
			if ownerLabel then
				ownerLabel.Text = capturePoint:IsOccupied() and capturePoint.OccupyingTeam.Name or "Disponible"
				ownerLabel.TextColor3 = capturePoint:IsOccupied() and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(255, 85, 85)
				print("[CapturePointHandler] Updated UI for capture point: " .. capturePoint:GetName())
			end
		end
	else
		-- Create UI if it doesn't exist
		createCapturePointUI(part, capturePoint)
	end
end


-- Public: Call this to monitor a capture point part
-- 15s capture logic: player must stay on part for 15s to capture
function CapturePointHandler:MonitorCapturePointPart(part, capturePoint)
	local capturingPlayers = {}
	
	-- Store part reference in capture point for UI updates
	capturePoint.Part = part
	
	-- Create initial UI for this capture point
	createCapturePointUI(part, capturePoint)

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
						CapturePointHandler:OccupyCapturePoint(capturePoint, player.Team, part)
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
	capturePoint.Part = nil -- Will be set when MonitorCapturePointPart is called
	print("Capture Point Handler created a new capture point: " .. name .. ", MoneyPerMinute: " .. tostring(capturePoint.MoneyPerMinute))
	allCapturePoints[name] = capturePoint
	return capturePoint
end

-- Function to count how many capture points a team controls
local function getTeamCapturedPointsCount(team)
	local count = 0
	for _, cp in pairs(allCapturePoints) do
		if cp:IsOccupied() and cp.OccupyingTeam == team then
			count = count + 1
		end
	end
	return count
end

-- Function to give bonus money to team members based on captured points
local function giveCaptureBonus(team, capturedPoints)
	-- Safety check to prevent zero or negative bonuses
	if capturedPoints <= 0 then
		print("[CapturePointHandler] Error: Cannot give bonus for " .. capturedPoints .. " points")
		return
	end
	
	local totalBonus = BONUS_PER_CAPTURE_POINT * capturedPoints
	
	print("[CapturePointHandler] Giving capture bonus: $" .. totalBonus .. " to team " .. team.Name .. " for " .. capturedPoints .. " points")
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team == team then
			WalletHandler:AddFunds(player, totalBonus)
			SendNotification:FireClient(player, {
				Title = "BONO DE CAPTURA",
				Text = "Ganaste $" .. totalBonus .. " por controlar " .. capturedPoints .. " territorio(s)",
				Icon = "rbxassetid://6022668892",
				Duration = 6
			})
			print("[CapturePointHandler] Gave $" .. totalBonus .. " capture bonus to " .. player.Name)
		end
	end
end

function CapturePointHandler:OccupyCapturePoint(capturePoint, team, part)
	if not capturePoint:IsOccupied() then
		capturePoint:SetOccupied(team)
		print("Capture Point " .. capturePoint:GetName() .. " occupied by team: " .. team.Name)
		
		-- Update UI if part is provided, or use stored part reference
		if part then
			updateCapturePointUI(part, capturePoint)
		elseif capturePoint.Part then
			updateCapturePointUI(capturePoint.Part, capturePoint)
		end
		
		-- Send notification to all players about the capture
		for _, player in ipairs(Players:GetPlayers()) do
			SendNotification:FireClient(player, {
				Title = "TERRITORIO CAPTURADO",
				Text = "La gang " .. team.Name .. " ha capturado " .. capturePoint:GetName(),
				Icon = "rbxassetid://6022668892",
				Duration = 5
			})
		end
		
		-- Start money generation for this capture point (for ALL teams)
		startMoneyLoop(capturePoint)
		
		-- Check if the capturing team belongs to target group and give ADDITIONAL bonus
		local isTargetGroup = false
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Team == team then
				-- Use pcall to safely check group membership
				local success, isInGroup = pcall(function()
					return player:IsInGroup(TARGET_GROUP_ID)
				end)
				if success and isInGroup then
					isTargetGroup = true
					print("[CapturePointHandler] Found player " .. player.Name .. " in target group " .. TARGET_GROUP_ID)
					break
				end
			end
		end
		
		-- If team belongs to target group, give ADDITIONAL capture bonus
		if isTargetGroup then
			-- Count captured points AFTER this point has been marked as occupied
			local capturedPoints = getTeamCapturedPointsCount(team)
			print("[CapturePointHandler] Target group team captured point. Total controlled points: " .. capturedPoints)
			
			-- Only give bonus if there are actually captured points
			if capturedPoints > 0 then
				print("[CapturePointHandler] Giving ADDITIONAL bonus to group " .. TARGET_GROUP_ID)
				giveCaptureBonus(team, capturedPoints)
			else
				print("[CapturePointHandler] No captured points found for bonus calculation - this shouldn't happen!")
			end
		else
			print("[CapturePointHandler] Team " .. team.Name .. " gets regular money generation only (not in target group " .. TARGET_GROUP_ID .. ")")
		end
		
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
		
		-- Update UI if part exists
		if capturePoint.Part then
			updateCapturePointUI(capturePoint.Part, capturePoint)
		end
		
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
		self:OccupyCapturePoint(capturePoint, team, nil)
	end
end

function CapturePointHandler:HandleCapturePointEvent(event, capturePoint, team)
	if event == "Occupy" then
		self:OccupyCapturePoint(capturePoint, team, nil)
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