--item.lua

data:extend({
   {
      type = "shortcut",
      name = "tapeline",
      order = "a[alt-mode]",
      action = "lua",
      localised_name = {"shortcut.tapeline"},
      icon =
      {
        filename = "__Tapeline__/graphics/icons/tapeline-x32.png",
        priority = "extra-high-no-scale",
        size = 32,
        scale = 1,
        flags = {"icon"}
      },
      small_icon =
      {
        filename = "__Tapeline__/graphics/icons/tapeline-x24.png",
        priority = "extra-high-no-scale",
        size = 24,
        scale = 1,
        flags = {"icon"}
      },
      disabled_small_icon =
      {
        filename = "__Tapeline__/graphics/icons/tapeline-x24-white.png",
        priority = "extra-high-no-scale",
        size = 24,
        scale = 1,
        flags = {"icon"}
      }
    }
})