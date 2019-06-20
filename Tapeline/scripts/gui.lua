function show_menu(player)

    local flow = mod_gui.get_frame_flow(player)
    local container = flow.tapeline_menu_container
    local menu_frame = flow.tapeline_mainmenu_frame
    if not container then
        container = flow.add {
            type = 'flow',
            name = 'tapeline_menu_container',
            direction = 'horizontal'
        }
        menu_frame = container.add {
            type = 'frame',
            name = 'tapeline_menu_frame',
            direction = 'vertical',
            caption = 'Tapeline'
        }@

        menu_frame.add {
            type = 'label',
            name = 'tapeline_menu_button',
            caption = 'Grid type:',
            style = 'subheader_caption_label'
        }

        stdlib.logger.log(game.surfaces)

    else
        container.visible = true
    end

end

function hide_menu(player)

    local container = mod_gui.get_frame_flow(player).tapeline_menu_container
    if container then
        container.visible = false
    end

end

function on_item(e)

    local player = game.players[e.player_index]
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.name == 'tapeline-capsule' then
        show_menu(player)
    else
        hide_menu(player)
    end

end

stdlib.event.register(defines.events.on_player_cursor_stack_changed, on_item)