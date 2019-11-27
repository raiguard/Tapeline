-- ----------------------------------------------------------------------------------------------------
-- EVENT LISTENERS
-- The entry point for the mod. Contains all non-GUI event listeners

local event = require('scripts/lib/event-handler')
local draw_gui = require('scripts/gui/windows/draw')
local edit_gui = require('scripts/gui/windows/edit')
local mod_gui = require('mod-gui')
local select_gui = require('scripts/gui/windows/select')
local tilegrid = require('tilegrid')
local math2d = require('math2d')
local util = require('scripts/lib/util')

-- --------------------------------------------------
-- LOCAL UTILITIES

local abs = math.abs
local floor = math.floor
local TEMP_TILEGRID_CLEAR_DELAY = 60
local area_contains_point = math2d.bounding_box.contains_point

local function setup_player(index)
    local data = {}
    data.settings = {
        auto_clear = true,
        cardinals_only = true,
        grid_type = 1,
        increment_divisor = 5,
        split_divisor = 4,
        log_to_chat = util.get_player(index).mod_settings['log-selection-area'].value
    }
    data.gui = {}
    data.cur_drawing = false
    data.cur_editing = false
    data.cur_selecting = false
    data.tutorial_shown = false
    data.last_capsule_tile = {x=0,y=0}
    global.players[index] = data
end

-- --------------------------------------------------
-- CONDITIONAL HANDLERS

-- finish drawing tilegrids, perish tilegrids
local function on_tick(e)
    local cur_tick = game.ticks_played
    local end_wait = global.end_wait
    local drawing = global.tilegrids.drawing
    local perishing = global.tilegrids.perishing
    for i,t in pairs(drawing) do
        if t.last_capsule_tick+end_wait < cur_tick then
            -- finish up tilegrid
            local player_table = util.player_table(t.player_index)
            local registry = global.tilegrids.registry[i]
            player_table.cur_drawing = false
            -- if the grid is 1x1, just delete it
            if util.position_equals(registry.area.left_top, t.last_capsule_pos) then
                tilegrid.destroy(i)
            else
                if registry.settings.auto_clear then
                    -- add to perishing table
                    perishing[i] = cur_tick + TEMP_TILEGRID_CLEAR_DELAY
                else
                    -- add to editable table
                    global.tilegrids.editable[i] = {area=registry.area, surface_index=t.surface_index}
                end
            end
            drawing[i] = nil
        end
    end
    for i,tick in pairs(perishing) do
        if cur_tick >= tick then
            tilegrid.destroy(i)
            perishing[i] = nil
        end
    end
    if table_size(drawing) == 0 and table_size(perishing) == 0 then
        event.deregister(defines.events.on_tick, on_tick, 'tilegrid_on_tick')
    end
end

-- tapeline draw draws a new tilegrid
local function on_draw_capsule(e)
    if e.item.name ~= 'tapeline-draw' then return end
    local player_table = util.player_table(e.player_index)
    local cur_tile = {x=floor(e.position.x), y=floor(e.position.y)}
    -- check if currently drawing
    if player_table.cur_drawing then
        local drawing = global.tilegrids.drawing[player_table.cur_drawing]
        local registry = global.tilegrids.registry[player_table.cur_drawing]
        local prev_tile = drawing.last_capsule_pos
        drawing.last_capsule_tick = game.ticks_played
        -- if cardinals only, adjust thrown position
        if registry.settings.cardinals_only then
            local origin = registry.area.origin
            if abs(cur_tile.x - origin.x) >= abs(cur_tile.y - origin.y) then
                cur_tile.y = floor(origin.y)
            else
                cur_tile.x = floor(origin.x)
            end
        end
        -- if the current tile position differs from the last known tile position
        if prev_tile.x ~= cur_tile.x or prev_tile.y ~= cur_tile.y then
            -- update existing tilegrid
            drawing.last_capsule_pos = cur_tile
            tilegrid.update(player_table.cur_drawing, cur_tile, drawing, registry)
        end
    else
        -- create new tilegrid
        player_table.cur_drawing = global.next_tilegrid_index
        global.next_tilegrid_index = global.next_tilegrid_index + 1
        tilegrid.construct(player_table.cur_drawing, cur_tile, e.player_index, util.get_player(e).surface.index)
        -- register on_tick
        if not event.is_registered('tilegrid_on_tick') then
            event.register(defines.events.on_tick, on_tick, 'tilegrid_on_tick')
        end
    end
end

-- tapeline edit lets you edit the tilegrid that was clicked on
local function on_edit_capsule(e)
    if e.item.name ~= 'tapeline-edit' then return end
    local player_table = util.player_table(e.player_index)
    local cur_tile = {x=floor(e.position.x), y=floor(e.position.y)}
    -- to avoid spamming messages, check against last tile position
    local prev_tile = player_table.last_capsule_tile
    if prev_tile.x == cur_tile.x and prev_tile.y == cur_tile.y then return end
    player_table.last_capsule_tile = cur_tile
    -- loop through the editable table to see if we clicked on a tilegrid
    local player = util.get_player(e)
    local surface_index = player.surface.index
    local clicked_on = {}
    for i,t in pairs(global.tilegrids.editable) do
        if t.surface_index == surface_index and area_contains_point(t.area, e.position) then
            table.insert(clicked_on, i)
        end
    end
    local size = table_size(clicked_on)
    if size == 0 then
        game.print('Please click on a tilegrid')
        return
    elseif size == 1 then
        -- skip selection dialog
        player.print('clicked on '..serpent.line(clicked_on))
    else
        -- show selection dialog
        select_gui.populate_listbox(e.player_index, clicked_on)
        player_table.cur_selecting = true
    end
    player.clean_cursor()
end

-- --------------------------------------------------
-- STATIC HANDLERS

event.on_init(function()
    -- setup global
    global.tilegrids = {}
    global.tilegrids.drawing = {}
    global.tilegrids.editable = {}
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
    event.load_conditional_handlers{
        tilegrid_on_tick = on_tick,
        on_draw_capsule = on_draw_capsule,
        on_edit_capsule = on_edit_capsule
    }
end)

-- when a player's cursor stack changes
event.register(defines.events.on_player_cursor_stack_changed, function(e)
    local player_table = util.player_table(e.player_index)
    local player = util.get_player(e)
    local stack = player.cursor_stack
    local player_gui = player_table.gui
    -- draw capsule
    if stack and stack.valid_for_read and stack.name == 'tapeline-draw' then
        -- because sometimes it doesn't work properly?
        if player_gui.draw then return end
        if player_table.tutorial_shown == false then
            -- show tutorial window
            player_table.tutorial_shown = true
            player.print{'chat-message.tutorial-hint'}
        end
        local elems, last_value = draw_gui.create(mod_gui.get_frame_flow(player), player.index, player_table.settings)
        player_gui.draw = {elems=elems, last_divisor_value=last_value}
        event.register(defines.events.on_player_used_capsule, on_draw_capsule, 'on_draw_capsule', e.player_index)
    elseif player_gui.draw then
        draw_gui.destroy(player_table.gui.draw.elems.window, player.index)
        player_gui.draw = nil
        event.deregister(defines.events.on_player_used_capsule, on_draw_capsule, 'on_draw_capsule', e.player_index)
    end
    -- edit capsule
    if stack and stack.valid_for_read and stack.name == 'tapeline-edit' then
        -- because sometimes it doesn't work properly?
        if player_gui.select then return end
        local elems = select_gui.create(mod_gui.get_frame_flow(player), player.index)
        player_gui.select = elems
        event.register(defines.events.on_player_used_capsule, on_edit_capsule, 'on_edit_capsule', e.player_index)
    elseif player_gui.select and not player_table.cur_selecting then
        select_gui.destroy(player_gui.select.window, player.index)
        player_gui.select = nil
        event.deregister(defines.events.on_player_used_capsule, on_edit_capsule, 'on_edit_capsule', e.player_index)
    end
end)

event.register(defines.events.on_player_created, function(e)
    setup_player(e.player_index)
end)
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

-- scroll between the items when the player shift+scrolls
event.register({'tapeline-cycle-forwards', 'tapeline-cycle-backwards'}, function(e)
    local player = util.get_player(e)
    local stack = player.cursor_stack
    if stack and stack.valid_for_read then
        if stack.name == 'tapeline-draw' then
            player.cursor_stack.set_stack{name='tapeline-edit', count=1}
        elseif stack.name == 'tapeline-edit' then
            player.cursor_stack.set_stack{name='tapeline-draw', count=1}
        end
    end
end)