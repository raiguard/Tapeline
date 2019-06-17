function on_load(e)



end

function on_change(e)

    retrieve_mod_settings(game.players[e.player_index])

end

-- retrieve mod settings for the specified player
function retrieve_mod_settings(player)

    stdlib.logger.log('retrieve mod settings')
    -- retrieve mod settings
    local player_mod_settings = player.mod_settings
    local mod_settings = {}
	mod_settings.draw_tilegrid_on_ground = player_mod_settings['draw-tilegrid-on-ground'].value
    mod_settings.tilegrid_line_width = player_mod_settings['tilegrid-line-width'].value
    mod_settings.tilegrid_clear_delay = player_mod_settings['tilegrid-clear-delay'].value * 60
    mod_settings.tilegrid_group_divisor = player_mod_settings['tilegrid-group-divisor'].value
	mod_settings.tilegrid_split_divisor = player_mod_settings['tilegrid-split-divisor'].value
	
	mod_settings.tilegrid_background_color = stdlib.color.set(defines.color[player_mod_settings['tilegrid-background-color'].value], 0.6)
	mod_settings.tilegrid_border_color = stdlib.color.set(defines.color[player_mod_settings['tilegrid-border-color'].value])
	mod_settings.tilegrid_label_color = stdlib.color.set(defines.color[player_mod_settings['tilegrid-label-color'].value], 0.8)
	mod_settings.tilegrid_div_color = {}
	mod_settings.tilegrid_div_color[1] = stdlib.color.set(defines.color[player_mod_settings['tilegrid-color-1'].value])
	mod_settings.tilegrid_div_color[2] = stdlib.color.set(defines.color[player_mod_settings['tilegrid-color-2'].value])
	mod_settings.tilegrid_div_color[3] = stdlib.color.set(defines.color[player_mod_settings['tilegrid-color-3'].value])
	mod_settings.tilegrid_div_color[4] = stdlib.color.set(defines.color[player_mod_settings['tilegrid-color-4'].value])

	mod_settings.label_primary_size = 2
	mod_settings.label_secondary_size = 1
	mod_settings.label_primary_offset = 1.1
    mod_settings.label_secondary_offset = 0.6
    
    return mod_settings

end

stdlib.event.register({defines.events.on_runtime_mod_setting_changed, defines.events.on_player_joined_game}, on_change)