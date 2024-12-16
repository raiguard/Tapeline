local flib_migration = require("__flib__.migration")

local settings = require("scripts.settings")
local tape = require("scripts.tape")
local tool = require("scripts.tool")

local versions = {
  ["3.0.0"] = function()
    rendering.clear(script.mod_name)
    storage = {}
    settings.on_init()
    tape.on_init()
    tool.on_init()
  end,
}

local migrations = {}

--- @param e ConfigurationChangedData
function migrations.on_configuration_changed(e)
  flib_migration.on_config_changed(e, versions)
end

return migrations
