-- UIManager.lua
local UIManager = {}
UIManager.__index = UIManager

local DEFAULT_BUTTON_COLOR = Color3.fromRGB(70, 70, 70)
local ACTIVE_BUTTON_COLOR = Color3.fromRGB(255,255,255)
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function UIManager.new(gangMenu)
	local self = setmetatable({}, UIManager)
	self.GangMenu = gangMenu
	self.Background = gangMenu:WaitForChild("GUIs"):WaitForChild("TeamFrame").Config.Frame:WaitForChild("Gangs")
	self.Buttons = self.Background:WaitForChild("Buttons")
	self.Frames = self.Background
	return self
end

function UIManager:DebugPrint(...)
	--print("[UIManager]", ...)
end

function UIManager:SetButtonColors(activeButton)
	for _, btn in ipairs(self.Buttons:GetChildren()) do
		if btn:IsA("TextButton") then
			btn.UIStroke.Color = (btn == activeButton) and ACTIVE_BUTTON_COLOR or DEFAULT_BUTTON_COLOR
		end
	end
end

function UIManager:ShowFrame(frameToShow)
	self:DebugPrint("ShowFrame called with:", frameToShow)

	-- Handle string inputs for GANG and JOIN (subframes under MENU)
	if typeof(frameToShow) == "string" then
		if frameToShow == "GANG" then
			self:DebugPrint("Showing GANG subframe")
			-- Hide all main frames except MENU
			for _, frame in ipairs(self.Frames:GetChildren()) do
				if frame:IsA("Frame") or frame:IsA("ScrollingFrame") then
					if frame.Name ~= "Buttons" then
						frame.Visible = (frame.Name == "MENU")
					end
				end
			end

			-- Show MENU frame and GANG subframe
			local menuFrame = self.Frames:FindFirstChild("MENU")
			if menuFrame then
				menuFrame.Visible = true
				local gangFrame = menuFrame:FindFirstChild("GANG")
				local joinFrame = menuFrame:FindFirstChild("JOIN")
				if gangFrame then 
					gangFrame.Visible = true 
					self:DebugPrint("GANG subframe made visible")
				end
				if joinFrame then 
					joinFrame.Visible = false 
					self:DebugPrint("JOIN subframe hidden")
				end
			end

			-- Highlight MENU button
			self:HighlightButton("MENU")
			return

		elseif frameToShow == "JOIN" then
			self:DebugPrint("Showing JOIN subframe")
			-- Hide all main frames except MENU
			for _, frame in ipairs(self.Frames:GetChildren()) do
				if frame:IsA("Frame") or frame:IsA("ScrollingFrame") then
					if frame.Name ~= "Buttons" then
						frame.Visible = (frame.Name == "MENU")
					end
				end
			end

			-- Show MENU frame and JOIN subframe
			local menuFrame = self.Frames:FindFirstChild("MENU")
			if menuFrame then
				menuFrame.Visible = true
				local gangFrame = menuFrame:FindFirstChild("GANG")
				local joinFrame = menuFrame:FindFirstChild("JOIN")
				if gangFrame then 
					gangFrame.Visible = false 
					self:DebugPrint("GANG subframe hidden")
				end
				if joinFrame then 
					joinFrame.Visible = true 
					self:DebugPrint("JOIN subframe made visible")
				end
			end

			-- Highlight MENU button
			self:HighlightButton("MENU")
			return
		end
	end

	-- Handle frame objects (CREATE, TURFS, etc.)
	self:DebugPrint("Showing main frame:", frameToShow.Name)
	for _, frame in ipairs(self.Frames:GetChildren()) do
		if frame:IsA("Frame") or frame:IsA("ScrollingFrame") then
			if frame.Name ~= "Buttons" then
				frame.Visible = (frame == frameToShow)
			end
		end
	end

	-- Highlight corresponding button
	self:HighlightButton(frameToShow.Name)
end

function UIManager:HighlightButton(buttonName)
	local btn = self.Buttons:FindFirstChild(buttonName)
	if btn then
		self:DebugPrint("Highlighting button:", buttonName)
		-- Highlight the active button
		if btn:FindFirstChild("Gradient") and btn.Gradient:FindFirstChild("UIGradient") then
			btn.Gradient.UIGradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.6),
				NumberSequenceKeypoint.new(1, 0.6)
			}
		end
		if btn:FindFirstChild("UIStroke") then
			local tween1 = TweenService:Create(btn.UIStroke, tweenInfo, {Color = Color3.fromRGB(255,255,255)})
			local tween2 = TweenService:Create(btn.UIStroke, tweenInfo, {Transparency = 0.3})
			tween1:Play()
			tween2:Play()
		end

		-- Dim other buttons
		for _, otherBtn in pairs(self.Buttons:GetChildren()) do
			if otherBtn:IsA("Frame") and otherBtn.Name ~= buttonName then
				if otherBtn:FindFirstChild("Gradient") and otherBtn.Gradient:FindFirstChild("UIGradient") then
					otherBtn.Gradient.UIGradient.Transparency = NumberSequence.new{
						NumberSequenceKeypoint.new(0, 0.9),
						NumberSequenceKeypoint.new(1, 0.9)
					}
				end
				if otherBtn:FindFirstChild("UIStroke") then
					local tween1 = TweenService:Create(otherBtn.UIStroke, tweenInfo, {Color = Color3.fromRGB(70,70,70)})
					local tween2 = TweenService:Create(otherBtn.UIStroke, tweenInfo, {Transparency = 0.5})
					tween1:Play()
					tween2:Play()
				end
			end
		end
	else
		self:DebugPrint("Button not found:", buttonName)
	end
end

function UIManager:SetupButtonConnections()
	self:DebugPrint("Setting up buttons...")

	local turfsBtn = self.Buttons:FindFirstChild("TURFS")
	local createBtn = self.Buttons:FindFirstChild("CREATE")
	local menuBtn = self.Buttons:FindFirstChild("MENU")

	if turfsBtn then
		turfsBtn.Toggle.MouseButton1Click:Connect(function()
			self:DebugPrint("TURFS clicked")
			self:ShowFrame(self.Frames:FindFirstChild("TURFS"))
		end)
	end

	if createBtn then
		createBtn.Toggle.MouseButton1Click:Connect(function()
			self:DebugPrint("CREATE clicked")
			self:ShowFrame(self.Frames:FindFirstChild("CREATE"))
		end)
	end

	if menuBtn then
		menuBtn.Toggle.MouseButton1Click:Connect(function()
			self:DebugPrint("MENU clicked")
			--self:ShowFrame("JOIN") -- Default to JOIN frame
		end)
	end

	self.Buttons.Visible = true
end

return UIManager