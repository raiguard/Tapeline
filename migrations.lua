local player_data = require("__Tapeline__/player-data")

return {
  ["2.0.0"] = function()
    -- NUKE EVERYTHING
    global = {}
    rendering.clear("Tapeline")

    -- re-init
    global.players = {}
    for _, player in pairs(game.players) do
      player_data.init(player.index)
      player_data.refresh(player, global.players[player.index])
    end
  end,
  ["2.0.3"] = function()
    -- reset all players' build distance bonuses
    for _, player in pairs(game.players) do
      if player.character then
        local build_distance = player.character_build_distance_bonus
        if build_distance >= 1000000 then
          player.character_build_distance_bonus = build_distance - (math.floor(build_distance / 1000000) * 1000000) --[[@as uint]]
        end
      end
    end
  end,
}
