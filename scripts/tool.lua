local flib_bounding_box = require("__flib__.bounding-box")

--- @param settings TapeSettings
--- @param tape Tape?
--- @return string
local function build_label(settings, tape)
  local output = ""
  if tape then
    output = output
      .. tostring(flib_bounding_box.width(tape.box))
      .. "×"
      .. tostring(flib_bounding_box.height(tape.box))
      .. " | "
  end
  if settings.mode == "subgrid" then
    return output .. "Subgrid mode | Size: " .. tostring(settings.subgrid_size)
  else
    return output .. "Split mode | # of splits: " .. tostring(settings.splits)
  end
end

--- @param player LuaPlayer
--- @return LuaItemStack?
local function get_tool(player)
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "tl-tool" then
    return cursor_stack
  end
end

--- @param player LuaPlayer
--- @param tape Tape?
local function set_tool(player, tape)
  local cursor_stack = player.cursor_stack
  if cursor_stack then
    if not cursor_stack.valid_for_read or cursor_stack.name == "tl-tool" or player.clear_cursor() then
      cursor_stack.set_stack({ name = "tl-tool", count = 10 })
      local settings = tape and tape.settings or storage.player_settings[player.index]
      cursor_stack.label = build_label(settings, tape)
    end
    if player.controller_type == defines.controllers.character and player.character_build_distance_bonus < 1000000 then
      player.character_build_distance_bonus = player.character_build_distance_bonus + 1000000
    end
  end
end

--- @param e EventData.on_player_cursor_stack_changed
local function on_player_cursor_stack_changed(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  local player_tool = get_tool(player)
  if player_tool then
    storage.holding_tool[player.index] = true
    set_tool(player, storage.editing[e.player_index] or storage.drawing[e.player_index])
  elseif not player_tool and storage.holding_tool[player.index] then
    storage.holding_tool[player.index] = nil
    -- FIXME: Handle player controller changes
    if player.controller_type == defines.controllers.character and player.character_build_distance_bonus >= 1000000 then
      player.character_build_distance_bonus = player.character_build_distance_bonus - 1000000
    end
  end
end

--- @param e EventData.on_built_entity
local function on_built_entity(e)
  local entity = e.entity
  if not entity.valid then
    return
  end
  local name = entity.name
  if name == "entity-ghost" then
    name = entity.ghost_name
  end
  if name ~= "tl-dummy-entity" then
    return
  end
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local tape = storage.editing[e.player_index] or storage.drawing[e.player_index]
  if not tape then
    return
  end
  set_tool(player, tape)
end

--- @param e EventData.on_player_selected_area|EventData.on_player_alt_selected_area
local function on_player_selected_area(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  set_tool(player, storage.editing[e.player_index])
end

local function on_init()
  --- @type table<uint, boolean>
  storage.holding_tool = {}
end

local tool = {}

tool.on_init = on_init

tool.events = {
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_player_alt_selected_area] = on_player_selected_area,
  [defines.events.on_player_cursor_stack_changed] = on_player_cursor_stack_changed,
  [defines.events.on_player_selected_area] = on_player_selected_area,
}

tool.set = set_tool
tool.get = get_tool

return tool
