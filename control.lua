local constants = require('constants')
local utils = require('utils')

function create_tapeline(player)
    player.clean_cursor()
    player.cursor_stack.set_stack({name = constants.tapelineItemName})
end

script.on_event(defines.events.on_lua_shortcut, function(e)

    if e.prototype_name ~= constants.tapelineShortcutName then return end

    -- setup local constants
    local player = game.players[e.player_index]

    create_tapeline(player)

end)

script.on_event(defines.events.on_player_selected_area, function(e)

    if e.item ~= constants.tapelineItemName then return end

    local player = game.players[e.player_index]
    local surfaceIndex = player.surface.index

    -- calculate positioning constants
    local area = e.area
    local aligned_area = {}
    aligned_area.left = {}
    aligned_area.right = {}
    aligned_area.left.x = math.floor(area.left_top.x)
    aligned_area.left.y = math.floor(area.left_top.y)
    aligned_area.right.x = math.ceil(area.right_bottom.x)
    aligned_area.right.y = math.ceil(area.right_bottom.y)
    aligned_area.width = math.abs(aligned_area.left.x - aligned_area.right.x)
    aligned_area.height = math.abs(aligned_area.left.y - aligned_area.right.y)

    -- draw ruler on ground
    if aligned_area.height > 1 and aligned_area.width > 1 then rendering.draw_rectangle{color={r=0.55,g=0.55,b=0.55,a=1}, filled=true, left_top={(aligned_area.left.x - 0.2),(aligned_area.left.y - 0.2)}, right_bottom={(aligned_area.left.x),(aligned_area.left.y)}, surface=surfaceIndex, time_to_live=180} end

    if aligned_area.height > 1 then
        rendering.draw_text{text=aligned_area.height, surface=surfaceIndex, target={(aligned_area.left.x - 1.8), (aligned_area.left.y + (aligned_area.height / 2))}, color={r=0.65,g=0.65,b=0.65}, alignment='center', scale=3, orientation=0.75, time_to_live=180}
        for i=0,(aligned_area.height - 1) do
            local c = ((i % 2 == 0) and 0.3 or 0.55)
            rendering.draw_rectangle{color={r=c,g=c,b=c,a=1}, filled=true, left_top={(aligned_area.left.x - 0.2),(aligned_area.left.y + i)}, right_bottom={(aligned_area.left.x),(aligned_area.left.y + (i + 1))}, surface=surfaceIndex, time_to_live=180}
        end
    end

    if aligned_area.width > 1 then
        rendering.draw_text{text=aligned_area.width, surface=surfaceIndex, target={(aligned_area.left.x + (aligned_area.width / 2)), (aligned_area.left.y - 1.8)}, color={r=0.65,g=0.65,b=0.65}, alignment='center', scale=3, time_to_live=180}
        for i=0,(aligned_area.width - 1) do
            local c = ((i % 2 == 0) and 0.3 or 0.55)
            rendering.draw_rectangle{color={r=c,g=c,b=c,a=1}, filled=true, left_top={(aligned_area.left.x + i),(aligned_area.left.y - 0.2)}, right_bottom={(aligned_area.left.x + (i + 1)),(aligned_area.left.y)}, surface=surfaceIndex, time_to_live=180}
        end
    end
    

end)