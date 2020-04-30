local player_data = {}

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

end

function player_data.refresh(player, player_table)

end

-- gets the values of all player mod settings and sticks them into the player's table
local function update_player_visual_settings(player_index, player)
  local t = global.players[player_index].settings.visual
  local s = player.mod_settings
  for k,vt in pairs(s) do
    if string_sub(k, 1, 3) == 'tl-' then
      -- use load() to convert table strings to actual tables
      k = string_gsub(k, "^tl%-", "")
      t[string_gsub(k, "%-", "_")] = load("return "..tostring(vt.value))()
    end
  end
end

return player_data