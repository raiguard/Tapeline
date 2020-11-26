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
  end
}