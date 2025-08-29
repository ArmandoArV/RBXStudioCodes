-- CarDealershipUI.luau
-- Adapted from GunShopUI for car dealership logic and UI
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local COLORS = {
    selected = Color3.new(0.333333, 1, 0.498039),
    default = Color3.new(1, 1, 1)
}

local Player = Players.LocalPlayer
local Gui = script.Parent
local MainFrame = Gui.MainFrame
local ViewPort = MainFrame.ViewportFrame
local List = MainFrame.CarList
local Info = MainFrame.Stats
local CarType = MainFrame.CarType
local Components = ReplicatedStorage:WaitForChild("Components")
local CarList = require(Components:WaitForChild("CarListModule"))
local ReadModule = require(Components:WaitForChild("ReadModule"))
local VehiclesFolder = ReplicatedStorage:WaitForChild("Vehicles")

-- Import Car and Dealership classes
local Car = require(Components.Classes.Car)
local Dealership = require(Components.Classes.Dealership)

-- Create a dealership instance for this UI
local dealership = Dealership.new("MainDealership")

-- Populate dealership with cars from Vehicles/<CATEGORY> folders
for _, categoryFolder in ipairs(VehiclesFolder:GetChildren()) do
    if categoryFolder:IsA("Folder") then
        local categoryName = categoryFolder.Name
        for _, vehicleModel in ipairs(categoryFolder:GetChildren()) do
            if vehicleModel:IsA("Model") then
                local tuneModule = vehicleModel:FindFirstChild("A-Chasis-Tune")
                if tuneModule and tuneModule:IsA("ModuleScript") then
                    local ok, tuneData = pcall(require, tuneModule)
                    if ok and type(tuneData) == "table" then
                        local tuneProps = ReadModule.read(tuneData)
                        local modelName = vehicleModel.Name
                        dealership:AddCar(modelName)
                        local car = dealership:GetCar(modelName)
                        if car then
                            -- Set cost from CarListModule if available, else fallback to 0
                            local carListData = CarList[modelName]
                            car:SetCost(carListData and carListData.price or 0)
                            car:SetColor(carListData and carListData.colors and carListData.colors[1] or "Default")
                            car:SetGroupOnly(carListData and carListData.team ~= nil)
                            car.category = categoryName
                            -- Set stats from tuneProps
                            car.maxSpeed = tuneProps.MaxSpeed or tuneProps.Horsepower or 0
                            car.seats = 0
                            -- Count seats in the model
                            for _, desc in ipairs(vehicleModel:GetDescendants()) do
                                if desc:IsA("Seat") or desc:IsA("VehicleSeat") then
                                    car.seats = car.seats + 1
                                end
                            end
                            -- Durability: use tire humanoid health if available (default 900)
                            car.durability = 900
                            for _, desc in ipairs(vehicleModel:GetDescendants()) do
                                if desc:IsA("Humanoid") and desc.Parent and desc.Parent.Name:lower():find("tire") then
                                    car.durability = desc.MaxHealth
                                    break
                                end
                            end
                            -- Print car info for debug
                            print("[CarDealership] Loaded car:", modelName)
                            print("  Category:", car.category)
                            print("  MaxSpeed:", car.maxSpeed)
                            print("  Seats:", car.seats)
                            print("  Durability:", car.durability)
                            print("  Cost:", car:GetCost())
                        end
                    end
                end
            end
        end
    end
end

local selectedCar
local cloneModel

local viewportCamera = Instance.new("Camera")
viewportCamera.Name = "ViewportCamera"
viewportCamera.Parent = ViewPort
ViewPort.CurrentCamera = viewportCamera

local cameraPosition = Vector3.new(0, 2, 12)
local cameraRotation = CFrame.Angles(0, 0, 0)
viewportCamera.CFrame = CFrame.new(cameraPosition) * cameraRotation

local minFOV = 10
local maxFOV = 50
local zoomSpeed = 2
local smoothingSpeed = 10
local targetFOV = 35
viewportCamera.FieldOfView = targetFOV

local mouseInDisplay = false
local holdInDisplay = false

local spring = {
    position = Vector3.new(),
    velocity = Vector3.new(),
    target = Vector3.new(),
    damping = 15,
    frequency = 5
}

local baseYaw = math.rad(-90)
local basePitch = 0
local targetYaw = baseYaw
local targetPitch = basePitch
local currentYaw = baseYaw
local currentPitch = basePitch

local sensitivity = 1
local returnSpeed = 10
local minPitch = -math.rad(40)
local maxPitch = math.rad(40)

local lastX, lastY

local defaultDamping = 15
local defaultFrequency = 5
local returnDamping = 30
local returnFrequency = 10

local function ClearList()
    Info.Label.Visible = true
    Info.Data.Visible = false
    Info.Info.Visible = false
    Info.Equip.Visible = false
    -- Info.How.Visible = false
    ViewPort.Visible = false
    selectedCar = nil

    for _, child in pairs(List:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local function truncateToDecimal(number, decimals)
    local mult = 10 ^ decimals
    return math.floor(number * mult) / mult
end

local function AddCar(modelName)
    local car = dealership:GetCar(modelName)
    if not car then
        return
    end
    local template = MainFrame.Template
    local copy = template:Clone()

    if modelName ~= nil and not List:FindFirstChild(modelName) then
        copy.Name = modelName
        -- Set CarName and Price fields
        if copy:FindFirstChild("CarName") then
            copy.CarName.Text = modelName
        end
        if copy:FindFirstChild("Price") then
            copy.Price.Text = "$" .. tostring(car:GetCost())
        end
        copy.LayoutOrder = car:GetCost() or 0
        copy.Parent = List
        copy.Visible = true

        copy.Toggle.MouseButton1Click:Connect(function()
            Info.Data.GName.Text = modelName
            Info.Data.GName.Shadow.Text = modelName
            Info.Label.Visible = false
            Info.Data.Visible = true
            Info.Info.Visible = true
            Info.Equip.Visible = true
            Info.How.Visible = true
            ViewPort.Visible = true
            selectedCar = modelName

            -- Update stats bars for car: maxSpeed, seats, durability, price, colors
            if Info.Info.MaxSpeed and Info.Info.MaxSpeed.BarFrame and Info.Info.MaxSpeed.BarFrame.Bar then
                local maxSpeed = car.maxSpeed or 0
                local speedPercent = math.clamp(maxSpeed / 300, 0, 1) -- assuming 300 is a reasonable max
                Info.Info.MaxSpeed.BarFrame.Bar:TweenSize(UDim2.new(speedPercent, 0, 1, 0), Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad, 0.3, true)
                Info.Info.MaxSpeed.BarFrame.Result.Text = tostring(maxSpeed)
            end
            if Info.Info.Seats and Info.Info.Seats.BarFrame and Info.Info.Seats.BarFrame.Bar then
                local seats = car.seats or 1
                local seatPercent = math.clamp(seats / 8, 0, 1) -- up to 8 seats
                Info.Info.Seats.BarFrame.Bar:TweenSize(UDim2.new(seatPercent, 0, 1, 0), Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad, 0.3, true)
                Info.Info.Seats.BarFrame.Result.Text = tostring(seats)
            end
            if Info.Info.Durability and Info.Info.Durability.BarFrame and Info.Info.Durability.BarFrame.Bar then
                local durability = car.durability or 900
                local durabilityPercent = math.clamp((durability - 10) / (900 - 10), 0, 1)
                Info.Info.Durability.BarFrame.Bar:TweenSize(UDim2.new(durabilityPercent, 0, 1, 0),
                    Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
                Info.Info.Durability.BarFrame.Result.Text = tostring(durability)
            end
            if Info.Info.Price then
                Info.Info.Price.Text = "$" .. tostring(car:GetCost())
            end
            -- TODO: Info.Info.Colors: update color swatches if present
        end)
    end
end

local function LoadCarsByCategory(category)
    ClearList()
    for modelName, car in pairs(dealership:GetAllCars()) do
        if car.category == category or category == "ALL" then
            AddCar(modelName)
        end
    end
end

if CarType then
    for _, button in pairs(CarType:GetChildren()) do
        if button:IsA("ImageButton") or button:IsA("TextButton") then
            button.Toggle.MouseButton1Click:Connect(function()
                LoadCarsByCategory(button.Name)
            end)
        end
    end
end

LoadCarsByCategory("ALL")
