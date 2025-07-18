local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Constants
local DEBUG_PREFIX = "[Gang Creation Debug]"
local DEFAULT_BUTTON_COLOR = Color3.new(0, 0, 0)
local ACTIVE_BUTTON_COLOR = Color3.fromRGB(45, 45, 45)

-- Cache frequently used objects
local GangMenu = script.Parent
local Buttons = GangMenu:WaitForChild("Buttons")
local Frames = GangMenu:WaitForChild("Menu")

-- Initialize RemoteEvent
local GangRemoteEvent = ReplicatedStorage:WaitForChild("GangRemoteEvent")

-- Debug function
local function debugPrint(...)
	print(DEBUG_PREFIX, ...)
end

-- UI Management
local function setButtonColors(activeButton)
	for _, button in ipairs(Buttons:GetChildren()) do
		if button:IsA("TextButton") then
			button.BackgroundColor3 = button == activeButton and ACTIVE_BUTTON_COLOR or DEFAULT_BUTTON_COLOR
		end
	end
end

local function showFrame(frameToShow)
	for _, frame in ipairs(Frames:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = frame == frameToShow
		end
	end
end

-- Button connections
local function setupButtonConnections()
	local buttonHandlers = {
		[Buttons.TURFS] = function()
			showFrame(Frames.TURFS)
			setButtonColors(Buttons.TURFS)
		end,
		[Buttons.CREATE] = function()
			showFrame(Frames.CREATE)
			setButtonColors(Buttons.CREATE)
			debugPrint("UI switched to CREATE frame")
		end,
		[Buttons.MENU] = function()
			showFrame(Frames.JOIN)
			setButtonColors(Buttons.MENU)
		end
	}

	for button, handler in pairs(buttonHandlers) do
		button.MouseButton1Click:Connect(handler)
	end
end

-- Gang Creation
local function setupGangCreation()
	local CREATEFrame = Frames.CREATE
	local groupIdInput = CREATEFrame:WaitForChild("ID")
	local groupImg = CREATEFrame:WaitForChild("IMG")
	local groupName = groupImg:WaitForChild("GroupName")
	local createButton = CREATEFrame:WaitForChild("Create")
	local availableColors = CREATEFrame:WaitForChild("AvailableColors")
	local selectedBrickColor = nil

	-- Color selection
	local function createColorButton(brickColor)
		local colorButton = Instance.new("TextButton")
		colorButton.Size = UDim2.new(1, 0, 0, 30)
		colorButton.BackgroundColor3 = brickColor.Color
		colorButton.Text = brickColor.Name
		colorButton.TextColor3 = Color3.new(1, 1, 1)
		colorButton.Font = Enum.Font.SourceSans
		colorButton.TextSize = 14

		colorButton.MouseButton1Click:Connect(function()
			selectedBrickColor = brickColor
			debugPrint("Selected BrickColor:", brickColor.Name)
		end)

		return colorButton
	end

	local function populateAvailableColors()
		debugPrint("Populating available colors")
		availableColors:ClearAllChildren()

		-- Ensure availableColors is a ScrollingFrame
		if not availableColors:IsA("ScrollingFrame") then
			warn("AvailableColors is not a ScrollingFrame! Please change it in Studio or script.")
		end

		-- Create or find UIListLayout
		local uiListLayout = availableColors:FindFirstChildOfClass("UIListLayout")
		if not uiListLayout then
			uiListLayout = Instance.new("UIListLayout")
			uiListLayout.Parent = availableColors
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.Padding = UDim.new(0, 5)  -- optional spacing between buttons
		end

		local GangColorPalette = require(ReplicatedStorage:WaitForChild("UI"):WaitForChild("GangColorPalette"))
		for index, name in ipairs(GangColorPalette) do
			local success, bc = pcall(BrickColor.new, name)
			if success and bc then
				local btn = createColorButton(bc)
				btn.LayoutOrder = index
				btn.Parent = availableColors
			else
				warn("Invalid BrickColor name:", name)
			end
		end

		-- Wait a tiny bit to let layout update
		task.wait(0.1)

		-- Update canvas size to fit all buttons
		availableColors.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
		debugPrint("AvailableColors children count after populate:", #availableColors:GetChildren())
	end


	-- Group ID validation
	local function validateGroupId(id)
		local idNum = tonumber(id)
		if not idNum then return false end

		-- Get group info from server
		local success, result = pcall(function()
			return ReplicatedStorage:WaitForChild("GetGroupName"):InvokeServer(idNum)
		end)

		if success and result then
			groupImg.Image = "rbxthumb://type=GroupIcon&id=" .. idNum .. "&w=150&h=150"
			groupName.Text = result
			return true
		else
			groupImg.Image = ""
			groupName.Text = "Invalid Group ID"
			return false
		end
	end

	groupIdInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			validateGroupId(groupIdInput.Text)
		end
	end)

	-- Gang creation
	createButton.MouseButton1Click:Connect(function()
		debugPrint("Create button clicked")

		local groupId = tonumber(groupIdInput.Text)
		local name = groupName.Text

		if not groupId or name == "" or name == "Invalid Group ID" or not selectedBrickColor then
			debugPrint("Validation failed - Missing required fields")
			return
		end

		local colorData = selectedBrickColor.Color
		debugPrint("Creating gang:", name, "Group ID:", groupId, "Color:", colorData)

		GangRemoteEvent:FireServer("CreateGang", {
			name = name,
			groupId = groupId,
			color = {
				r = colorData.R,
				g = colorData.G,
				b = colorData.B
			}
		})
	end)

	populateAvailableColors()
end

-- Gang Joining
local function setupGangJoining()
	local JOINFrame = Frames.JOIN
	local groupIdInput = JOINFrame:WaitForChild("GroupID")
	local joinButton = JOINFrame:WaitForChild("Join")
	local statusLabel = JOINFrame:FindFirstChild("Status")

	if not statusLabel then
		statusLabel = Instance.new("TextLabel")
		statusLabel.Name = "Status"
		statusLabel.Parent = JOINFrame
		statusLabel.Text = ""
		statusLabel.TextColor3 = Color3.new(1, 1, 1)
		statusLabel.TextSize = 14
		statusLabel.BackgroundTransparency = 1
		statusLabel.Size = UDim2.new(1, 0, 0, 20)
		statusLabel.Position = UDim2.new(0, 0, 1, 5)
	end

	joinButton.MouseButton1Click:Connect(function()
		local groupId = tonumber(groupIdInput.Text)
		if not groupId then
			statusLabel.Text = "Invalid Group ID"
			return
		end

		statusLabel.Text = "Verifying group..."
		joinButton.Active = false

		-- Get group info from server
		local success, groupName = pcall(function()
			return ReplicatedStorage:WaitForChild("GetGroupName"):InvokeServer(groupId)
		end)

		if not success or not groupName then
			statusLabel.Text = "Invalid group"
			joinButton.Active = true
			return
		end

		debugPrint("Attempting to join gang:", groupName, "Group ID:", groupId)
		GangRemoteEvent:FireServer("JoinGang", {
			groupId = groupId,
			groupName = groupName
		})
	end)
end

-- Server response handler
local function setupServerHandlers()
	GangRemoteEvent.OnClientEvent:Connect(function(eventType, data)
		debugPrint("Server event:", eventType, data)

		if eventType == "GangCreated" or eventType == "GangJoined" then
			debugPrint("Success:", eventType)
			GangMenu.Visible = false
			player:LoadCharacter()
		elseif eventType:find("Failed") then
			debugPrint("Failed:", data)
			local JOINFrame = Frames.JOIN
			if JOINFrame and JOINFrame:FindFirstChild("Status") then
				JOINFrame.Status.Text = data or "Unknown error"
			end
		elseif eventType == "RefreshGangList" then
			debugPrint("Refreshing gang list")
			-- Implement refresh logic if needed
		end
	end)
end

-- Initialize all
setupButtonConnections()
setupGangCreation()
setupGangJoining()
setupServerHandlers()
debugPrint("System initialized")

-- Turf List UI


local function populateTurfsUI()
	   local ReplicatedStorage = game:GetService("ReplicatedStorage")
	   local TurfsFrame = Frames:FindFirstChild("TURFS")
	   if not TurfsFrame then warn("No TURFS frame found"); return end
	   local Background = TurfsFrame:FindFirstChild("Background")
	   if not Background then warn("No Background in TURFS frame"); return end

	   -- Ensure Background is a ScrollingFrame
	   if not Background:IsA("ScrollingFrame") then
			   warn("Background is not a ScrollingFrame! Please change it in Studio.")
	   end

	   -- Clear previous
	   for _, child in ipairs(Background:GetChildren()) do
			   if child:IsA("Frame") then child:Destroy() end
	   end

	   -- Ensure UIListLayout exists
	   local layout = Background:FindFirstChildOfClass("UIListLayout")
	   if not layout then
			   layout = Instance.new("UIListLayout")
			   layout.Parent = Background
			   layout.SortOrder = Enum.SortOrder.LayoutOrder
			   layout.Padding = UDim.new(0, 6)
	   end

	   local folder = ReplicatedStorage:WaitForChild("CapturePoints")
	   local capturePoints = folder:GetChildren()
	   print("[TurfsUI] Found capture points:", #capturePoints)
	   print("[TurfsUI] Children of Background:")
	   for _, child in ipairs(Background:GetChildren()) do
		   print("[TurfsUI] Child:", child.Name, child.ClassName)
	   end
	   local template = Background:FindFirstChild("FrameToDuplicate")
	   if not template then warn("[TurfsUI] FrameToDuplicate not found in Background"); return end
	   print("[TurfsUI] Found template FrameToDuplicate")

	   local rowCount = 0
	   for _, cpFolder in ipairs(capturePoints) do
			   local name = cpFolder.Name
			   local location = cpFolder:FindFirstChild("Location") and cpFolder.Location.Value or "?"
			   local occupied = cpFolder:FindFirstChild("Occupied") and cpFolder.Occupied.Value or false
			   local team = cpFolder:FindFirstChild("Team") and cpFolder.Team.Value or "None"
			   print(string.format("[TurfsUI] Processing: name=%s, location=%s, occupied=%s, team=%s", tostring(name), tostring(location), tostring(occupied), tostring(team)))

			   local row = template:Clone()
			   row.Name = name .. "Row"
			   row.Visible = true
			   row.Parent = Background
			   print("[TurfsUI] Cloned and parented row:", row.Name)

			   local ownedBox = row:FindFirstChild("Owned")
			   local payTitleBox = row:FindFirstChild("PayTitle")
			   if ownedBox and ownedBox:IsA("TextBox") then
				   ownedBox.Text = team ~= "None" and team or "Unoccupied"
				   print("[TurfsUI] Set Owned text:", ownedBox.Text)
			   else
				   print("[TurfsUI] WARNING: Owned TextBox not found in row", row.Name)
			   end
			   if payTitleBox and payTitleBox:IsA("TextBox") then
				   payTitleBox.Text = "Location: " .. location .. " | Occupied: " .. tostring(occupied)
				   print("[TurfsUI] Set PayTitle text:", payTitleBox.Text)
			   else
				   print("[TurfsUI] WARNING: PayTitle TextBox not found in row", row.Name)
			   end
			   rowCount = rowCount + 1
	   end
	   print("[TurfsUI] Total rows created:", rowCount)

	   -- Set CanvasSize for scrolling
	   if Background:IsA("ScrollingFrame") and layout then
			   Background.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	   end

	   print("[TurfsUI] Rows created:", #(Background:GetChildren()))
end

-- Call populateTurfsUI when the TURFS frame is shown
local oldShowFrame = showFrame
showFrame = function(frameToShow)
	oldShowFrame(frameToShow)
	if frameToShow == Frames:FindFirstChild("TURFS") then
		populateTurfsUI()
	end
end
