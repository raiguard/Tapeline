-- ----------------------------------------------------------------------------------------------------
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
global.players = table.deepcopy(global.player_data or {})
global.player_data = nil

for i,p in pairs(game.players) do
    if global.players[i] then
        -- remove old settings window if it's open
        local window = mod_gui.get_frame_flow(p).tapeline_menu_frame
        if window then window.destroy() end
        -- convert cur_editing from bool to number
        global.players[i].cur_editing = 0
        -- add cur_drawing
        global.players[i].cur_drawing = 0
    end
end