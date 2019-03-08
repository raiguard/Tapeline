local constants = require('constants')
local Event = require('__stdlib__/stdlib/event/event')
local Area = require('__stdlib__/stdlib/area/area')
local Logger = require('__stdlib__/stdlib/misc/logger').new('Tapeline', 'Tapeline_Debug', constants.isDebugMode)

function create_tapeline(player)
    player.clean_cursor()
    player.cursor_stack.set_stack({name = 'tapeline-tool'})
end

function on_custom_input(e)

    create_tapeline(game.players[e.player_index])

end

function on_shortcut_pressed(e)

    if e.prototype_name ~= 'tapeline-shortcut' then return end

    create_tapeline(game.players[e.player_index])

end

function measure_area(e)

    if e.item ~= 'tapeline-tool' then return end

    local player = game.players[e.player_index]
    local surfaceIndex = player.surface.index

    -- calculate area constants
    local area = Area.new(e.area)
    area = Area.ceil(area)
    area = Area.corners(area)
    area.size,area.width,area.height = area:size()
    area.midpoints = Area.center(area)
    -- retrieve mod settings
    local draw_tilegrid_on_ground = player.mod_settings['draw-tilegrid-on-ground'].value
    local tilegrid_line_width = player.mod_settings['tilegrid-line-width'].value
    local tilegrid_clear_delay = player.mod_settings['tilegrid-clear-delay'].value * 60
    local tilegrid_group_divisor = player.mod_settings['tilegrid-group-divisor'].value

    -- draw tile grid
    rendering.draw_rectangle {
        color=constants.colors.tilegrid_background,
        filled=true,
        left_top={area.left_top.x,area.left_top.y},
        right_bottom={area.right_bottom.x,area.right_bottom.y},
        surface=surfaceIndex,
        time_to_live=tilegrid_clear_delay,
        draw_on_ground=draw_tilegrid_on_ground
    }
    
    for i=1,(area.height - 1) do
        rendering.draw_line {
            color=constants.colors.tilegrid_div[(i % (tilegrid_group_divisor ^ 3) == 0 and 4 or (i % (tilegrid_group_divisor ^ 2) == 0 and 3 or (i % (tilegrid_group_divisor ^ 1) == 0 and 2 or 1)))],
            width=tilegrid_line_width,
            from={(area.left_top.x),(area.left_top.y + i)},
            to={area.right_top.x,(area.left_top.y + i)},
            surface=surfaceIndex,
            time_to_live=tilegrid_clear_delay,
            draw_on_ground=draw_tilegrid_on_ground
        }
    end

    for i=1,(area.width - 1) do
        rendering.draw_line {
            color=constants.colors.tilegrid_div[(i % (tilegrid_group_divisor ^ 3) == 0 and 4 or (i % (tilegrid_group_divisor ^ 2) == 0 and 3 or (i % (tilegrid_group_divisor ^ 1) == 0 and 2 or 1)))],
            width=tilegrid_line_width,
            from={(area.left_top.x + i),area.left_top.y},
            to={(area.left_top.x + i),area.right_bottom.y},
            surface=surfaceIndex,
            time_to_live=tilegrid_clear_delay,
            draw_on_ground=draw_tilegrid_on_ground
        }
    end

    rendering.draw_rectangle {
        color=constants.colors.tilegrid_border,
        width=tilegrid_line_width,
        filled=false,
        left_top={area.left_top.x,area.left_top.y},
        right_bottom={area.right_bottom.x,area.right_bottom.y},
        surface=surfaceIndex,
        time_to_live=tilegrid_clear_delay,
        draw_on_ground=draw_tilegrid_on_ground
    }

    if area.height > 1 then
        rendering.draw_text {
            text=area.height,
            surface=surfaceIndex,
            target={(area.left_top.x - 1.2),
            area.midpoints.y},
            color=constants.colors.tilegrid_label,
            alignment='center',
            scale=2,
            orientation=0.75,
            time_to_live=tilegrid_clear_delay
        }
    end

    if area.width > 1 then
        rendering.draw_text {
            text=area.width,
            surface=surfaceIndex,
            target={area.midpoints.x, (area.left_top.y - 1.2)},
            color=constants.colors.tilegrid_label,
            alignment='center',
            scale=2,
            time_to_live=tilegrid_clear_delay
        }
    end

    -- log dimensions to chat, if desired
    if player.mod_settings['log-selection-area'].value == true then player.print('Dimensions: ' .. area.width .. 'x' .. area.height) end

end

function cleanup_tapeline_tool(e)

    local player = game.players[e.player_index]
    local is_trash = e.name == defines.events.on_player_trash_inventory_changed
    local inventory

    if is_trash then inventory = player.get_inventory(defines.inventory.player_trash)
    elseif is_trash == false then inventory = player.get_main_inventory()
    else return
    end

    local tapeline_tool = game.item_prototypes['tapeline-tool'] and inventory.find_item_stack('tapeline-tool')
        
    if tapeline_tool then return tapeline_tool.clear() end

    return

end

Event.register('get-tapeline-tool', on_custom_input)
Event.register(defines.events.on_lua_shortcut, on_shortcut_pressed)
Event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, measure_area)
Event.register({defines.events.on_player_main_inventory_changed, defines.events.on_player_trash_inventory_changed}, cleanup_tapeline_tool)