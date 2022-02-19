data:extend({
  {
    type = "shortcut",
    name = "tl-get-tool",
    order = "a[alt-mode]-b[copy]",
    associated_control_input = "tl-get-tool",
    action = "spawn-item",
    item_to_spawn = "tl-tool",
    icon = {
      filename = "__Tapeline__/graphics/shortcut/shortcut-x32.png",
      y = 0,
      size = 32,
      mipmap_count = 2,
      flags = { "icon" },
    },
    disabled_icon = {
      filename = "__Tapeline__/graphics/shortcut/shortcut-x32.png",
      y = 32,
      size = 32,
      mipmap_count = 2,
      flags = { "icon" },
    },
    small_icon = {
      filename = "__Tapeline__/graphics/shortcut/shortcut-x24.png",
      y = 0,
      size = 24,
      mipmap_count = 2,
      flags = { "icon" },
    },
    disabled_small_icon = {
      filename = "__Tapeline__/graphics/shortcut/shortcut-x24.png",
      y = 24,
      size = 24,
      mipmap_count = 2,
      flags = { "icon" },
    },
  },
})
