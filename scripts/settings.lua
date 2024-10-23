--- @class TapeSettings
--- @field mode "subgrid"|"split"
--- @field subgrid_size int
--- @field splits int

--- @param player_index uint
local function create_settings(player_index)
  storage.player_settings[player_index] = {
    mode = "subgrid",
    subgrid_size = 5,
    splits = 4,
  }
end

--- @param e EventData.on_player_created
local function on_player_created(e)
  create_settings(e.player_index)
end

--- @param e EventData.on_player_removed
local function on_player_removed(e)
  storage.player_settings[e.player_index] = nil
end

--- @param e EventData.CustomInputEvent
local function on_change_divisor(e)
  local delta = e.input_name == "tl-increase-divisor" and 1 or -1
  local settings = storage.player_settings[e.player_index]
  if not settings then
    return
  end
  if settings.mode == "subgrid" then
    settings.subgrid_size = math.max(0, settings.subgrid_size + delta)
  else
    settings.splits = math.max(2, settings.splits + delta)
  end
end

local M = {}

function M.on_init()
  --- @type table<uint, TapeSettings>
  storage.player_settings = {}
  for player_index in pairs(game.players) do
    create_settings(player_index --[[@as uint]])
  end
end

M.events = {
  [defines.events.on_player_created] = on_player_created,
  [defines.events.on_player_removed] = on_player_removed,
  ["tl-increase-divisor"] = on_change_divisor,
  ["tl-decrease-divisor"] = on_change_divisor,
}

return M
