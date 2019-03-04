function create_tapeline(player)
    player.clean_cursor()
    player.cursor_stack.set_stack({name = 'tapeline-item'})
end

script.on_event(defines.events.on_lua_shortcut, function(e)

    if e.prototype_name ~= 'tapeline-shortcut' then return end

    -- setup local constants
    local player = game.players[e.player_index]

    create_tapeline(player)

end)