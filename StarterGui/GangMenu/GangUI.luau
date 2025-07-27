-- GangUI.luau (localscript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local GangMenu = playerGui:WaitForChild("Buttons")

local GangRemoteEvent = ReplicatedStorage:WaitForChild("GangRemoteEvent")

local Modules = GangMenu:WaitForChild("Modules")
local UIManager = require(Modules:WaitForChild("UIManager"))
local GangCreation = require(Modules:WaitForChild("GangCreation"))
local GangJoining = require(Modules:WaitForChild("GangJoining"))
local TurfsUI = require(Modules:WaitForChild("TurfsUI"))
local GangInfo = require(Modules:WaitForChild("GangInfo"))

local uiManager = UIManager.new(GangMenu)
uiManager:SetupButtonConnections() -- Enable default UIManager button debug and error output

-- Simple client-side gang tracking
local isInGang = false

local function debugPrint(...)
	uiManager:DebugPrint(...)
end

print("GangUI loaded for player:", player.Name)

-- Initialize submodules
local gangCreation = GangCreation.new(uiManager.Frames, GangRemoteEvent, debugPrint)
local gangJoining = GangJoining.new(uiManager.Frames, GangRemoteEvent, debugPrint)
local turfsUI = TurfsUI.new(uiManager.Frames, debugPrint)
local gangInfo = GangInfo.new(uiManager.Frames, GangRemoteEvent, debugPrint)

print("GangMenu", GangMenu)
print("GUIs", GangMenu:FindFirstChild("GUIs"))
print("TeamFrame", GangMenu:FindFirstChild("GUIs") and GangMenu.GUIs:FindFirstChild("TeamFrame"))
print("Config", GangMenu:FindFirstChild("GUIs") and GangMenu.GUIs:FindFirstChild("TeamFrame") and
	GangMenu.GUIs.TeamFrame:FindFirstChild("Config"))
print("Frame", GangMenu:FindFirstChild("GUIs") and GangMenu.GUIs:FindFirstChild("TeamFrame") and
	GangMenu.GUIs.TeamFrame:FindFirstChild("Config") and GangMenu.GUIs.TeamFrame.Config:FindFirstChild("Frame"))
print("Gangs", GangMenu:FindFirstChild("GUIs") and GangMenu.GUIs:FindFirstChild("TeamFrame") and
	GangMenu.GUIs.TeamFrame:FindFirstChild("Config") and GangMenu.GUIs.TeamFrame.Config:FindFirstChild("Frame") and
	GangMenu.GUIs.TeamFrame.Config.Frame:FindFirstChild("Gangs"))

gangCreation:Setup()
gangJoining:Setup()
turfsUI:SetupAutoUpdate() -- Setup automatic UI updates

-- Enhanced gang detection with wait for replication
local function isPlayerInGang()
	debugPrint("checking lol")
	---- Method 1: Check client-side tracking first
	--if isInGang then
	--	debugPrint("Gang detected via client tracking")
	--	return true
	--end

	---- Method 2: Check if player has a team
	--if not player.Team then
	--	debugPrint("Player has no team")
	--	return false
	--end

	---- Method 3: Check ReplicatedStorage first (most reliable)
	--local gangsFolder = ReplicatedStorage:FindFirstChild("Gangs")
	--if gangsFolder and gangsFolder:FindFirstChild(player.Team.Name) then
	--	local gangFolder = gangsFolder:FindFirstChild(player.Team.Name)
	--	local isGangValue = gangFolder:FindFirstChild("IsGang")
	--	if isGangValue and isGangValue.Value then
	--		debugPrint("Gang detected via ReplicatedStorage:", player.Team.Name)
	--		isInGang = true
	--		return true
	--	end
	--end

	-- Method 4: Check team attributes
	if player.Team ~= nil then
		if player.Team:GetAttribute("IsGang") then
			debugPrint("Gang detected via team attribute:", player.Team.Name)
			isInGang = true
			return true
		end
	end
	debugPrint("Player is in team (or not) but not a gang")
	return false
end

-- Function to update UI based on gang status
local function updateUIForGangStatus()
	local inGang = isPlayerInGang()
	local createBtn = uiManager.Buttons:FindFirstChild("CREATE")

	debugPrint("Updating UI for gang status. In gang:", inGang)

	if inGang then
		-- Hide CREATE button if player is in a gang
		if createBtn then
			createBtn.Visible = false
		end
		debugPrint("Player is in gang - hiding CREATE button")
	else
		-- Show CREATE button if player is not in a gang
		if createBtn then
			createBtn.Visible = true
		end
		debugPrint("Player is not in gang - showing CREATE button")
	end
end

-- Button setup with gang logic
local function setupButtonConnectionsWithGangLogic()
	local turfsBtn = uiManager.Buttons:FindFirstChild("TURFS")
	local createBtn = uiManager.Buttons:FindFirstChild("CREATE")
	local menuBtn = uiManager.Buttons:FindFirstChild("MENU")

	if turfsBtn then
		turfsBtn.Toggle.MouseButton1Click:Connect(function()
			uiManager:DebugPrint("TURFS clicked")
			uiManager:ShowFrame(uiManager.Frames:FindFirstChild("TURFS"))
		end)
	end

	if createBtn then
		createBtn.Toggle.MouseButton1Click:Connect(function()
			uiManager:DebugPrint("CREATE clicked")
			uiManager:ShowFrame(uiManager.Frames:FindFirstChild("CREATE"))
		end)
	end

	if menuBtn then
		menuBtn.Toggle.MouseButton1Click:Connect(function()
			uiManager:DebugPrint("MENU clicked")
			
			-- Check if player is in a gang
			if isPlayerInGang() then
				print("true")
				-- Show GANG frame if in gang
				uiManager:ShowFrame("GANG")
			else
				-- Show JOIN frame if not in gang
				print("falkkse")
				uiManager:ShowFrame("JOIN")
			end
		end)
	end

	uiManager.Buttons.Visible = true
	updateUIForGangStatus()
end

-- Override ShowFrame to populate GANG and TURFS
local oldShowFrame = uiManager.ShowFrame
function uiManager:ShowFrame(frameToShow)
	-- Handle string inputs for GANG and JOIN
	if frameToShow == "GANG" then
		oldShowFrame(self, frameToShow)
		-- Populate GANG UI when showing GANG frame
		if isPlayerInGang() then
			-- Wait a bit for the frame to be visible
			task.spawn(function()
				task.wait(0.2)
				gangInfo:PopulateUI(player)
				debugPrint("Populated GANG UI for player:", player.Name)
			end)
		else
			debugPrint("Cannot populate GANG UI - player not in gang")
		end
	elseif frameToShow == "JOIN" then
		oldShowFrame(self, frameToShow)
	else
		oldShowFrame(self, frameToShow)
		if frameToShow == self.Frames:FindFirstChild("TURFS") then
			turfsUI:PopulateTurfsUI()
		end
	end
end

-- Set up button connections
setupButtonConnectionsWithGangLogic()

-- Show appropriate default frame based on gang status
if isPlayerInGang() then
	uiManager:ShowFrame("GANG")
else
	uiManager:ShowFrame("JOIN")
end

-- Listen for team changes
player:GetPropertyChangedSignal("Team"):Connect(function()
	debugPrint("Player team changed to:", player.Team and player.Team.Name or "None")

	-- Reset tracking when team changes
	isInGang = false

	-- Wait for potential replication
	task.spawn(function()
		task.wait(1) -- Wait for replication
		updateUIForGangStatus()

		-- Update frame display
		if isPlayerInGang() then
			uiManager:ShowFrame("GANG")
		else
			uiManager:ShowFrame("JOIN")
		end
	end)
end)

-- Listen for gang folder changes
local gangsFolder = ReplicatedStorage:WaitForChild("Gangs")
gangsFolder.ChildAdded:Connect(function(child)
	debugPrint("Gang added to ReplicatedStorage:", child.Name)
	-- Recheck gang status after a short delay
	task.spawn(function()
		task.wait(0.5)
		updateUIForGangStatus()
	end)
end)

-- Handle remote events (RESTORE ORIGINAL LOGIC)
GangRemoteEvent.OnClientEvent:Connect(function(eventType, data)
	debugPrint("Server event:", eventType, "Data:", data)

	if eventType == "GangCreated" or eventType == "GangJoined" then
		debugPrint("Success:", eventType)

		-- Mark as in gang immediately
		isInGang = true

		-- Update UI elements
		local joinFrame = uiManager.Frames:FindFirstChild("MENU").JOIN
		local createFrame = uiManager.Frames:FindFirstChild("CREATE")

		if joinFrame and joinFrame:FindFirstChild("Status") then
			joinFrame.Status.Text = "¡Haz ingresado a la Gang!"
			local joinButton = joinFrame:FindFirstChild("Join")
			if joinButton then
				if joinButton:FindFirstChild("Toggle") then
					joinButton.Toggle.Visible = true
				end
				if joinButton:FindFirstChild("Label") then
					joinButton.Label.Text = "Ingresar"
					if joinButton.Label:FindFirstChild("Shadow") then
						joinButton.Label.Shadow.Text = "Ingresar"
					end
				end
			end
		end

		if createFrame then
			local createButton = createFrame:FindFirstChild("Create")
			if createButton and createButton:FindFirstChild("Label") then
				createButton.Label.Text = "¡Gang creada exitosamente!"
			end
		end

		-- Update UI status first
		updateUIForGangStatus()

		-- Wait for replication, then show GANG frame
		task.spawn(function()
			task.wait(1) -- Wait for replication
			uiManager:ShowFrame("GANG")
		end)

	elseif eventType:find("Failed") then
		debugPrint("Failed:", data)
		local joinFrame = uiManager.Frames:FindFirstChild("MENU").JOIN
		if joinFrame and joinFrame:FindFirstChild("Status") then
			joinFrame.Status.Text = data or "Unknown error"
			local joinButton = joinFrame:FindFirstChild("Join")
			if joinButton then
				if joinButton:FindFirstChild("Toggle") then
					joinButton.Toggle.Visible = true
				end
				if joinButton:FindFirstChild("Label") then
					joinButton.Label.Text = "Ingresar"
					if joinButton.Label:FindFirstChild("Shadow") then
						joinButton.Label.Shadow.Text = "Ingresar"
					end
				end
			end
		end
	elseif eventType == "RefreshGangList" then
		debugPrint("Refreshing gang list")
		-- Recheck gang status after a short delay
		task.spawn(function()
			task.wait(0.5)
			updateUIForGangStatus()
		end)
	end
end)

debugPrint("Gang system client initialized")
