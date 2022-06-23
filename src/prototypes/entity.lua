local collision_mask_util = require("__core__.lualib.collision-mask-util")
local data_util = require("__flib__.data-util")

data:extend({
  {
    type = "simple-entity-with-force",
    name = "tl-dummy-entity",
    flags = { "not-on-map", "hidden", "player-creation" },
    collision_box = { { -0.4, -0.4 }, { 0.4, 0.4 } },
    collision_mask = { collision_mask_util.get_first_unused_layer() },
    selectable_in_game = false,
    picture = {
      filename = data_util.empty_image,
      width = 8,
      height = 8,
    },
    build_sound = {
      filename = "__core__/sound/silence-1sec.ogg",
    },
    created_smoke = { smoke_name = "tl-empty-smoke" },
    alert_when_damaged = false,
  },
  {
    type = "highlight-box",
    name = "tl-highlight-box",
  },
})
