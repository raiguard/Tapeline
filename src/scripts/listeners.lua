-- ----------------------------------------------------------------------------------------------------
-- EVENT LISTENERS
-- The entry point for the mod. Contains all non-GUI event listeners

local event = require('scripts/lib/event-handler')
local tilegrid = require('tilegrid')
local util = require('scripts/lib/util')

local floor = math.floor

local function setup_player(index)
    local data = {}
    data.settings = {
        auto_clear = true,
        cardinals_only = false,
        grid_type = 1,
        increment_divisor = 5,
        split_divisor = 4,
        log_to_chat = util.get_player(index).mod_settings['log-selection-area'].value
    }
    data.cur_drawing = false
    data.cur_editing = false
    global.players[index] = data
end

event.on_init(function()
    -- setup global
    global.tilegrids = {}
    global.tilegrids.drawing = {}
    global.tilegrids.perishing = {}
    global.tilegrids.registry = {}
    global.players = {}
    global.next_tilegrid_index = 1
    -- set end_wait for a singleplayer game
    global.end_wait = 3
    -- create player data for any existing players
    for i,player in pairs(game.players) do
        setup_player(i)
    end
end)

event.on_load(function()
    -- re-register conditional handlers if needed
    event.load_conditional_events{
        on_tapeline_capsule = on_capsule
    }
end)

event.register(defines.events.on_player_used_capsule, function(e)
    if not e.item.name == 'tapeline-capsule' then return end
    local player_data = util.player_table(e.player_index)
    local cur_tile = {x=floor(e.position.x), y=floor(e.position.y)}
    -- check if currently drawing
    if player_data.cur_drawing then
        local drawing = global.tilegrids.drawing[player_data.cur_drawing]
        local prev_tile = drawing.last_capsule_pos
        -- if the current tile position differs from the last known tile position
        if prev_tile.x ~= cur_tile.x or prev_tile.y ~= cur_tile.y then
            -- update existing tilegrid
            drawing.last_capsule_pos = cur_tile
            drawing.last_capsule_tick = game.ticks_played
            tilegrid.update(player_data.cur_drawing, cur_tile)
        end
    else
        -- create new tilegrid
        player_data.cur_drawing = global.next_tilegrid_index
        global.next_tilegrid_index = global.next_tilegrid_index + 1
        tilegrid.construct(player_data.cur_drawing, cur_tile, e.player_index)
    end
end)

event.register(defines.events.on_player_created, function(e) setup_player(e.player_index) end)
event.register(defines.events.on_player_joined_game, function(e)
    -- check if game is multiplayer
    if game.is_multiplayer() then
        -- check if end_wait has already been adjusted
        if global.end_wait == 3 then
            global.end_wait = 60
            game.print{'chat-message.mp-latency-message'}
        end
    end
end)