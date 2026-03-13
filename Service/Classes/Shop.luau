-- Shop.luau
-- Generic base class for any shop that sells items.
-- Subclass this to create specific shops (GunShop, Dealership, etc.)
--
-- Usage (subclassing):
--   local Shop = require(script.Parent.Shop)
--   local MyShop = setmetatable({}, { __index = Shop })
--   MyShop.__index = MyShop
--
--   function MyShop.new()
--       local self = Shop.new("MyItemType")
--       return setmetatable(self, MyShop)
--   end

local Shop = {}
Shop.__index = Shop

-- @param itemTypeName  string  Used in warnings, e.g. "Gun", "Car", "Potion"
function Shop.new(itemTypeName: string)
	local self = setmetatable({}, Shop)
	self.Items = {}
	self._typeName = itemTypeName or "Item"
	return self
end

function Shop:AddItem(name: string, data: any): boolean
	if not self.Items[name] then
		self.Items[name] = data
		return true
	end
	warn(("[Shop:AddItem] %s already exists: %s"):format(self._typeName, name))
	return false
end

function Shop:RemoveItem(name: string): boolean
	if self.Items[name] then
		self.Items[name] = nil
		return true
	end
	warn(("[Shop:RemoveItem] %s not found: %s"):format(self._typeName, name))
	return false
end

function Shop:GetItem(name: string): any
	return self.Items[name]
end

function Shop:GetAllItems(): { [string]: any }
	return self.Items
end

function Shop:UpdateItem(name: string, data: any): boolean
	if self.Items[name] then
		self.Items[name] = data
		return true
	end
	warn(("[Shop:UpdateItem] %s not found: %s"):format(self._typeName, name))
	return false
end

function Shop:HasItem(name: string): boolean
	return self.Items[name] ~= nil
end

function Shop:ClearItems()
	self.Items = {}
end

function Shop:GetItemNames(): { string }
	local names = {}
	for name in pairs(self.Items) do
		table.insert(names, name)
	end
	return names
end

-- Filter items with a predicate function: predicate(name, data) -> boolean
function Shop:GetItemsByFilter(predicate: (string, any) -> boolean): { [string]: any }
	local results = {}
	for name, data in pairs(self.Items) do
		if predicate(name, data) then
			results[name] = data
		end
	end
	return results
end

function Shop:PrintItems()
	for name, data in pairs(self.Items) do
		print(self._typeName .. ": " .. name)
		if type(data) == "table" then
			for key, value in pairs(data) do
				print("  " .. tostring(key) .. ": " .. tostring(value))
			end
		end
	end
end

return Shop
