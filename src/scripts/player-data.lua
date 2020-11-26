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
    visual_settings = nil,
    tapes = {
      editing = nil,
      drawing = nil
    },
    tape_settings = {
      mode = "subgrid",
      subgrid_divisor = 5,
      split_divisor = 4
    }
  }
end

function player_data.update_visual_setting(player, settings_table, prototype, internal)
  if string.find(internal, "color") then
    settings_table[internal] = (
      game.json_to_table(player.mod_settings[prototype].value) or game.json_to_table(constants.default_colors[internal])
    )
  else
    settings_table[internal] = player.mod_settings[prototype].value
  end
end

function player_data.update_visual_settings(player, player_table)
  local settings = {}
  for prototype, internal in pairs(constants.setting_names) do
    player_data.update_visual_setting(player, settings, prototype, internal)
  end
  player_table.visual_settings = settings
end

function player_data.refresh(player, player_table)
  player_data.update_visual_settings(player, player_table)
end

return player_data