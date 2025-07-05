-- remoteevent
local GunFolder = game:GetService("ReplicatedStorage"):WaitForChild("Tools")
local GunConfigs = game:GetService("ReplicatedStorage"):WaitForChild("GunEngineShared").Configuration
local Player = game.Players.LocalPlayer
local Gui = script.Parent
local MainFrame = Gui.MainFrame
local ViewPort = MainFrame.ViewportFrame
local List = MainFrame.GunList
local Info = MainFrame.Stats
local TypeOfGun = MainFrame.GunType
local Components = game:GetService("ReplicatedStorage"):WaitForChild("Components")
local ToolCloner = require(Components:WaitForChild("ToolCloner"))
local GunPrices = require(Components:WaitForChild("GunPrices"))

-- RemoteEvent for gun purchases
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GunShopPurchaseEvent = ReplicatedStorage:FindFirstChild("GunShopPurchase")
if not GunShopPurchaseEvent then
	GunShopPurchaseEvent = Instance.new("RemoteEvent")
	GunShopPurchaseEvent.Name = "GunShopPurchase"
	GunShopPurchaseEvent.Parent = ReplicatedStorage
end

-- Build Guns table from GunFolder tools, using IntValue for price and merging config
Guns = {}
for _, tool in pairs(GunFolder:GetDescendants()) do
	if tool:IsA("Tool") then
		local price = GunPrices.GetPrice(tool.Name)
		local configModule = GunConfigs:FindFirstChild(tool.Name)
		local config = configModule and require(configModule) or {}
		local gunType = config.GunType or "Unknown"
		Guns[tool.Name] = {
			Type = gunType,
			Spread_IncreasePS = config.Spread_IncreasePS or 0,
			Recoil = config.Recoil or 0,
			AngleX_Min = config.AngleX_Min or 0,
			AngleX_Max = config.AngleX_Max or 0,
			Damage = config.Damage or 0,
			Range = config.Range or 0,
			Weight = config.Weight or 0,
			Rate = config.Rate or 0,
			Price = price
		}
	else
	end
end

function ClearList()
	for _, a in pairs(List:GetChildren()) do
		if a:IsA("Frame") then
			a:Destroy()
		end
	end
end
local selectedgun

local template = MainFrame.Template
template.Visible = false
function AddGun(name, typeofweapon, accuracy, damage, range, mobility, rate, price)
	local copy = template:Clone()
	if name ~= nil and not List:FindFirstChild(name) then
		copy.Name = name
		copy.Label.Text = name
		copy.Label.Shadow.Text = name
		copy.Parent = List
		copy.Visible = true
		copy.Toggle.MouseButton1Click:Connect(function()
			Info.GName.Text = name
			Info.GName.Shadow.Text = name
			Info.Label.Visible = false
			Info.GName.Visible = true
			Info.Info.Visible = true
			Info.Equip.Visible = true
			selectedgun = name
			--[[STATS
			0-100%
			]]
			local rB = 0.05
			local aB = 0.20
			local sB = 0.10
			local anglething = (accuracy[3] + accuracy[4]) / 2
			local A = 1 / (1 + (rB * accuracy[2]) + (aB * anglething) + (sB * accuracy[1]))
			Info.Info.Accuracy.BarFrame.Bar:TweenSize(UDim2.new(A, 0, 1, 0), Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad, 0.3, true)
			-- damage
			local D = damage
			if D > 100 then
				D = 100
			end
			Info.Info.Damage.BarFrame.Bar:TweenSize(UDim2.new(D, 0, 1, 0), Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad, 0.3, true)
			-- range
			local R = range / 300000
			Info.Info.Range.BarFrame.Bar:TweenSize(UDim2.new(R, 0, 1, 0), Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad, 0.3, true)
			-- mobility
			Info.Info.Mobility.BarFrame.Bar:TweenSize(UDim2.new(mobility, 0, 1, 0), Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad, 0.3, true)
			-- rate
			local rmax
			if typeofweapon == "SniperRifle" or typeofweapon == "Shotgun" then
				rmax = 0.5
			else
				rmax = 0.15
			end
			local FLinear = math.clamp(((rmax - rate) / (rmax - 0.05)), 0.1, 1)
			Info.Info.Rate.BarFrame.Bar:TweenSize(UDim2.new(FLinear, 0, 1, 0), Enum.EasingDirection.Out,Enum.EasingStyle.Quad, 0.3, true)
			Info.Equip.Label.Text = price
			Info.Equip.Label.Shadow.Text = price
		end)
	end
end

local Types = {}
local SpecificGuns = {}
function LoadWeapons(LookFor, specific)
	for name, data in pairs(Guns) do
		if specific then
			if name == LookFor then
				for _, i in pairs(GunFolder:GetDescendants()) do
					if i:IsA("Tool") and i.Name == name then
						AddGun(name, data.Type, {data.Spread_IncreasePS, data.Recoil, data.AngleX_Min, data.AngleX_Max}, data.Damage, data.Range, data.Weight, data.Rate, data.Price)
					end
				end
			end
		else
			if data.Type == LookFor then
				for _, i in pairs(GunFolder:GetDescendants()) do
					if i:IsA("Tool") and i.Name == name then
						AddGun(name, data.Type, {data.Spread_IncreasePS, data.Recoil, data.AngleX_Min, data.AngleX_Max}, data.Damage, data.Range, data.Weight, data.Rate, data.Price)
					end
				end
			end
		end
	end
end

for _, button in pairs(TypeOfGun:GetChildren()) do
	if button.Name == "Assault" then
		table.insert(Types, {button.Name, {"Rifle", "OldGun_nobolt", "OldGun"}})
		button.Toggle.MouseButton1Click:Connect(function()
			ClearList()
			for _, i in pairs(Types) do
				if i[1] == button.Name then
					for _, a in pairs(i[2]) do
						LoadWeapons(a, false)
					end
				end
			end
		end)
	elseif button.Name == "Machine" then
		table.insert(SpecificGuns, {button.Name, {"M249", "M60", "MG42", "RPK16"}})
		button.Toggle.MouseButton1Click:Connect(function()
			ClearList()
			for _, i in pairs(SpecificGuns) do
				if i[1] == button.Name then
					for _, a in pairs(i[2]) do
						LoadWeapons(a, true)
					end
				end
			end
		end)
	elseif button.Name == "Pistol" then
		table.insert(Types, {button.Name, {"SemiPistol", "AutoPistol", "Revorler", "OldSemiPistol"}})
		button.Toggle.MouseButton1Click:Connect(function()
			ClearList()
			for _, i in pairs(Types) do
				if i[1] == button.Name then
					for _, a in pairs(i[2]) do
						LoadWeapons(a, false)
					end
				end
			end
		end)
	elseif button.Name == "Shotgun" then
		table.insert(Types, {button.Name, {"Shotgun"}})
		button.Toggle.MouseButton1Click:Connect(function()
			ClearList()
			for _, i in pairs(Types) do
				if i[1] == button.Name then
					for _, a in pairs(i[2]) do
						LoadWeapons(a, false)
					end
				end
			end
		end)
	elseif button.Name == "Sniper" then
		table.insert(Types, {button.Name, {"SniperRifle"}})
		button.Toggle.MouseButton1Click:Connect(function()
			ClearList()
			for _, i in pairs(Types) do
				if i[1] == button.Name then
					for _, a in pairs(i[2]) do
						LoadWeapons(a, false)
					end
				end
			end
		end)
	elseif button.Name == "Misc" then
		table.insert(Types, {button.Name, {"Melee", "Explosive", "Flamethrower", "Taser", "Stun"}})
		button.Toggle.MouseButton1Click:Connect(function()
			ClearList()
			for _, i in pairs(Types) do
				if i[1] == button.Name then
					for _, a in pairs(i[2]) do
						LoadWeapons(a, false)
					end
				end
			end
		end)
	end
end

-- After building the Guns table, load the default weapon type to populate the UI
if #Types > 0 then
	for _, a in pairs(Types[1][2]) do
		LoadWeapons(a, false)
	end
end

Info.GName.Changed:Connect(function(thing)
	if thing == "Text" then
		if Guns[selectedgun] then
			local price = Guns[selectedgun].Price
			Info.Equip.Label.Text = "COMPRAR POR $"..price
			Info.Equip.Label.Shadow.Text = "COMPRAR POR $"..price
		end
	end
end)
Info.Equip.Button.MouseButton1Click:Connect(function()
	if selectedgun and Guns[selectedgun] then
		GunShopPurchaseEvent:FireServer(selectedgun)
	end
end)

-- Listen for purchase result from server
GunShopPurchaseEvent.OnClientEvent:Connect(function(result, gunName)
	if result == "success" then
		-- Optionally show a success message or animation
	elseif result == "too_expensive" and gunName == selectedgun then
		Info.Equip.Label.Text = "MUY CARO"
		Info.Equip.Label.Shadow.Text = "MUY CARO"
	elseif result == "not_found" and gunName == selectedgun then
		Info.Equip.Label.Text = "NO DISPONIBLE"
		Info.Equip.Label.Shadow.Text = "NO DISPONIBLE"
	end
end)