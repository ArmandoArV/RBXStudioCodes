
repeat wait() until game:IsLoaded()

-- Require custom classes
local Locker = require(game:GetService("ReplicatedStorage").Service.Classes.Locker)
local Human = require(game:GetService("ReplicatedStorage").Service.Classes.Human)
local Outfit = require(game:GetService("ReplicatedStorage").Service.Classes.Outfit)

local mainFrame = script.Parent.MainFrame
local lockerFrame = mainFrame:WaitForChild("Locker")
local ButtonsFrame = lockerFrame:WaitForChild("Buttons")
local PartsFrame = lockerFrame:WaitForChild("Parts")
local ExtraFrame = lockerFrame:WaitForChild("Extra")
local Template = script.Template
local viewPort = mainFrame.Preview.ViewportFrame
local hatsFrame = mainFrame.Preview.Hats

local rs = game:GetService("ReplicatedStorage")
local api = game:GetService("MarketplaceService")
local tweenService = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui
player.CharacterAppearanceLoaded:Wait()
local character = player.Character or player.CharacterAdded:Wait()

local blur = game:GetService("Lighting").TeamBlur
local camera = workspace.CurrentCamera
local cameraPart = workspace:WaitForChild("CameraPart")

local MouseInDisplay, HoldInDisplay = false, false
local currentX

local VPFcam = Instance.new("Camera")
VPFcam.Parent = viewPort
local CameraPosition = Vector3.new(0, 1.4, 8)
local CameraRotation = CFrame.Angles(math.rad(-20), 0, 0)

local isMainFrameVisible = true
local tablethinglol = {}

local hatsBackup = {}
local hatsRemoved = false

local buying = false
local id = 5275406
local hasGamepass = false

local team = player.Team.Name

local lockerStorage = rs:WaitForChild("Locker"):WaitForChild(team)
local locker = Locker.new(lockerStorage)

local guiToHide = {
	backpack = playerGui:WaitForChild("Backpack"),
	--phone = playerGui:WaitForChild("Phone"),
	minimap = playerGui:WaitForChild("Minimap"),
	playerlist = player.PlayerGui:WaitForChild("Playerlist"),
	controls = player.PlayerGui:WaitForChild("Controls")
}

local loadSlot = rs:WaitForChild("LoadSlot")
local loadEvent = rs:WaitForChild("LoadEvent")
local saveSlot = rs:WaitForChild("SaveSlot")

local colors = {
	selected = Color3.new(0.333333, 1, 0.498039);
	default = Color3.new(1, 1, 1);
}

-- Use a hashmap for equipped accessories for O(1) access
local equippedAccessories = {}

local slots = {
	slot1 = {
		slot = mainFrame.Slots.Buttons.Slot1;
		loadButton = mainFrame.Slots.Buttons.Slot1.Load.Toggle;
		saveButton = mainFrame.Slots.Buttons.Slot1.Save.Toggle;
		lastSaved = mainFrame.Slots.Buttons.Slot1.Load.Date;
	};
	slot2 = {
		slot = mainFrame.Slots.Buttons.Slot2;
		loadButton = mainFrame.Slots.Buttons.Slot2.Load.Toggle;
		saveButton = mainFrame.Slots.Buttons.Slot2.Save.Toggle;
		lastSaved = mainFrame.Slots.Buttons.Slot2.Load.Date;
	};
	slot3 = {
		slot = mainFrame.Slots.Buttons.Slot3;
		loadButton = mainFrame.Slots.Buttons.Slot3.Load.Toggle;
		saveButton = mainFrame.Slots.Buttons.Slot3.Save.Toggle;
		lastSaved = mainFrame.Slots.Buttons.Slot3.Load.Date;
	};
	slot4 = {
		slot = mainFrame.Slots.Buttons.Slot4;
		loadButton = mainFrame.Slots.Buttons.Slot4.Load.Toggle;
		saveButton = mainFrame.Slots.Buttons.Slot4.Save.Toggle;
		lastSaved = mainFrame.Slots.Buttons.Slot4.Load.Date;
	};
	slot5 = {
		slot = mainFrame.Slots.Buttons.Slot5;
		loadButton = mainFrame.Slots.Buttons.Slot5.Load.Toggle;
		saveButton = mainFrame.Slots.Buttons.Slot5.Save.Toggle;
		lastSaved = mainFrame.Slots.Buttons.Slot5.Load.Date;
	};
	slot6 = {
		slot = mainFrame.Slots.Buttons.Slot6;
		loadButton = mainFrame.Slots.Buttons.Slot6.Load.Toggle;
		saveButton = mainFrame.Slots.Buttons.Slot6.Save.Toggle;
		lastSaved = mainFrame.Slots.Buttons.Slot6.Load.Date;
	};
}

VPFcam.CFrame = CFrame.new(CameraPosition) * CameraRotation
viewPort.CurrentCamera = VPFcam
VPFcam.FieldOfView = 37

character.Archivable = true


local clonedChar = character:Clone()
clonedChar.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

-- Use Outfit class for preview character
local previewOutfit = Outfit.new(clonedChar)

local function checkGamepass()
	local success, result = pcall(function()
		return api:UserOwnsGamePassAsync(player.UserId, id)
	end)
	if success and result then
		hasGamepass = true
	end

	if hasGamepass then
		mainFrame.Slots.NotBought.Visible = false
		mainFrame.Slots.Buttons.Slot2.Visible = true
		mainFrame.Slots.Buttons.Slot3.Visible = true
		mainFrame.Slots.Buttons.Slot4.Visible = true
		mainFrame.Slots.Buttons.Slot5.Visible = true
		mainFrame.Slots.Buttons.Slot6.Visible = true
	end
end

checkGamepass()

game.Workspace.Locker.Part.ProximityPrompt.Triggered:Connect(function()
	mainFrame.Visible = true
end)

for _, descendant in pairs(clonedChar:GetDescendants()) do
	if descendant:IsA("Animator") then
		descendant:Destroy()
	elseif descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
		descendant:Destroy()
	end
end

clonedChar.Parent = viewPort.WorldModel
clonedChar:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, 0, -0.4), Vector3.new(0, 0, 7)))

uis.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		HoldInDisplay = MouseInDisplay
		currentX = input.Position.X
	end
end)

uis.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		HoldInDisplay = false
	end
end)

viewPort.MouseMoved:Connect(function(x)
	if HoldInDisplay then
		if currentX then
			local angleChange = (x - currentX) * 0.01
			clonedChar:SetPrimaryPartCFrame(clonedChar.PrimaryPart.CFrame * CFrame.Angles(0, angleChange, 0))
		end
		currentX = x
	end
end)

viewPort.MouseEnter:Connect(function()
	MouseInDisplay = true
end)

viewPort.MouseLeave:Connect(function()
	MouseInDisplay = false
end)

local function tweenButton(frame, targetSize, backgroundColor)
	tweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = targetSize,
		BackgroundColor3 = backgroundColor
	}):Play()
end

local function clearFrame(frame)
	for _, descendant in pairs(frame:GetDescendants()) do
		if descendant:IsA("Frame") then
			descendant:Destroy()
		end
	end
end

local function updateUISelection(partName, frame, subname)
	local equippedItemName = equippedAccessories[partName]
	if not equippedItemName then return end

	for _, template in pairs(frame:GetChildren()) do
		if template:IsA("Frame") then
			local itemName = template.Name
			if itemName == equippedItemName then
				for _, v in pairs(template.Corners:GetChildren()) do
					v:TweenSize(UDim2.new(0.04, 0, 0.04, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
					v.ImageColor3 = colors.selected
				end
				template.Label.TextColor3 = colors.selected
			else
				for _, v in pairs(template.Corners:GetChildren()) do
					v:TweenSize(UDim2.new(0.03, 0, 0.03, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
					v.ImageColor3 = colors.default
				end
				template.Label.TextColor3 = colors.default
			end
		end
	end
end


function equipPreviewItem(itemName, partName, alreadyselected)
	local partFolder = lockerStorage:FindFirstChild(partName)
	if not partFolder then
		warn("No existe la carpeta para la parte:", partName)
		return
	end

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

	if not item then
		warn("No se encontró el ítem:", itemName, "en la parte:", partName)
		return
	end

	local accessoryKey = subfolderName or partName
	-- Use a hash for quick lookup
	local isCurrentlyEquipped = equippedAccessories[accessoryKey] == itemName

	if isCurrentlyEquipped ~= alreadyselected then
		alreadyselected = isCurrentlyEquipped
	end

	local newModel = item:Clone()

	-- Use Outfit class methods for special parts
	if partName == "Helmet" and previewOutfit.UpdateHelmet then
		previewOutfit:UpdateHelmet(newModel)
		if alreadyselected then
			equippedAccessories[accessoryKey] = nil
		else
			equippedAccessories[accessoryKey] = itemName
		end
	elseif partName == "Gloves" and previewOutfit.UpdateGloves then
		previewOutfit:UpdateGloves(newModel)
		if alreadyselected then
			equippedAccessories[accessoryKey] = nil
		else
			equippedAccessories[accessoryKey] = itemName
		end
	elseif partName == "Vest" and previewOutfit.UpdateVest then
		previewOutfit:UpdateVest(newModel)
		if alreadyselected then
			equippedAccessories[accessoryKey] = nil
		else
			equippedAccessories[accessoryKey] = itemName
		end
	elseif newModel:IsA("Model") then
		local bodyPart = clonedChar:FindFirstChild(partName)
		if not bodyPart then
			warn("Parte no encontrada para accesorio:", partName)
			return
		end

		newModel.PrimaryPart = newModel:FindFirstChild(partName)

		if alreadyselected then
			for i, v in pairs(clonedChar:GetChildren()) do
				if v:IsA("Model") and (v.Name == accessoryKey.." Accessory") then
					v:Destroy()
				end
			end
			equippedAccessories[accessoryKey] = nil
		else
			newModel.Name = accessoryKey.." Accessory"

			for i, v in pairs(clonedChar:GetChildren()) do
				if v:IsA("Model") and (v.Name == accessoryKey.." Accessory") then
					v:Destroy()
				end
			end

			if newModel.PrimaryPart then
				newModel:SetPrimaryPartCFrame(bodyPart.CFrame)
				newModel.PrimaryPart:Destroy()
				for _, part in pairs(newModel:GetChildren()) do
					if part:IsA("BasePart") then
						local newWeld = Instance.new("Weld")
						newWeld.Part0 = bodyPart
						newWeld.Part1 = part
						newWeld.C0 = CFrame.new()
						newWeld.C1 = part.CFrame:ToObjectSpace(bodyPart.CFrame)
						newWeld.Parent = bodyPart
						part.CanCollide = false
						part.Anchored = false
					end
				end
			end

			newModel.Parent = clonedChar
			equippedAccessories[accessoryKey] = itemName
		end

	elseif newModel:IsA("Shirt") or newModel:IsA("Pants") then
		for i, v in pairs(clonedChar:GetChildren()) do
			if v.ClassName == newModel.ClassName or v:IsA("ShirtGraphic") then
				v:Destroy()
			end
		end
		newModel.Parent = clonedChar
		equippedAccessories[accessoryKey] = itemName
	end

	updateUISelection(partName, PartsFrame)
	if subfolderName then
		updateUISelection(partName, ExtraFrame, subfolderName)
	end
end


local function populatePartsFrame(partName)
	local partFolder = lockerStorage:FindFirstChild(partName)
	mainFrame.Back.Visible = true
	if not partFolder then return end

	clearFrame(PartsFrame)
	clearFrame(ExtraFrame)

	local hasSubfolders = false
	for _, item in pairs(partFolder:GetChildren()) do
		if item:IsA("Folder") then
			hasSubfolders = true
			break
		end
	end

	if hasSubfolders then
		for _, subfolder in pairs(partFolder:GetChildren()) do
			if subfolder:IsA("Folder") then
				local newTemplate = Template:Clone()
				newTemplate.Name = subfolder.Name
				newTemplate.Label.Text = string.upper(subfolder.Name)
				newTemplate.Label.Shadow.Text = string.upper(subfolder.Name)
				newTemplate.Parent = PartsFrame
				newTemplate.LayoutOrder = subfolder:GetAttribute("listOrder") or 0

				newTemplate.Toggle.MouseButton1Click:Connect(function()
					script.Click:Play()
					clearFrame(ExtraFrame)

					for _, item in pairs(subfolder:GetChildren()) do
						if not item:IsA("Folder") then
							local itemTemplate = Template:Clone()
							itemTemplate.Name = item.Name
							itemTemplate.Label.Text = string.upper(item.Name)
							itemTemplate.Label.Shadow.Text = string.upper(item.Name)
							itemTemplate.Parent = ExtraFrame

							local accessoryKey = subfolder.Name
							if equippedAccessories[accessoryKey] == item.Name then
								for _, v in pairs(itemTemplate.Corners:GetChildren()) do
									v:TweenSize(UDim2.new(0.04,0,0.04,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
									v.ImageColor3 = colors.selected
								end
								itemTemplate.Label.TextColor3 = colors.selected
							else
								itemTemplate.Label.TextColor3 = colors.default
							end

							itemTemplate.Toggle.MouseButton1Click:Connect(function()
								script.Click:Play()
								local isCurrentlySelected = equippedAccessories[accessoryKey] == item.Name

								equipPreviewItem(item.Name, partName, isCurrentlySelected)
								rs:WaitForChild("LockerEvent"):FireServer(item.Name, partName, isCurrentlySelected)

								for _, v in pairs(ExtraFrame:GetChildren()) do
									if v:IsA("Frame") then
										local isSelected = equippedAccessories[accessoryKey] == v.Name
										for _, corner in pairs(v.Corners:GetChildren()) do
											corner:TweenSize(UDim2.new(isSelected and 0.04 or 0.03, 0, isSelected and 0.04 or 0.03, 0),
												Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
											corner.ImageColor3 = isSelected and colors.selected or colors.default
										end
										v.Label.TextColor3 = isSelected and colors.selected or colors.default
									end
								end
							end)
						end
					end

					PartsFrame:TweenPosition(UDim2.new(-0.5, 0, 0.9, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
					ExtraFrame:TweenPosition(UDim2.new(0.5, 0, 0.9, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
				end)
			end
		end
	else
		for _, item in pairs(partFolder:GetChildren()) do
			if not item:IsA("Folder") then
				local newTemplate = Template:Clone()
				newTemplate.Name = item.Name
				newTemplate.Label.Text = string.upper(item.Name)
				newTemplate.Label.Shadow.Text = string.upper(item.Name)
				newTemplate.Parent = PartsFrame

				if equippedAccessories[partName] == item.Name then
					for _, v in pairs(newTemplate.Corners:GetChildren()) do
						v:TweenSize(UDim2.new(0.04, 0, 0.04, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
						v.ImageColor3 = colors.selected
					end
					newTemplate.Label.TextColor3 = colors.selected
				else
					newTemplate.Label.TextColor3 = colors.default
				end

				newTemplate.Toggle.MouseButton1Click:Connect(function()
					script.Click:Play()
					local isCurrentlySelected = equippedAccessories[partName] == item.Name

					equipPreviewItem(item.Name, partName, isCurrentlySelected)
					rs:WaitForChild("LockerEvent"):FireServer(item.Name, partName, isCurrentlySelected)

					for _, v in pairs(PartsFrame:GetChildren()) do
						if v:IsA("Frame") then
							local isSelected = equippedAccessories[partName] == v.Name
							for _, corner in pairs(v.Corners:GetChildren()) do
								corner:TweenSize(UDim2.new(isSelected and 0.04 or 0.03, 0, isSelected and 0.04 or 0.03, 0),
									Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
								corner.ImageColor3 = isSelected and colors.selected or colors.default
							end
							v.Label.TextColor3 = isSelected and colors.selected or colors.default
						end
					end
				end)
			end
		end
	end
end

clearFrame(ButtonsFrame)

for _,i in pairs(lockerStorage:GetChildren()) do
	if i:IsA("Folder") then
		local button = script.Button:Clone()
		button.LayoutOrder = i:GetAttribute("listOrder")
		button.Name = i.Name
		button.Label.Text = string.upper(button.Name)
		button.Label.Shadow.Text = string.upper(button.Name)
		button.Parent = ButtonsFrame
	end
end

for _, button in pairs(ButtonsFrame:GetChildren()) do
	if button:IsA("Frame") then
		button.Toggle.MouseButton1Click:Connect(function() script.Click:Play()
			ButtonsFrame:TweenPosition(UDim2.new(-0.5,0,0.9,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			PartsFrame:TweenPosition(UDim2.new(0.5,0,0.9,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			populatePartsFrame(button.Name)
		end)
	end
end

mainFrame.Back.Button.MouseButton1Click:Connect(function() 
	script.Click:Play()
	if ExtraFrame and ExtraFrame.Position ~= UDim2.new(1.5, 0, 0.9, 0) then
		PartsFrame:TweenPosition(UDim2.new(0.5, 0, 0.9, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		ExtraFrame:TweenPosition(UDim2.new(1.5, 0, 0.9, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		delay(0.3, function()
			clearFrame(ExtraFrame)
		end)
	else
		PartsFrame:TweenPosition(UDim2.new(1.5, 0, 0.9, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		ButtonsFrame:TweenPosition(UDim2.new(0.5, 0, 0.9, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		mainFrame.Back.Visible = false

		delay(0.3, function()
			clearFrame(PartsFrame)
			if ExtraFrame then
				clearFrame(ExtraFrame)
			end
		end)
	end
end)

local function toggleGuiVisibility(visible)
	--for _, gui in pairs(guiToHide) do
	--	gui.Enabled = visible
	--end

	if not visible then
		for _, gui in pairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= script.Parent.Name and gui.Name ~= "LoadingScreen" and gui.Name ~= "CursorGui" and not table.find(tablethinglol, gui.Name) then
				table.insert(tablethinglol, gui.Name)
				gui.Enabled = visible
			end
		end
	else
		for _, guiName in pairs(tablethinglol) do
			playerGui:FindFirstChild(guiName).Enabled = true
		end
		tablethinglol = {}
	end

	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, visible)
	--game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, visible)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, visible)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Captures, visible)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, visible)

	if playerGui:FindFirstChild("RadioCallSystem") then
		playerGui:FindFirstChild("RadioCallSystem").Enabled = visible
	end
end

function Blur(number, tme)
	tweenService:Create(blur,TweenInfo.new(tme, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Size = number
	}):Play();
end

mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	isMainFrameVisible = mainFrame.Visible
	if isMainFrameVisible then
		Blur(20, 0.5)
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = cameraPart.CFrame
		toggleGuiVisibility(false)
	else
		Blur(0, 0.5)
		camera.CameraType = Enum.CameraType.Custom
		rs.PreviewEvent:FireServer()
		toggleGuiVisibility(true)
	end
end)

local function createAndPlayTween(instance, property, targetValue)
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = tweenService:Create(instance, tweenInfo, {[property] = targetValue})
	tween:Play()
end

local function onExitMouseEnter()
	mainFrame.Exit:TweenSize(UDim2.new(0.06, 0, 0.06, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
	createAndPlayTween(mainFrame.Exit.Image, "ImageTransparency", 1)
	createAndPlayTween(mainFrame.Exit.Image.Shadow, "ImageTransparency", 1)
	createAndPlayTween(mainFrame.Exit.Label, "TextTransparency", 0)
	createAndPlayTween(mainFrame.Exit.Label.Shadow, "TextTransparency", 0)
end

local function onExitMouseLeave()
	mainFrame.Exit:TweenSize(UDim2.new(0.03, 0, 0.06, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
	createAndPlayTween(mainFrame.Exit.Image, "ImageTransparency", 0)
	createAndPlayTween(mainFrame.Exit.Image.Shadow, "ImageTransparency", 0)
	createAndPlayTween(mainFrame.Exit.Label, "TextTransparency", 1)
	createAndPlayTween(mainFrame.Exit.Label.Shadow, "TextTransparency", 1)
end

mainFrame.Exit.Button.MouseEnter:Connect(onExitMouseEnter)
mainFrame.Exit.Button.MouseLeave:Connect(onExitMouseLeave)

mainFrame.Exit.Button.MouseButton1Click:Connect(function() script.Click:Play()
	mainFrame.Visible = false
	PartsFrame:TweenPosition(UDim2.new(1.5,0,0.9,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
	ExtraFrame:TweenPosition(UDim2.new(1.5,0,0.9,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
	ButtonsFrame:TweenPosition(UDim2.new(0.5,0,0.9,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
	clearFrame(PartsFrame)
	clearFrame(ExtraFrame)
	toggleGuiVisibility(true)
	clonedChar:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, 0, -0.4), Vector3.new(0, 0, 7)))
end)

player.Character.Humanoid.Changed:Connect(function()
	if player.Character.Humanoid.Health == 0 then
		mainFrame.Visible = false
		toggleGuiVisibility(true)
	end
end)

for _, hat in pairs(clonedChar:GetChildren()) do
	if hat:IsA("Accessory") then
		hatsBackup[hat] = hat.Parent
	end
end

local function removeHats(character, clonedCharacter, hatsBackup)
	for _, hat in pairs(clonedCharacter:GetChildren()) do
		if hat:IsA("Accessory") then
			hatsBackup[hat] = hat.Parent
			hat.Parent = nil
		end
	end
	for _, hat in pairs(character:GetChildren()) do
		if hat:IsA("Accessory") then
			hatsBackup[hat] = hat.Parent
			hat.Parent = nil
		end
	end
end

local function restoreHats(hatsBackup)
	for hat, parent in pairs(hatsBackup) do
		if hat and hat.Parent == nil then
			pcall(function()
				hat.Parent = parent
			end)
		end
	end
end

hatsFrame.Button.MouseButton1Click:Connect(function() script.Click:Play()
	if hatsRemoved then
		restoreHats(hatsBackup)
		hatsRemoved = false
		hatsFrame.ImageLabel.Image = "rbxassetid://6031068421"
		hatsFrame.ImageLabel.Shadow.Image = "rbxassetid://6031068421"
	else
		removeHats(character, clonedChar, hatsBackup)
		hatsRemoved = true
		hatsFrame.ImageLabel.Image = "rbxassetid://6031068420"
		hatsFrame.ImageLabel.Shadow.Image = "rbxassetid://6031068420"
	end
end)

function savepress(slotreq)
	slotreq.slot.Save.Image.ImageColor3 = Color3.new(0.494118, 0.494118, 0.494118)
	task.wait(0.5)
	slotreq.slot.Save.Image.ImageColor3 = Color3.new(1, 1, 1)
end

function loadpress(slotreq)
	slotreq.slot.Load.Label.Text = ". . ."
	slotreq.slot.Load.Label.Shadow.Text = ". . ."
	slotreq.slot.Load.Label.TextColor3 = Color3.new(0.494118, 0.494118, 0.494118)
	task.wait(0.5)
	slotreq.slot.Load.Label.Text = string.upper(slotreq.slot.Name)
	slotreq.slot.Load.Label.Shadow.Text = string.upper(slotreq.slot.Name)
	slotreq.slot.Load.Label.TextColor3 = Color3.new(1, 1, 1)
end

local function getFormattedDateTime()
	return os.date("%d/%m/%Y - %H:%M")
end

local function clearAllAccessories()
	-- Use keys for O(1) removal
	for partName, itemName in pairs(equippedAccessories) do
		equipPreviewItem(itemName, partName, true)
	end
	table.clear(equippedAccessories)
end

local function handleSlot(slot, saveSlot, loadSlot, team)
	local data = loadSlot:InvokeServer(slot.slot.Name, team)

	if data and data.lastSaved then
		slot.lastSaved.Text = "LAST SAVED: " .. data.lastSaved
		slot.lastSaved.Shadow.Text = "LAST SAVED: " .. data.lastSaved
	end

	slot.saveButton.MouseButton1Click:Connect(function()
		script.Click:Play()

		-- Use a hashmap for storage, but convert to array for serialization
		local accessoriesToSave = {}
		for partName, itemName in pairs(equippedAccessories) do
			accessoriesToSave[partName] = itemName
		end

		local saveData = {
			equippedAccessories = accessoriesToSave,
			lastSaved = getFormattedDateTime()
		}

		saveSlot:FireServer(slot.slot.Name, accessoriesToSave, team)
		savepress(slot)

		slot.lastSaved.Text = "LAST SAVED: " .. saveData.lastSaved
		slot.lastSaved.Shadow.Text = "LAST SAVED: " .. saveData.lastSaved
	end)

	slot.loadButton.MouseButton1Click:Connect(function()
		script.Click:Play()
		loadpress(slot)
		clearAllAccessories()
		local data = loadSlot:InvokeServer(slot.slot.Name, team)
		loadEvent:FireServer(slot.slot.Name, team)
		if data and data.equippedAccessories then
			for partName, itemName in pairs(data.equippedAccessories) do
				local subfolder = nil
				local partFolder = lockerStorage:FindFirstChild(partName)
				if not partFolder then
					for _, folder in pairs(lockerStorage:GetChildren()) do
						local foundItem = folder:FindFirstChild(itemName)
						if not foundItem then
							for _, sub in pairs(folder:GetChildren()) do
								if sub:IsA("Folder") and sub:FindFirstChild(itemName) then
									foundItem = sub:FindFirstChild(itemName)
									subfolder = sub.Name
									break
								end
							end
						end
						if foundItem then
							partName = folder.Name
							break
						end
					end
				end
				if itemName ~= "" then
					equipPreviewItem(itemName, partName, false)
					if subfolder then
						updateUISelection(subfolder, ExtraFrame)
					else
						updateUISelection(partName, PartsFrame)
					end
				end
			end
			slot.lastSaved.Text = "LAST SAVED: " .. (data.lastSaved or "N/A")
			slot.lastSaved.Shadow.Text = "LAST SAVED: " .. (data.lastSaved or "N/A")
		end
	end)
end

for _, slot in pairs(slots) do
	handleSlot(slot, saveSlot, loadSlot, team)
end

local function gamepassPurchaseFinished(player,passid,purchased)
	buying = false
	if purchased == true and passid == id then
		if mainFrame.Slots:FindFirstChild("NotBought") then
			mainFrame.Slots.NotBought.Visible = false
			mainFrame.Slots.Buttons.Slot2.Visible = true
			mainFrame.Slots.Buttons.Slot3.Visible = true
			mainFrame.Slots.Buttons.Slot4.Visible = true
			mainFrame.Slots.Buttons.Slot5.Visible = true
			mainFrame.Slots.Buttons.Slot6.Visible = true
		end
	end
end

if not api:UserOwnsGamePassAsync(player.UserId, id) then
	if mainFrame.Slots:FindFirstChild("NotBought") then
		mainFrame.Slots.NotBought.Visible = true
		mainFrame.Slots.Buttons.Slot2.Visible = false
		mainFrame.Slots.Buttons.Slot3.Visible = false
		mainFrame.Slots.Buttons.Slot4.Visible = false
		mainFrame.Slots.Buttons.Slot5.Visible = false
		mainFrame.Slots.Buttons.Slot6.Visible = false
		mainFrame.Slots:FindFirstChild("NotBought").Buy.Button.MouseButton1Click:Connect(function() script.Click:Play()
			api:PromptGamePassPurchase(player, id)
			tweenButton(mainFrame.Slots:FindFirstChild("NotBought").Buy, UDim2.new(0.6, 0, 0.12, 0), Color3.fromRGB(58, 175, 86))
			mainFrame.Slots:FindFirstChild("NotBought").Buy.Label.Text = "PROCESANDO..."
			mainFrame.Slots:FindFirstChild("NotBought").Buy.Label.Shadow.Text = "PROCESANDO..."
		end)
		mainFrame.Slots:FindFirstChild("NotBought").Buy.Button.MouseEnter:Connect(function()
			tweenButton(mainFrame.Slots:FindFirstChild("NotBought").Buy, UDim2.new(0.6, 0, 0.12, 0), Color3.fromRGB(58, 175, 86))
		end)
		mainFrame.Slots:FindFirstChild("NotBought").Buy.Button.MouseLeave:Connect(function()
			tweenButton(mainFrame.Slots:FindFirstChild("NotBought").Buy, UDim2.new(0.5, 0, 0.1, 0), Color3.fromRGB(85, 255, 127))
		end)
	end
else
	if mainFrame.Slots:FindFirstChild("NotBought") then
		mainFrame.Slots.NotBought.Visible = false
		mainFrame.Slots.Buttons.Slot2.Visible = true
		mainFrame.Slots.Buttons.Slot3.Visible = true
		mainFrame.Slots.Buttons.Slot4.Visible = true
		mainFrame.Slots.Buttons.Slot5.Visible = true
		mainFrame.Slots.Buttons.Slot6.Visible = true
	end
end

checkGamepass()

api.PromptGamePassPurchaseFinished:Connect(gamepassPurchaseFinished)