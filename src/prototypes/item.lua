local data_util = require("__flib__.data-util")

data:extend{
  {
    type = "selection-tool",
    name = "tl-draw-tool",
    icons = {
      {icon = data_util.black_image, icon_size = 1, scale = 64},
      {icon = "__Tapeline__/graphics/item/draw.png", icon_size = 32, icon_mipmaps = 2}
    },
    selection_mode = {"nothing"},
    alt_selection_mode = {"nothing"},
    selection_color = {a = 0},
    alt_selection_color = {a = 0},
    selection_cursor_box_type = "not-allowed",
    alt_selection_cursor_box_type = "not-allowed",
    place_result = "tl-dummy-entity",
    stack_size = 1,
    flags = {"not-stackable", "hidden", "only-in-cursor", "spawnable"},
    draw_label_for_cursor_render = true,
    mouse_cursor = "tl-draw-cursor"
  }
}