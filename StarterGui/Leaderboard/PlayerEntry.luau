-- PlayerEntry.luau
-- Represents a player in the leaderboard

local PlayerEntry = {}
PlayerEntry.__index = PlayerEntry

function PlayerEntry.new(player, frame)
    local self = setmetatable({}, PlayerEntry)
    self.player = player
    self.frame = frame
    self.team = player.Team and player.Team.Name or nil
    self.kills = 0
    self.deaths = 0
    self.ping = 0
    return self
end

function PlayerEntry:updateTeam(newTeam)
    self.team = newTeam
end

function PlayerEntry:updateKills(kills)
    self.kills = kills
end

function PlayerEntry:updateDeaths(deaths)
    self.deaths = deaths
end

function PlayerEntry:updatePing(ping)
    self.ping = ping
end

return PlayerEntry
