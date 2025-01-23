local flib_migration = require("__flib__.migration")

local settings = require("scripts.settings")
local tape = require("scripts.tape")
local tool = require("scripts.tool")

local versions = {
  ["3.0.0"] = function()
    rendering.clear(script.mod_name)
    for _, surface in pairs(game.surfaces) do
      for _, box in pairs(surface.find_entities_filtered({ name = "tl-highlight-box" })) do
        box.destroy()
      end
    end
    storage = {}
    settings.on_init()
    tape.on_init()
    tool.on_init()
  end,
  ["3.0.3"] = function()
    --- @param tbl table<uint, Tape>
    local function migrate_tapes(tbl)
      for key, tape_data in pairs(tbl) do
        if tape_data.player.valid then
          tape_data.player_index = tape_data.player.index
        else
          tbl[key] = nil
        end
      end
    end
    migrate_tapes(storage.drawing)
    migrate_tapes(storage.editing)
    migrate_tapes(storage.tapes)
  end,
}

local migrations = {}

--- @param e ConfigurationChangedData
function migrations.on_configuration_changed(e)
  flib_migration.on_config_changed(e, versions)
end

return migrations
