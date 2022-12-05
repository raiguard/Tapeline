local constants = {}

-- FIXME:
constants.colors = {
  background_color = { a = 0.8 },
  border_color = { r = 0.8, g = 0.8, b = 0.8 },
  label_color = { r = 0.8, g = 0.8, b = 0.8 },
  line_color_1 = { r = 0.4, g = 0.4, b = 0.4 },
  line_color_2 = { r = 0.4, g = 0.8, b = 0.4 },
  line_color_3 = { r = 0.8, g = 0.4, b = 0.4 },
  line_color_4 = { r = 0.8, g = 0.8, b = 0.4 },
}

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

return constants
