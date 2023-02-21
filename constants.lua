local constants = {}

constants.default_colors = {
  tape_background_color = { a = 204 },
  tape_border_color = { r = 204, g = 204, b = 204 },
  tape_label_color = { r = 204, g = 204, b = 204 },
  tape_line_color_1 = { r = 102, g = 102, b = 102 },
  tape_line_color_2 = { r = 102, g = 204, b = 102 },
  tape_line_color_3 = { r = 204, g = 102, b = 102 },
  tape_line_color_4 = { r = 204, g = 204, b = 102 },
}

constants.divisor_labels = {
  subgrid = "Grid size:",
  split = "# of splits:",
}

constants.divisor_minimums = {
  subgrid = 2,
  split = 2,
}

constants.modes = {
  subgrid = "subgrid",
  split = "split",
}

-- TEMPORARY - item labels don't support localised strings
constants.mode_labels = {
  subgrid = "Subgrid",
  split = "Split",
}

--- @class VisualSettings
--- @field log_selection_area boolean
--- @field draw_tape_on_ground boolean
--- @field tape_line_width float
--- @field tape_clear_delay number
--- @field tape_background_color Color
--- @field tape_border_color Color
--- @field tape_label_color Color
--- @field tape_line_color_1 Color
--- @field tape_line_color_2 Color
--- @field tape_line_color_3 Color
--- @field tape_line_color_4 Color

constants.setting_names = {
  ["tl-log-selection-area"] = "log_selection_area",
  ["tl-draw-tape-on-ground"] = "draw_tape_on_ground",
  ["tl-tape-line-width"] = "tape_line_width",
  ["tl-tape-clear-delay"] = "tape_clear_delay",
  ["tl-tape-background-color"] = "tape_background_color",
  ["tl-tape-border-color"] = "tape_border_color",
  ["tl-tape-label-color"] = "tape_label_color",
  ["tl-tape-line-color-1"] = "tape_line_color_1",
  ["tl-tape-line-color-2"] = "tape_line_color_2",
  ["tl-tape-line-color-3"] = "tape_line_color_3",
  ["tl-tape-line-color-4"] = "tape_line_color_4",
}

return constants
