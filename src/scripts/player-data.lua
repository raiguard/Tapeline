local player_data = {}

function player_data.init(player_index)
  global.players[player_index] = {
    flags = {
      drawing = false,
      placed_entity = false
    },
    last_entity = nil,
    tapes = {
      drawing = nil,
      next_index = 1
    }
  }
end

function player_data.refresh(player, player_table)

end

return player_data