-- ----------------------------------------------------------------------------------------------------
-- LISTENERS
-- The entry point for the mod, contains all event listeners

local event = require('__stdlib__/stdlib/event/event')
local on_event = event.register

-- local gui = require('gui')
-- local rendering = require('rendering')
local util = require('util')

-- ----------------------------------------------------------------------------------------------------

-- setup global
event.on_init(function()
    global.next_tilegrid_index = 1
    global.perish = {}
    global.end_wait = 3
    -- global.map_settings = get_global_settings()
end)

-- re-register on_tick event if necessary
event.on_load(function()
    if table_size(global.perish) > 0 then
        -- reregister
    end
end)

-- check if the game is multiplayer and take appropriate action
on_event(defines.events.on_player_joined_game, function(e)
    if game.is_multiplayer() then
        if global.end_wait == 3 then
            -- create_warning_dialog(e.player_index)
        end
        global.end_wait = 60
    end
end)

