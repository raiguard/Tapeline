-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MIGRATIONS

-- table of migration functions
return {
  ["0.6.0"] = function()
    -- create missing global tables
    global.drawing = {}
    global.tilegrids = {}
    -- move all tilegrid tables to tilegrids subtable
    for k,v in pairs(global) do
        if type(k) == "number" then
            global.tilegrids[k] = table.deepcopy(v)
            global[k] = nil
        end
    end
    -- rename players table
    if global.player_data then
      global.players = table.deepcopy(global.player_data)
      global.player_data = nil
      for i,p in pairs(game.players) do
        if global.players[i] then
          -- remove old settings window if it's open
          local window = mod_gui.get_frame_flow(p).tapeline_menu_frame
          if window then window.destroy() end
          local player_table = global.players[i]
          -- convert cur_editing from bool to number
          player_table.cur_editing = 0
          -- if the player is currently drawing, add that tilegrid to the drawing table, then convert cur_drawing to an int
          if player_table.cur_drawing then
            global.drawing[player_table.cur_tilegrid_index] = {
              player = p,
              last_capsule_tick = player_table.last_capsule_tick,
              last_capsule_pos = player_table.last_capsule_pos
            }
          end
          global.players[i].cur_drawing = 0
          -- clean up now unnecessary player data
          player_table.cur_tilegrid_index = nil
          player_table.last_capsule_tick = nil
          player_table.last_capsule_pos = nil
          player_table.center_gui = nil
          player_table.mod_gui = nil
          -- if the player is currently holding a tapeline capsule, destroy it
          if p.cursor_stack and p.cursor_stack.valid_for_read and p.cursor_stack.name == "tapeline-capsule" then
              p.clean_cursor()
          end
        end
      end
    end
  end,
  ["1.0.0"] = function()
    -- remove any highlight boxes
    for _,t in pairs(global.tilegrids) do
      if t.highlight_box and t.highlight_box.valid then
        t.highlight_box.destroy()
      end
    end
    -- clear all render objects
    rendering.clear("Tapeline")
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
      local s = game.get_player(i).mod_settings
      for k,vt in pairs(s) do
        if string.find(k, "^tl%-") then
          -- use load() to convert table strings to actual tables
          k = string.gsub(k, "tl%-", "")
          visual_settings[string.gsub(k, "%-", "_")] = load("return "..tostring(vt.value))()
        end
      end
      new_global.players[i] = data
    end
    global = new_global
  end,
  ["1.0.4"] = function()
    -- remove GUI data from global, it's no longer needed
    global.__lualib.gui = nil
  end,
  ["1.1.0"] = function()
    global.__lualib = nil

  end
}