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

    -- compute selection dimensions and area
    local area = e.area
    local width = math.abs(math.floor(area.left_top.x) - math.ceil(area.right_bottom.x))
    local height = math.abs(math.floor(area.left_top.y) - math.ceil(area.right_bottom.y))
    utils.log('Width: ' .. width .. '   Height: ' .. height, false)
    utils.log(e.area.left_top)
    utils.log(e.area.right_bottom)
    -- draw ruler on ground
    local player = game.players[e.player_index]

    -- rendering.draw_line{color={r=1,g=1,b=1}, width=6, from=area.left_top, to=area.right_bottom, surface=1}
    rendering.draw_line{color={r=1,g=0,b=0,a=0.1}, width=4, from={area.left_top.x,area.left_top.y}, to={area.left_top.x,area.right_bottom.y}, surface=1}
    rendering.draw_line{color={r=1,g=0,b=0,a=0.1}, width=4, from={area.left_top.x,area.left_top.y}, to={area.right_bottom.x,area.left_top.y}, surface=1}

end)