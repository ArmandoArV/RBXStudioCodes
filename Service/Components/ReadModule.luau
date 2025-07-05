-- ReadModule: Utility to read properties and values from a ModuleScript
-- Usage: local readModule = require(path.to.ReadModule)
--        local data = readModule.read(moduleScript)

local ReadModule = {}

-- Reads all properties and values from a ModuleScript
-- @param moduleScript (table) The required ModuleScript table
-- @return table: A shallow copy of the module's properties and values
function ReadModule.read(moduleScript)
    assert(type(moduleScript) == "table", "ReadModule.read expects a table (required ModuleScript)")
    local result = {}
    for key, value in pairs(moduleScript) do
        result[key] = value
    end
    return result
end

return ReadModule
