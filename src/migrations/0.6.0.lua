-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TAPELINE 0.6.0 MIGRATIONS

local mod_gui = require('mod-gui')

-- create missing global tables
global.drawing = {}
global.tilegrids = {}
-- move all tilegrid tables to tilegrids subtable
for k,v in pairs(global) do
    if type(k) == 'number' then
        global.tilegrids[k] = table.deepcopy(v)
        global[k] = nil
    end
end
-- rename players table
if global.player_data then
    global.players = table.deepcopy(global.player_data)
    global.player_data = nil

    for i,p in pairs(game.players) do
        if global.players[i] then
            -- remove old settings window if it's open
            local window = mod_gui.get_frame_flow(p).tapeline_menu_frame
            if window then window.destroy() end
            local player_table = global.players[i]
            -- convert cur_editing from bool to number
            player_table.cur_editing = 0
            -- if the player is currently drawing, add that tilegrid to the drawing table, then convert cur_drawing to an int
            if player_table.cur_drawing then
                global.drawing[player_table.cur_tilegrid_index] = {
                    player = p,
                    last_capsule_tick = player_table.last_capsule_tick,
                    last_capsule_pos = player_table.last_capsule_pos
                }
            end
            global.players[i].cur_drawing = 0
            -- clean up now unnecessary player data
            player_table.cur_tilegrid_index = nil
            player_table.last_capsule_tick = nil
            player_table.last_capsule_pos = nil
            player_table.center_gui = nil
            player_table.mod_gui = nil
            -- if the player is currently holding a tapeline capsule, destroy it
            if p.cursor_stack and p.cursor_stack.valid_for_read and p.cursor_stack.name == 'tapeline-capsule' then
                p.clean_cursor()
            end
        end
    end
end