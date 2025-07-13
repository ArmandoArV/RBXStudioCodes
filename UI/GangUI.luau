local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupService = game:GetService("GroupService") -- Add this line
local GangRemoteEvent = "GangRemoteEvent"
local GangHandler = ReplicatedStorage:WaitForChild("Handler"):WaitForChild("GangHandler")
local TurfHandler = ReplicatedStorage:WaitForChild("Handler"):WaitForChild("TurfHandler")

-- Ensure the RemoteEvent exists
local remoteEvent = ReplicatedStorage:FindFirstChild(GangRemoteEvent)
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = GangRemoteEvent
	remoteEvent.Parent = ReplicatedStorage
end

-- Update the UI 
local GangMenu = script.Parent
local Buttons = GangMenu:WaitForChild("Buttons", 5) -- waits up to 5 seconds
local Frames = GangMenu:WaitForChild("Menu", 5)
if not Buttons then
	warn("Buttons object not found in GangMenu after waiting!")
	return
end
if not Frames then
	warn("Menu object not found in GangMenu after waiting!")
	return
end

local function setButtonColors(activeButton)
	Buttons.TURFS.BackgroundColor3 = activeButton == Buttons.TURFS and Color3.fromRGB(45, 45, 45) or Color3.new(0, 0, 0)
	Buttons.CREATE.BackgroundColor3 = activeButton == Buttons.CREATE and Color3.fromRGB(45, 45, 45) or
		Color3.new(0, 0, 0)
	Buttons.MENU.BackgroundColor3 = activeButton == Buttons.MENU and Color3.fromRGB(45, 45, 45) or Color3.new(0, 0, 0)
end

Buttons.TURFS.MouseButton1Click:Connect(function()
	Frames.TURFS.Visible = true
	Frames.CREATE.Visible = false
	Frames.JOIN.Visible = false
	setButtonColors(Buttons.TURFS)
end)

Buttons.CREATE.MouseButton1Click:Connect(function()
	Frames.TURFS.Visible = false
	Frames.CREATE.Visible = true
	Frames.JOIN.Visible = false
	setButtonColors(Buttons.CREATE)
end)

Buttons.MENU.MouseButton1Click:Connect(function()
	Frames.TURFS.Visible = false
	Frames.CREATE.Visible = false
	Frames.JOIN.Visible = true
	setButtonColors(Buttons.MENU)
end)

local function colorWheel(colourWheel, wheelPicker, darknessPicker, darknessSlider, colourDisplay)
	local uis = game:GetService("UserInputService")
	local buttonDown = false
	local movingSlider = false

	local selectedColor = Color3.new(1, 1, 1)

	local function updateColour(centreOfWheel)
		local colourPickerCentre = Vector2.new(wheelPicker.AbsolutePosition.X + (wheelPicker.AbsoluteSize.X / 2),
			wheelPicker.AbsolutePosition.Y + (wheelPicker.AbsoluteSize.Y / 2))
		local h =
			(math.pi - math.atan2(colourPickerCentre.Y - centreOfWheel.Y, colourPickerCentre.X - centreOfWheel.X)) /
			(math.pi * 2)
		local s = (centreOfWheel - colourPickerCentre).Magnitude / (colourWheel.AbsoluteSize.X / 2)
		local v = math.abs((darknessSlider.AbsolutePosition.Y - darknessPicker.AbsolutePosition.Y) /
			darknessPicker.AbsoluteSize.Y - 1)
		local hsv = Color3.fromHSV(math.clamp(h, 0, 1), math.clamp(s, 0, 1), math.clamp(v, 0, 1))
		colourDisplay.ImageColor3 = hsv
		selectedColor = hsv
		darknessPicker.UIGradient.Color = ColorSequence.new {ColorSequenceKeypoint.new(0, hsv),
			ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))}
	end

	colourWheel.MouseButton1Down:Connect(function()
		buttonDown = true
	end)

	darknessPicker.MouseButton1Down:Connect(function()
		movingSlider = true
	end)

	uis.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		buttonDown = false
		movingSlider = false
	end)

	uis.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local mousePos = uis:GetMouseLocation() - Vector2.new(0, game:GetService("GuiService"):GetGuiInset().Y)
		local centreOfWheel = Vector2.new(colourWheel.AbsolutePosition.X + (colourWheel.AbsoluteSize.X / 2),
			colourWheel.AbsolutePosition.Y + (colourWheel.AbsoluteSize.Y / 2))
		local distanceFromWheel = (mousePos - centreOfWheel).Magnitude
		if distanceFromWheel <= colourWheel.AbsoluteSize.X / 2 and buttonDown then
			wheelPicker.Position = UDim2.new(0, mousePos.X - colourWheel.AbsolutePosition.X, 0,
				mousePos.Y - colourWheel.AbsolutePosition.Y)
		elseif movingSlider then
			darknessSlider.Position = UDim2.new(darknessSlider.Position.X.Scale, 0, 0, math.clamp(
				mousePos.Y - darknessPicker.AbsolutePosition.Y, 0, darknessPicker.AbsoluteSize.Y))
		end
		updateColour(centreOfWheel)
	end)

	return function()
		return selectedColor
	end
end
local function createGang()
	local CREATEFrame = Frames.CREATE
	local groupIdInput = CREATEFrame:WaitForChild("ID")
	local groupImg = CREATEFrame:WaitForChild("IMG")
	local groupName = groupImg:WaitForChild("GroupName")
	local colourWheel = CREATEFrame:WaitForChild("ColourWheel")
	local wheelPicker = colourWheel:WaitForChild("Picker")
	local darknessPicker = CREATEFrame:WaitForChild("DarknessPicker")
	local darknessSlider = darknessPicker:WaitForChild("Slider")
	local colourDisplay = CREATEFrame:WaitForChild("ColourDisplay")
	local createButton = CREATEFrame:WaitForChild("Create")

	-- Setup color wheel and get a function to retrieve the selected color
	local getSelectedColor = colorWheel(colourWheel, wheelPicker, darknessPicker, darknessSlider, colourDisplay)

	-- Display group logo when Enter is pressed in groupIdInput
	groupIdInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local groupId = groupIdInput.Text
			local groupIdNum = tonumber(groupId)
			if groupIdNum then
				-- Use Roblox's group thumbnail asset id
				groupImg.Image = "rbxthumb://type=GroupIcon&id=" .. groupIdNum .. "&w=150&h=150"
				-- Request group name from server
				local remoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("GetGroupName")
				local groupNameResult = remoteFunction:InvokeServer(groupIdNum)
				print("[DEBUG] GroupNameResult from server:", groupNameResult)
				groupName.Text = groupNameResult or "Group Name Not Found"
			else
				groupImg.Image = ""
				groupName.Text = "Invalid Group ID"
			end
		end
	end)

	createButton.MouseButton1Click:Connect(function()
		local groupId = groupIdInput.Text
		local name = groupName.Text
		local colour = getSelectedColor()

		if groupId == "" or name == "" then
			warn("Group ID and Name cannot be empty.")
			return
		end

		-- Set group image from groupId
		local groupIdNum = tonumber(groupId)
		if groupIdNum then
			-- Roblox group thumbnail API
			local thumbUrl = string.format("https://www.roblox.com/groups/%d/render?size=150x150", groupIdNum)
			groupImg.Image = thumbUrl
		else
			groupImg.Image = "" -- fallback if not a valid number
		end

		-- Request gang creation from server, send color as Color3
		local GangRemoteEvent = ReplicatedStorage:WaitForChild("GangRemoteEvent")
		GangRemoteEvent:FireServer("CreateGang", name, {r = colour.R, g = colour.G, b = colour.B})
	end)

	-- Listen for gang creation result
	local GangRemoteEvent = ReplicatedStorage:WaitForChild("GangRemoteEvent")
	GangRemoteEvent.OnClientEvent:Connect(function(eventType, data)
		if eventType == "GangCreated" then
			print("Gang created successfully:", data)
			-- Optionally, update the UI or notify the player
		elseif eventType == "GangCreateFailed" then
			warn("Failed to create gang:", data)
			-- Optionally, show error to user
		end
	end)
end

createGang()