local constants = require("__Tapeline__/constants")

local player_data = {}

--- @param player_index uint
function player_data.init(player_index)
  --- @class PlayerTable
  global.players[player_index] = {
    flags = {
      editing = false,
      drawing = false,
      holding_tool = false,
      increased_build_distance = false,
    },
    --- @type LuaEntity?
    last_entity = nil,
    --- @type VisualSettings?
    visual_settings = nil,
    tapes = {
      -- @type TapeData?
      editing = nil,
      -- @type TapeData?
      drawing = nil,
    },
    --- @class TapeSettings
    tape_settings = {
      mode = "subgrid",
      subgrid_divisor = 5,
      split_divisor = 4,
    },
  }
end

--- @param player LuaPlayer
--- @param settings_table VisualSettings
--- @param prototype string
--- @param internal string
function player_data.update_visual_setting(player, settings_table, prototype, internal)
  local value = player.mod_settings[prototype].value
  if string.find(internal, "color") then
    settings_table[internal] = value --[[@as Color]]
  else
    settings_table[internal] = value
  end
end

--- @param player LuaPlayer
--- @param player_table PlayerTable
function player_data.update_visual_settings(player, player_table)
  local settings = {}
  for prototype, internal in pairs(constants.setting_names) do
    player_data.update_visual_setting(player, settings, prototype, internal)
  end
  player_table.visual_settings = settings
end

--- @param player LuaPlayer
--- @param player_table PlayerTable
function player_data.refresh(player, player_table)
  player_data.update_visual_settings(player, player_table)
end

return player_data
