local data_util = require("__flib__.data-util")

data:extend{
  {
    type = "trivial-smoke",
    name = "tl-empty-smoke",
    animation = {
      filename = data_util.empty_image,
      size = {1, 1},
      frame_count = 8
    },
    duration = 1
  }
}
