script.on_event(defines.events.on_lua_shortcut, function(e)

    if e.prototype_name == 'tapeline' then 

        local player = game.players[e.player_index]

        player.clean_cursor()
        player.cursor_stack.set_stack({name = 'blueprint-book'})

    end

end)