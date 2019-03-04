script.on_event(defines.events.on_lua_shortcut, function(e)

    if e.prototype_name == 'tapeline' then

        -- setup constants
        local player = game.players[e.player_index]

        -- clean player cursor, and insert tapeline item (for debugging purposes, insert blueprint)
        player.clean_cursor()
        player.cursor_stack.set_stack({name = 'blueprint'})

    end

end)