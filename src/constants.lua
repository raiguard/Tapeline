local constants = {}

constants.default_colors = {
  tape_background_color = "#000000cc",
  tape_border_color = "#cc",
  tape_label_color = "#cc",
  tape_line_color_1 = "#66",
  tape_line_color_2 = "#66cc66",
  tape_line_color_3 = "#cc6666",
  tape_line_color_4 = "#cccc66",
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
