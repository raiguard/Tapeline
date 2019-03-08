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
    Logger.log(area)

    -- draw ruler on ground
    if area.height > 1 and area.width > 1 then rendering.draw_rectangle{color={r=0.55,g=0.55,b=0.55,a=1}, filled=true, left_top={(area.left_top.x - 0.2),(area.left_top.y - 0.2)}, right_bottom={(area.left_top.x),(area.left_top.y)}, surface=surfaceIndex, time_to_live=180} end

    if area.height > 1 then
        rendering.draw_text{text=area.height, surface=surfaceIndex, target={(area.left_top.x - 1.8), area.midpoints.y}, color={r=0.65,g=0.65,b=0.65}, alignment='center', scale=3, orientation=0.75, time_to_live=180}
        for i=0,(area.height - 1) do
            local c = ((i % 2 == 0) and 0.3 or 0.55)
            rendering.draw_rectangle{color={r=c,g=c,b=c,a=1}, filled=true, left_top={(area.left_top.x - 0.2),(area.left_top.y + i)}, right_bottom={(area.left_top.x),(area.left_top.y + (i + 1))}, surface=surfaceIndex, time_to_live=180}
        end
    end

    if area.width > 1 then
        rendering.draw_text{text=area.width, surface=surfaceIndex, target={area.midpoints.x, (area.left_top.y - 1.8)}, color={r=0.65,g=0.65,b=0.65}, alignment='center', scale=3, time_to_live=180}
        for i=0,(area.width - 1) do
            local c = ((i % 2 == 0) and 0.3 or 0.55)
            rendering.draw_rectangle{color={r=c,g=c,b=c,a=1}, filled=true, left_top={(area.left_top.x + i),(area.left_top.y - 0.2)}, right_bottom={(area.left_top.x + (i + 1)),(area.left_top.y)}, surface=surfaceIndex, time_to_live=180}
        end
    end

    

end

Event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, measure_area)
Event.register(defines.events.on_lua_shortcut, on_shortcut_pressed)
Event.register('get-tapeline-tool', on_custom_input)