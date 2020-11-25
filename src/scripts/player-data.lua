local constants = require("constants")

local player_data = {}

function player_data.init(player_index)
  global.players[player_index] = {
    flags = {
      editing = false,
      drawing = false,
      placed_entity = false,
      shift_placed_entity = false
    },
    last_entity = nil,
    settings = {
      tape_mode = "increment",
      increment_divisor = 5,
      split_divisor = 4
    },
    tapes = {
      editing = nil,
      drawing = nil
    }
  }
end

function player_data.update_settings(player, player_table)
  local player_settings = player.mod_settings
  local settings = player_table.settings
  for internal, prototype in pairs(constants.setting_names) do
    if string.find(internal, "color") then
      settings[internal] = (
        game.json_to_table(player_settings[prototype].value) or game.json_to_table(constants.default_colors[internal])
      )
    else
      settings[internal] = player_settings[prototype].value
    end
  end
  player_table.settings = settings
end

function player_data.refresh(player, player_table)
  player_data.update_settings(player, player_table)
end

return player_data