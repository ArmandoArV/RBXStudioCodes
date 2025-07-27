-- TurfsUI.lua
local TurfsUI = {}
TurfsUI.__index = TurfsUI

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GangMenu = script.Parent.Parent
local Background = GangMenu:WaitForChild("GUIs").TeamFrame.Config.Frame:WaitForChild("Gangs")
local Frames = Background
local template = Frames:FindFirstChild("TURFS"):FindFirstChild("FrameToDuplicate"):Clone()
local DEBUG_PREFIX = "[TurfsUI]"

-- Internal debug print
local function defaultDebugPrint(...)
	print(DEBUG_PREFIX, ...)
end

-- Constructor
function TurfsUI.new(frames, debugPrint)
	local self = setmetatable({}, TurfsUI)
	self.Frames = frames
	self.DebugPrint = debugPrint or defaultDebugPrint
	self.Connections = {} -- Store connections for cleanup
	return self
end

-- Correctly named method
function TurfsUI:PopulateTurfsUI()
	local TurfsFrame = self.Frames:FindFirstChild("TURFS")
	if not TurfsFrame then
		warn("[TurfsUI] No TURFS frame found")
		return
	end

	local BackgroundFrame = TurfsFrame
	if not BackgroundFrame then
		warn("[TurfsUI] No Background in TURFS frame")
		return
	end

	if not BackgroundFrame:IsA("ScrollingFrame") then
		warn("[TurfsUI] Background is not a ScrollingFrame! Fix in Studio.")
	end
	
	if not template then
		warn("[TurfsUI] FrameToDuplicate not found")
		return
	end
	-- Clear old rows
	for _, child in ipairs(BackgroundFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	local layout = BackgroundFrame:FindFirstChildOfClass("UIListLayout")
	--if not layout then
	--	layout = Instance.new("UIListLayout")
	--	layout.Parent = BackgroundFrame
	--	layout.SortOrder = Enum.SortOrder.LayoutOrder
	--	layout.Padding = UDim.new(0, 6)
	--end
	-- Get CapturePoints
	local folder = ReplicatedStorage:WaitForChild("CapturePoints")
	local capturePoints = folder:GetChildren()

	self.DebugPrint("Found capture points:", #capturePoints)


	local rowCount = 0
	for _, cpFolder in ipairs(capturePoints) do
		local name = cpFolder.Name
		local location = cpFolder:FindFirstChild("Location") and cpFolder.Location.Value or "?"
		local occupied = cpFolder:FindFirstChild("Occupied") and cpFolder.Occupied.Value or false
		local team = cpFolder:FindFirstChild("Team") and cpFolder.Team.Value or "None"

		local row = template:Clone()
		row.Name = name .. "Row"
		row.Visible = true
		row.Parent = BackgroundFrame
		row.Title.Text = name
		local ownedBox = row:FindFirstChild("Owned")
		local payTitleBox = row:FindFirstChild("Pay")

		if ownedBox and ownedBox:IsA("TextLabel") then
			if team ~= "None" and occupied then
				ownedBox.Text = team
				ownedBox.TextColor3 = Color3.fromRGB(85, 255, 127) -- Green for occupied
			else
				ownedBox.Text = "Disponible"
				ownedBox.TextColor3 = Color3.fromRGB(255, 85, 85) -- Red for unoccupied
			end
		else
			warn("[TurfsUI] Owned TextBox missing in row", row.Name)
		end

		if payTitleBox and payTitleBox:IsA("TextLabel") then
			local status = occupied and "Ocupado" or "Libre"
			payTitleBox.Text = "Ubicación: " .. location .. " | Estado: " .. status .. " | $100/min"
		else
			warn("[TurfsUI] PayTitle TextBox missing in row", row.Name)
		end

		rowCount = rowCount + 1

	end

	if BackgroundFrame:IsA("ScrollingFrame") and layout then
		BackgroundFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end

	self.DebugPrint("Total rows created:", rowCount)
end

-- Setup automatic updates when capture points change
function TurfsUI:SetupAutoUpdate()
	local folder = ReplicatedStorage:WaitForChild("CapturePoints")
	
	-- Listen for changes to the capture points folder
	local function onCapturePointChange()
		self.DebugPrint("Capture points changed, refreshing UI...")
		-- Use pcall to handle potential errors during UI update
		local success, err = pcall(function()
			self:PopulateTurfsUI()
		end)
		if not success then
			warn("[TurfsUI] Error updating UI:", err)
		end
	end
	
	-- Connect to folder changes
	table.insert(self.Connections, folder.ChildAdded:Connect(onCapturePointChange))
	table.insert(self.Connections, folder.ChildRemoved:Connect(onCapturePointChange))
	
	-- Listen for changes to individual capture point properties
	local function setupCapturePointListeners(cpFolder)
		if cpFolder:IsA("Folder") then
			local teamValue = cpFolder:FindFirstChild("Team")
			local occupiedValue = cpFolder:FindFirstChild("Occupied")
			
			if teamValue then
				table.insert(self.Connections, teamValue.Changed:Connect(onCapturePointChange))
			end
			
			if occupiedValue then
				table.insert(self.Connections, occupiedValue.Changed:Connect(onCapturePointChange))
			end
		end
	end
	
	-- Setup listeners for existing capture points
	for _, cpFolder in ipairs(folder:GetChildren()) do
		setupCapturePointListeners(cpFolder)
	end
	
	-- Listen for new capture points being added
	table.insert(self.Connections, folder.ChildAdded:Connect(function(child)
		-- Wait for child properties to be set
		task.wait(0.1)
		setupCapturePointListeners(child)
		onCapturePointChange()
	end))
	
	self.DebugPrint("Auto-update system initialized")
end

-- Cleanup connections
function TurfsUI:Cleanup()
	for _, connection in ipairs(self.Connections) do
		if connection then
			connection:Disconnect()
		end
	end
	self.Connections = {}
	self.DebugPrint("Cleanup completed")
end

return TurfsUI
