-- local constants = require("constants")

data:extend({
  {
    type = "bool-setting",
    name = "tl-draw-tape-on-ground",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "b",
  },
  {
    type = "double-setting",
    name = "tl-tape-line-width",
    setting_type = "runtime-per-user",
    default_value = 1.5,
    order = "c",
  },
  {
    type = "double-setting",
    name = "tl-tape-clear-delay",
    setting_type = "runtime-per-user",
    default_value = 1,
    order = "d",
  },
  {
    type = "color-setting",
    name = "tl-tape-background-color",
    setting_type = "runtime-per-user",
    default_value = { a = 0.8 },
    order = "ea",
  },
  {
    type = "color-setting",
    name = "tl-tape-border-color",
    setting_type = "runtime-per-user",
    default_value = { r = 0.8, g = 0.8, b = 0.8 },
    order = "eb",
  },
  {
    type = "color-setting",
    name = "tl-tape-label-color",
    setting_type = "runtime-per-user",
    default_value = { r = 0.8, g = 0.8, b = 0.8 },
    order = "ec",
  },
  {
    type = "color-setting",
    name = "tl-tape-line-color-1",
    setting_type = "runtime-per-user",
    default_value = { r = 0.4, g = 0.4, b = 0.4 },
    order = "ed",
  },
  {
    type = "color-setting",
    name = "tl-tape-line-color-2",
    setting_type = "runtime-per-user",
    default_value = { r = 0.4, g = 0.8, b = 0.4 },
    order = "ee",
  },
  {
    type = "color-setting",
    name = "tl-tape-line-color-3",
    setting_type = "runtime-per-user",
    default_value = { r = 0.8, g = 0.4, b = 0.4 },
    order = "ef",
  },
  {
    type = "color-setting",
    name = "tl-tape-line-color-4",
    setting_type = "runtime-per-user",
    default_value = { r = 0.8, g = 0.8, b = 0.4 },
    order = "eg",
  },
})
