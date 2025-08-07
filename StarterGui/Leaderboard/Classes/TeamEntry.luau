-- TeamEntry.luau
-- Represents a team in the leaderboard

local TeamEntry = {}
TeamEntry.__index = TeamEntry

function TeamEntry.new(teamName, frame, layoutOrder)
    local self = setmetatable({}, TeamEntry)
    self.teamName = teamName
    self.frame = frame
    self.layoutOrder = layoutOrder
    self.players = {}
    return self
end

function TeamEntry:addPlayer(playerEntry)
    table.insert(self.players, playerEntry)
end

function TeamEntry:removePlayer(playerName)
    for i, entry in ipairs(self.players) do
        if entry.player.Name == playerName then
            table.remove(self.players, i)
            break
        end
    end
end

return TeamEntry
