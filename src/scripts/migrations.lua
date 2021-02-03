local global_data = require("scripts.global-data")
local player_data = require("scripts.player-data")

return {
  ["2.0.0"] = function()
    -- NUKE EVERYTHING
    global = {}
    rendering.clear("Tapeline")

    -- re-init
    global_data.init()
    for i, player in pairs(game.players) do
      player_data.init(i)
      player_data.refresh(player, global.players[i])
    end
  end,
  ["2.0.3"] = function()
    -- reset all players' build distance bonuses
    for _, player in pairs(game.players) do
      if player.character then
        local build_distance = player.character_build_distance_bonus
        if build_distance >= 1000000 then
          player.character_build_distance_bonus = build_distance - (math.floor(build_distance / 1000000) * 1000000)
        end
      end
    end
  end
}
