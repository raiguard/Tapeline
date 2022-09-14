local constants = require("__Tapeline__.constants")

local player_data = {}

-- from the core lualib
local function color_from_hex(hex) -- supports 'rrggbb', 'rgb', 'rrggbbaa', 'rgba', 'ww', 'w'
  local function h(i, j)
    return j and tonumber("0x" .. hex:sub(i, j)) / 255 or tonumber("0x" .. hex:sub(i, i)) / 15
  end

  hex = hex:gsub("#", "")
  return #hex == 6 and { r = h(1, 2), g = h(3, 4), b = h(5, 6) }
    or #hex == 3 and { r = h(1), g = h(2), b = h(3) }
    or #hex == 8 and { r = h(1, 2), g = h(3, 4), b = h(5, 6), a = h(7, 8) }
    or #hex == 4 and { r = h(1), g = h(2), b = h(3), a = h(4) }
    or #hex == 2 and { r = h(1, 2), g = h(1, 2), b = h(1, 2) }
    or #hex == 1 and { r = h(1), g = h(1), b = h(1) }
    or { r = 1, g = 1, b = 1 }
end

function player_data.init(player_index)
  global.players[player_index] = {
    flags = {
      editing = false,
      drawing = false,
      holding_tool = false,
      increased_build_distance = false,
    },
    last_entity = nil,
    visual_settings = nil,
    tapes = {
      editing = nil,
      drawing = nil,
    },
    tape_settings = {
      mode = "subgrid",
      subgrid_divisor = 5,
      split_divisor = 4,
    },
  }
end

function player_data.update_visual_setting(player, settings_table, prototype, internal)
  local value = player.mod_settings[prototype].value
  if string.find(internal, "color") then
    settings_table[internal] = color_from_hex(value)
  else
    settings_table[internal] = value
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
