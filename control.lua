local constants = require('constants')
local Event = require('__stdlib__/stdlib/event/event')
local Area = require('__stdlib__/stdlib/area/area')
local Logger = require('__stdlib__/stdlib/misc/logger').new('Tapeline', 'Tapeline_Debug', constants.isDebugMode)

function create_tapeline(player)
    player.clean_cursor()
    player.cursor_stack.set_stack({name = constants.tapelineItemName})
end

function on_shortcut_pressed(e)

    if e.prototype_name ~= constants.tapelineShortcutName then return end

    -- setup local constants
    local player = game.players[e.player_index]

    create_tapeline(player)

end

function on_custom_input(e)

    create_tapeline(game.players[e.player_index])

end

function measure_area(e)

    if e.item ~= constants.tapelineItemName then return end

    local player = game.players[e.player_index]
    local surfaceIndex = player.surface.index

    -- calculate area constants
    local area = Area.new(e.area)
    area = Area.ceil(area)
    area = Area.corners(area)
    area.size,area.width,area.height = area:size()
    area.midpoints = Area.center(area)
    
    if player.mod_settings['log-selection-area'].value == true then player.print('Dimensions: ' .. area.width .. 'x' .. area.height) end

    local tilegrid_line_width = player.mod_settings["tilegrid-line-width"].value

    -- draw tile grid
    rendering.draw_rectangle{color=constants.colors.tilegrid_border, width=tilegrid_line_width, filled=false, left_top={area.left_top.x,area.left_top.y}, right_bottom={area.right_bottom.x,area.right_bottom.y}, surface=surfaceIndex, time_to_live=180, draw_on_ground=1}
    for i=1,(area.height - 1) do
        rendering.draw_line{color=constants.colors.tilegrid_div[(i % 100 == 0 and 100 or (i % 25 == 0 and 25 or (i % 5 == 0 and 5 or 1)))], width=tilegrid_line_width, from={(area.left_top.x),(area.left_top.y + i)}, to={area.right_top.x,(area.left_top.y + i)}, surface=surfaceIndex, time_to_live=180, draw_on_ground=1}
    end

    for i=1,(area.width - 1) do
        rendering.draw_line{color=constants.colors.tilegrid_div[(i % 100 == 0 and 100 or (i % 25 == 0 and 25 or (i % 5 == 0 and 5 or 1)))], width=tilegrid_line_width, from={(area.left_top.x + i),area.left_top.y}, to={(area.left_top.x + i),area.right_bottom.y}, surface=surfaceIndex, time_to_live=180, draw_on_ground=1}
    end

    if area.height > 1 then rendering.draw_text{text=area.height, surface=surfaceIndex, target={(area.left_top.x - 1.2), area.midpoints.y}, color=constants.colors.tilegrid_label, alignment='center', scale=2, orientation=0.75, time_to_live=180} end
    if area.width > 1 then rendering.draw_text{text=area.width, surface=surfaceIndex, target={area.midpoints.x, (area.left_top.y - 1.2)}, color=constants.colors.tilegrid_label, alignment='center', scale=2, time_to_live=180} end

end

Event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, measure_area)
Event.register('get-tapeline-tool', on_custom_input)
Event.register(defines.events.on_lua_shortcut, on_shortcut_pressed)