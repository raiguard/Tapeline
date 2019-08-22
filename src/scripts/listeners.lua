-- ----------------------------------------------------------------------------------------------------
-- LISTENERS
-- The entry point for the mod, contains all non-gui event listeners

local event = require('__stdlib__/stdlib/event/event')
local on_event = event.register

local gui = require('gui')
local tilegrid = require('tilegrid')
local util = require('util')

-- ----------------------------------------------------------------------------------------------------

-- setup global
event.on_init(function()
    global.end_wait = 3
    global.next_tilegrid_index = 1
    global.map_settings = tilegrid.get_global_settings()
    global.drawing = {}
    global.tilegrids = {}
    global.perish = {}
    global.players = {}
end)

-- re-register on_tick event if necessary
event.on_load(function()
    if table_size(global.drawing) > 0 or table_size(global.perish) > 0 then
        event.register(defines.events.on_tick, tilegrid.on_tick)
    end
end)

-- check if the game is multiplayer and take appropriate action
on_event(defines.events.on_player_joined_game, function(e)
    if game.is_multiplayer() then
        if global.end_wait == 3 then
            game.print{'chat-message.mp-latency-message'}
            global.end_wait = 60
        end
    end
end)

-- when a player is created
on_event(defines.events.on_player_created, function(e)
    local data = {}
    data.cur_drawing = 0
    data.cur_editing = 0
    local settings = {}
    settings.grid_type = 1
    settings.increment_divisor = 5
    settings.split_divisor = 4
    settings.grid_autoclear = false
    settings.restrict_to_cardinals = false
    data.settings = settings
    global.players[e.player_index] = data
    log(serpent.block(global))
end)

-- when a capsule is thrown
on_event(defines.events.on_player_used_capsule, tilegrid.on_capsule)

-- when a player's cursor stack changes
on_event(defines.events.on_player_cursor_stack_changed, function(e)
    local player = game.players[e.player_index]
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.name == 'tapeline-capsule' then
        -- if holding the tapeline
		gui.open(player)
    else
        -- hide settings GUI
        gui.close(player)
    end
end)

-- when the settings button is clicked
on_event('tapeline-open-gui', function(e)
    local player = util.get_player(e)
    local selected = player.selected
    local player_data = util.player_table(player)

    if selected and selected.name == 'tapeline-settings-button' then
        if player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == 'tapeline-capsule' then
            player.surface.create_entity {
                name = 'flying-text',
                position = selected.position,
                text = {'flying-text.capsule-warning'}
            }
        else
            for k,v in pairs(global.tilegrids) do
                if type(v) == 'table' and v.button and v.button == selected then
                    player_data.cur_editing = k
                    break
                end
            end
            gui.open(player, player_data.cur_editing)
        end
	end
end)