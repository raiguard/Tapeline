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
}

return M
