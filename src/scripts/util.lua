-- ----------------------------------------------------------------------------------------------------
-- UTILITIES

local util = {}

function util.get_player(obj)
    if type(obj) == 'number' then return game.players[obj]
    else return game.players[obj.player_index]
    end
end

function util.player_table(player)
    return type(player) == 'number' and global.players[player] or global.players[player.index]
end

return util