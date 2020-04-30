local global_data = {}

function global_data.init()
  global.end_wait = 3
  global.tilegrids = {
    drawing = {},
    perishing = {},
  }
  global.players = {}
end

return global_data