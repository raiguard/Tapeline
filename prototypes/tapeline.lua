local constants = require('constants')
local utils = require('utils')

data:extend({
   {
      type = "shortcut",
      name = "tapeline-shortcut",
      order = "a[alt-mode]-b[copy]",
      action = "lua",
      localised_name = {"shortcut.tapeline"},
      icon =
      {
        filename = constants.shortcutAssetPath .. "tapeline-x32.png",
        priority = "extra-high-no-scale",
        size = 32,
        scale = 1,
        flags = {"icon"}
      },
      small_icon =
      {
        filename = constants.shortcutAssetPath .. "tapeline-x24.png",
        priority = "extra-high-no-scale",
        size = 24,
        scale = 1,
        flags = {"icon"}
      },
      disabled_small_icon =
      {
        filename = constants.shortcutAssetPath .. "tapeline-x24-white.png",
        priority = "extra-high-no-scale",
        size = 24,
        scale = 1,
        flags = {"icon"}
      }
    },
    {
      type = "selection-tool",
      name = constants.tapelineItemName,
      icon = constants.itemAssetPath .. "tapeline-tool.png",
      icon_size = 32,
      flags = {"hidden"},
      subgroup = "other",
      order = "c[automated-construction]-a[blueprint]",
      stack_size = 1,
      stackable = false,
      selection_color = { r = 0, g = 1, b = 0, a = 0.5 },
      alt_selection_color = { r = 0, g = 1, b = 0 },
      selection_mode = {"any-tile"},
      alt_selection_mode = {"blueprint"},
      selection_cursor_box_type = "copy",
      alt_selection_cursor_box_type = "copy",
      --entity_filters = {"stone-furnace", "steel-furnace"},
      --entity_type_filters = {"furnace", "assembling-machine"},
      --tile_filters = {"concrete", "stone-path"},
      --entity_filter_mode = "whitelist",
      --tile_filter_mode = "whitelist",
      --alt_entity_filters = {"stone-furnace", "steel-furnace"},
      --alt_entity_type_filters = {"furnace", "assembling-machine"},
      --alt_tile_filters = {"concrete", "stone-path"},
      --alt_entity_filter_mode = "whitelist",
      --alt_tile_filter_mode = "whitelist",
      show_in_library = true
    },
})