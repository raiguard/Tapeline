-- ----------------------------------------------------------------------------------------------------
-- UTILITIES

local util = require('__core__/lualib/util')

function util.get_player(obj)
    if type(obj) == 'number' then return game.players[obj]
    else return game.players[obj.player_index] end
end

function util.player_table(player)
    if type(player) == 'number' then
        return global.players[player]
    end
    return global.players[player.index]
end

return util