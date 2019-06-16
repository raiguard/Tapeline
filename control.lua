local stdlib = {}
stdlib.color = require("__stdlib__/stdlib/utils/color")
stdlib.event = require("__stdlib__/stdlib/event/event")
stdlib.area = require("__stdlib__/stdlib/area/area")
stdlib.logger = require("__stdlib__/stdlib/misc/logger").new("Tapeline", "Tapeline_Debug", false)

function on_custom_input(e)

    local player = game.players[e.player_index]
    if player.clean_cursor() then player.cursor_stack.set_stack({name = "tapeline-dummy"}) end

end

function measure_area(e)

    if e.item ~= "tapeline-tool" then return end

    local player = game.players[e.player_index]
    local surfaceIndex = player.surface.index
    local is_alt_selection = e.name == defines.events.on_player_alt_selected_area

    -- retrieve mod settings
    local player_mod_settings = player.mod_settings
    local mod_settings = {}
	mod_settings.draw_tilegrid_on_ground = player_mod_settings["draw-tilegrid-on-ground"].value
    mod_settings.tilegrid_line_width = player_mod_settings["tilegrid-line-width"].value
    mod_settings.tilegrid_clear_delay = player_mod_settings["tilegrid-clear-delay"].value * 60
    mod_settings.tilegrid_group_divisor = player_mod_settings["tilegrid-group-divisor"].value
	mod_settings.tilegrid_split_divisor = player_mod_settings["tilegrid-split-divisor"].value
	
	mod_settings.tilegrid_background_color = stdlib.color.set(defines.color[player_mod_settings["tilegrid-background-color"].value], 0.6)
	mod_settings.tilegrid_border_color = stdlib.color.set(defines.color[player_mod_settings["tilegrid-border-color"].value])
	mod_settings.tilegrid_label_color = stdlib.color.set(defines.color[player_mod_settings["tilegrid-label-color"].value], 0.8)
	mod_settings.tilegrid_div_color = {}
	mod_settings.tilegrid_div_color[1] = stdlib.color.set(defines.color[player_mod_settings["tilegrid-color-1"].value])
	mod_settings.tilegrid_div_color[2] = stdlib.color.set(defines.color[player_mod_settings["tilegrid-color-2"].value])
	mod_settings.tilegrid_div_color[3] = stdlib.color.set(defines.color[player_mod_settings["tilegrid-color-3"].value])
	mod_settings.tilegrid_div_color[4] = stdlib.color.set(defines.color[player_mod_settings["tilegrid-color-4"].value])

	mod_settings.label_primary_size = 2
	mod_settings.label_secondary_size = 1
	mod_settings.label_primary_offset = 1.1
	mod_settings.label_secondary_offset = 0.6

    -- generate area
    local area = stdlib.area(e.area):normalize():ceil():corners()
    area.size,area.width,area.height = area:size()
	area.midpoints = stdlib.area.center(area)
	
	-- calculate tilegrid divisors
	local tilegrid_divisors = {}

	if is_alt_selection then
		tilegrid_divisors[1] = { x = 1, y = 1 }
		tilegrid_divisors[2] = { x = (area.width > 1 and (area.width / mod_settings.tilegrid_split_divisor) or area.width), y = (area.height > 1 and (area.height / mod_settings.tilegrid_split_divisor) or area.height) }
		tilegrid_divisors[3] = { x = (area.width > 1 and (area.midpoints.x - area.left_top.x) or area.width), y = (area.height > 1 and (area.midpoints.y - area.left_top.y) or area.height) }
	else
		for i=1,4 do
			table.insert(tilegrid_divisors, { x = mod_settings.tilegrid_group_divisor ^ (i - 1), y = mod_settings.tilegrid_group_divisor ^ (i - 1) })
		end
	end

	-- log dimensions to chat, if desired
	if player_mod_settings["log-selection-area"].value == true then player.print("Dimensions: " .. area.width .. "x" .. area.height) end

	-- ----------------------------------------------------------------------------------------------------
	-- DRAW TILEGRID

    -- background
    rendering.draw_rectangle {
        color = mod_settings.tilegrid_background_color,
        filled = true,
        left_top = {area.left_top.x,area.left_top.y},
        right_bottom = {area.right_bottom.x,area.right_bottom.y},
        surface = surfaceIndex,
        time_to_live = mod_settings.tilegrid_clear_delay,
        draw_on_ground = mod_settings.draw_tilegrid_on_ground,
        players = { player }
	}
	
	-- grids
	for k,t in pairs(tilegrid_divisors) do
		for i=t.x,area.width,t.x do
			rendering.draw_line {
				color = mod_settings.tilegrid_div_color[k],
				width = mod_settings.tilegrid_line_width,
				from = {(area.left_top.x + i),area.left_top.y},
				to = {(area.left_bottom.x + i),area.left_bottom.y},
				surface = surfaceIndex,
				time_to_live = mod_settings.tilegrid_clear_delay,
				draw_on_ground = mod_settings.draw_tilegrid_on_ground,
				players = { player }
			}
		end

		for i=t.y,area.height,t.y do
			rendering.draw_line {
				color = mod_settings.tilegrid_div_color[k],
				width = mod_settings.tilegrid_line_width,
				from = {area.left_top.x,(area.left_top.y + i)},
				to = {area.right_top.x,(area.left_top.y + i)},
				surface = surfaceIndex,
				time_to_live = mod_settings.tilegrid_clear_delay,
				draw_on_ground = mod_settings.draw_tilegrid_on_ground,
				players = { player }
			}
		end
	end

    -- border
    rendering.draw_rectangle {
        color = mod_settings.tilegrid_border_color,
        width = mod_settings.tilegrid_line_width,
        filled = false,
        left_top = {area.left_top.x,area.left_top.y},
        right_bottom = {area.right_bottom.x,area.right_bottom.y},
        surface = surfaceIndex,
        time_to_live = mod_settings.tilegrid_clear_delay,
        draw_on_ground = mod_settings.draw_tilegrid_on_ground,
        players = { player }
	}

	-- labels
	if area.height > 1 then
        rendering.draw_text {
            text = area.height,
            surface = surfaceIndex,
            target = {(area.left_top.x - 1.1), area.midpoints.y},
            color = mod_settings.tilegrid_label_color,
            alignment = "center",
            scale = 2,
            orientation = 0.75,
            time_to_live = mod_settings.tilegrid_clear_delay,
            players = { player }
        }
	end
	
    if area.width > 1 then
        rendering.draw_text {
            text = area.width,
            surface = surfaceIndex,
            target = {area.midpoints.x, (area.left_top.y - 1.1)},
            color = mod_settings.tilegrid_label_color,
            alignment = "center",
            scale = 2,
            time_to_live = mod_settings.tilegrid_clear_delay,
            players = { player }
        }
	end
	
	-- ----------------------------------------------------------------------------------------------------

end

stdlib.event.register("get-tapeline-tool", on_custom_input)
stdlib.event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, measure_area)