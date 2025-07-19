-- UIManager.lua
local UIManager = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GangMenu = script.Parent.Parent
local Background = GangMenu:WaitForChild("Background")
local Buttons = Background:WaitForChild("Buttons")
local Frames = Background:WaitForChild("Menu")

local DEBUG_PREFIX = "[UIManager]"

local DEFAULT_BUTTON_COLOR = Color3.new(0, 0, 0)
local ACTIVE_BUTTON_COLOR = Color3.fromRGB(45, 45, 45)

function UIManager:DebugPrint(...)
    print(DEBUG_PREFIX, ...)
end

function UIManager.new()
    local self = setmetatable({}, {
        __index = UIManager
    })
    self.Frames = Frames
    self.Buttons = Buttons
    return self
end

function UIManager:SetButtonColors(activeButton)
    for _, button in ipairs(Buttons:GetChildren()) do
        if button:IsA("TextButton") then
            button.BackgroundColor3 = (button == activeButton) and ACTIVE_BUTTON_COLOR or DEFAULT_BUTTON_COLOR
        end
    end
end

function UIManager:ShowFrame(frameToShow)
    for _, frame in ipairs(Frames:GetChildren()) do
        if frame:IsA("Frame") then
            frame.Visible = (frame == frameToShow)
        end
    end
end

function UIManager:SetupButtonConnections()
    local buttonHandlers = {
        [Buttons:FindFirstChild("TURFS")] = function()
            UIManager:ShowFrame(Frames:FindFirstChild("TURFS"))
            UIManager:SetButtonColors(Buttons.TURFS)
        end,
        [Buttons:FindFirstChild("CREATE")] = function()
            UIManager:ShowFrame(Frames:FindFirstChild("CREATE"))
            UIManager:SetButtonColors(Buttons.CREATE)
            UIManager:DebugPrint("UI switched to CREATE frame")
        end,
        [Buttons:FindFirstChild("MENU")] = function()
            UIManager:ShowFrame(Frames:FindFirstChild("JOIN"))
            UIManager:SetButtonColors(Buttons.MENU)
        end
    }

    for button, handler in pairs(buttonHandlers) do
        if button then
            button.MouseButton1Click:Connect(handler)
        else
            warn("[UIManager] Button missing in Buttons folder")
        end
    end
end

function UIManager:GetButtons()
    return Buttons
end

function UIManager:GetFrames()
    return Frames
end

return UIManager
