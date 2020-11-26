local constants = require("constants")

data:extend{
  -- player settings
  {
    type = "bool-setting",
    name = "tl-log-selection-area",
    setting_type = "runtime-per-user",
    default_value = false,
    order = "a"
  },
  {
    type = "bool-setting",
    name = "tl-draw-tape-on-ground",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "b"
  },
  {
    type = "double-setting",
    name = "tl-tape-line-width",
    setting_type = "runtime-per-user",
    default_value = 1.5,
    order = "c"
  },
  {
    type = "double-setting",
    name = "tl-tape-clear-delay",
    setting_type = "runtime-per-user",
    default_value = 1,
    order = "d"
  },
  {
    type = "string-setting",
    name = "tl-tape-background-color",
    setting_type = "runtime-per-user",
    default_value = constants.default_colors.tape_background_color,
    order = "ea"
  },
  {
    type = "string-setting",
    name = "tl-tape-border-color",
    setting_type = "runtime-per-user",
    default_value = constants.default_colors.tape_border_color,
    order = "eb"
  },
  {
    type = "string-setting",
    name = "tl-tape-label-color",
    setting_type = "runtime-per-user",
    default_value = constants.default_colors.tape_label_color,
    order = "ec"
  },
  {
    type = "string-setting",
    name = "tl-tape-line-color-1",
    setting_type = "runtime-per-user",
    default_value = constants.default_colors.tape_line_color_1,
    order = "ed"
  },
  {
    type = "string-setting",
    name = "tl-tape-line-color-2",
    setting_type = "runtime-per-user",
    default_value = constants.default_colors.tape_line_color_2,
    order = "ee"
  },
  {
    type = "string-setting",
    name = "tl-tape-line-color-3",
    setting_type = "runtime-per-user",
    default_value = constants.default_colors.tape_line_color_3,
    order = "ef"
  },
  {
    type = "string-setting",
    name = "tl-tape-line-color-4",
    setting_type = "runtime-per-user",
    default_value = constants.default_colors.tape_line_color_4,
    order = "eg"
  }
}