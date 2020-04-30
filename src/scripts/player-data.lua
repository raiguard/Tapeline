local player_data = {}

local string_gsub = string.gsub
local string_sub = string.sub

function player_data.init(player_index)
  global.players[player_index] = {
    flags = {
      adjusting_tilegrid = false,
      adjustment_tutorial_shown = false,
      capsule_tutorial_shown = false,
      selecting_tilegrid = false
    },
    gui = {},
    last_capsule_tick = 0,
    last_capsule_tile = nil, -- doesn't have an initial value, but here for reference
    settings = {
      auto_clear = true,
      cardinals_only = true,
      grid_type = 1,
      increment_divisor = 5,
      split_divisor = 4,
      visual = {}
    },
    tilegrids = {
      drawing = false,
      editing = false,
      registry = {}
    }
  }
  player_data.refresh(game.get_player(player_index), global.players[player_index])
end

function player_data.update_settings(player, player_table)
  local t = player_table.settings.visual
  local s = player.mod_settings
  for k,vt in pairs(s) do
    if string_sub(k, 1, 3) == 'tl-' then
      k = string_gsub(k, "^tl%-", "")
      -- use load() to convert table strings to actual tables
      t[string_gsub(k, "%-", "_")] = load("return "..tostring(vt.value))()
    end
  end
end

function player_data.refresh(player, player_table)
  player_data.update_settings(player, player_table)
end

return player_data