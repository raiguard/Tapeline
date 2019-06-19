function on_hotkey(e)

    local player = game.players[e.player_index]
    if player.clean_cursor() then player.cursor_stack.set_stack({name = 'tapeline-capsule'}) end

end

stdlib.event.register('get-tapeline-tool', on_hotkey)