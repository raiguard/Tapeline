local handler = require("__core__.lualib.event_handler")

handler.add_libraries({
  require("scripts.tool"),
  require("scripts.tape"),
  require("scripts.settings"),
})
