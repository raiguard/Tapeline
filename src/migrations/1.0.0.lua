if not global.tilegrids then return end

-- remove any highlight boxes
for _,t in pairs(global.tilegrids) do
  if t.highlight_box and t.highlight_box.valid then
    t.highlight_box.destroy()
  end
end

-- clear all render objects
rendering.clear('Tapeline')

-- assemble new global table
local new_global = {
  __lualib = {
    event = {},
    gui = {}
  },
  end_wait = global.end_wait or 3,
  players = {},
  tilegrids = {
    drawing = {},
    perishing = {}
  }
}

for i,t in pairs(global.players) do
  local data = {
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
  local visual_settings = data.settings.visual
  for k,vt in pairs(game.get_player(i).mod_settings) do
    -- use load() to convert table strings to actual tables
    visual_settings[string.gsub(k, '%-', '_')] = load('return '..tostring(vt.value))()
  end
  new_global.players[i] = data
end

global = new_global