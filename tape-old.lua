-- local bounding_box = require("__flib__/bounding-box")
-- local table = require("__flib__/table")

-- local constants = require("__Tapeline__/constants")

-- local bring_to_front = rendering.bring_to_front
-- local destroy = rendering.destroy
-- local draw_line = rendering.draw_line
-- local draw_rectangle = rendering.draw_rectangle
-- local draw_text = rendering.draw_text
-- local set_from = rendering.set_from
-- local set_left_top = rendering.set_left_top
-- local set_right_bottom = rendering.set_right_bottom
-- local set_target = rendering.set_target
-- local set_text = rendering.set_text
-- local set_time_to_live = rendering.set_time_to_live
-- local set_to = rendering.set_to
-- local set_visible = rendering.set_visible

-- local tape = {}

-- --- @param objects TapeObjects
-- --- @param func fun(id: uint64, ...)
-- local function apply_to_all_objects(objects, func, ...)
--   for _, v in pairs(objects) do
--     if type(v) == "table" then
--       apply_to_all_objects(v, func, ...)
--     else
--       func(v, ...)
--     end
--   end
-- end

-- --- @param player LuaPlayer
-- --- @param tape_data TapeData
-- local function create_objects(player, tape_data)
--   local player_index = player
--   local box = tape_data.box
--   --- @class TapeObjects
--   local objects = {
--     background = draw_rectangle({
--       color = constants.colors.background_color,
--       filled = true,
--       left_top = box.left_top,
--       right_bottom = box.right_bottom,
--       surface = tape_data.surface,
--       players = { player_index },
--       draw_on_ground = true,
--     }),
--     border = draw_rectangle({
--       color = constants.colors.border_color,
--       width = 1.5,
--       filled = false,
--       left_top = box.left_top,
--       right_bottom = box.right_bottom,
--       surface = tape_data.surface,
--       players = { player_index },
--       draw_on_ground = true,
--     }),
--     labels = {
--       x = draw_text({
--         text = tostring(bounding_box.width(box)),
--         surface = tape_data.surface,
--         target = { x = bounding_box.center(box).x, y = box.left_top.y - 0.85 },
--         color = constants.colors.label_color,
--         scale = 1.5,
--         alignment = "center",
--         visible = false,
--         players = { player_index },
--       }),
--       y = draw_text({
--         text = tostring(bounding_box.height(box)),
--         surface = tape_data.surface,
--         target = { x = box.left_top.x - 0.85, y = bounding_box.center(box).y },
--         color = constants.colors.label_color,
--         scale = 1.5,
--         orientation = 0.75,
--         alignment = "center",
--         visible = false,
--         players = { player_index },
--       }),
--     },
--     lines = {
--       { x = {}, y = {} },
--       { x = {}, y = {} },
--       { x = {}, y = {} },
--       { x = {}, y = {} },
--     },
--   }
--   return objects
-- end

-- --- @param player_index uint
-- --- @param tape_data TapeData
-- --- @param tape_settings TapeSettings
-- local function update_objects(player_index, tape_data, tape_settings)
--   local box = tape_data.box
--   local objects = tape_data.objects

--   local background = objects.background
--   set_left_top(background, box.left_top)
--   set_right_bottom(background, box.right_bottom)

--   local border = objects.border
--   set_left_top(border, box.left_top)
--   set_right_bottom(border, box.right_bottom)

--   local center = bounding_box.center(box)
--   local height = bounding_box.height(box)
--   local width = bounding_box.width(box)

--   local x_label = objects.labels.x
--   set_text(x_label, tostring(width))
--   set_target(x_label, { x = center.x, y = box.left_top.y - 0.85 })
--   if width > 1 then
--     set_visible(x_label, true)
--   else
--     set_visible(x_label, false)
--   end

--   local y_label = objects.labels.y
--   set_text(y_label, tostring(height))
--   set_target(y_label, { x = box.left_top.x - 0.85, y = center.y })
--   if height > 1 then
--     set_visible(y_label, true)
--   else
--     set_visible(y_label, false)
--   end

--   -- GRID LINES

--   local function delete_lines(axis, grid_index)
--     apply_to_all_objects(objects.lines[grid_index][axis], destroy)
--     objects.lines[grid_index][axis] = {}
--   end

--   local function delete_grid(grid_index)
--     delete_lines("x", grid_index)
--     delete_lines("y", grid_index)
--   end

--   local function update_lines(axis, grid_index, grid_step)
--     local lines = objects.lines[grid_index][axis]

--     -- Iterate from the origin corner outwards
--     local start = math.floor(tape_data.origin[axis])
--     local finish = math.floor(tape_data.anchor[axis])
--     if start > finish then
--       start = start + 1
--       finish = finish + 1
--     end

--     local i = 0

--     if (axis == "x" and width or height) > 1 then
--       for pos = start, finish, start < finish and grid_step or -grid_step do
--         local from, to
--         if axis == "x" then
--           from = { x = pos, y = box.left_top.y }
--           to = { x = pos, y = box.right_bottom.y }
--         else
--           from = { x = box.left_top.x, y = pos }
--           to = { x = box.right_bottom.x, y = pos }
--         end

--         i = i + 1
--         local line = lines[i]
--         if line then
--           set_from(line, from)
--           set_to(line, to)
--           bring_to_front(line)
--         else
--           lines[i] = draw_line({
--             color = constants.colors["line_color_" .. grid_index],
--             width = 1.5,
--             from = from,
--             to = to,
--             surface = tape_data.surface,
--             players = { player_index },
--             draw_on_ground = true,
--           })
--         end
--       end
--     end

--     for j = i + 1, #lines do
--       destroy(lines[j])
--       lines[j] = nil
--     end
--   end

--   local function update_grid(grid_index, grid_step)
--     update_lines("x", grid_index, grid_step)
--     update_lines("y", grid_index, grid_step)
--   end

--   -- base grid
--   update_grid(1, 1)

--   local mode = tape_settings.mode
--   if mode == "subgrid" then
--     local subgrid_size = tape_settings.subgrid_divisor
--     update_grid(2, subgrid_size)
--     update_grid(3, subgrid_size ^ 2)
--     update_grid(4, subgrid_size ^ 3)
--   elseif mode == "split" then
--     local num_splits = tape_settings.split_divisor
--     update_lines("x", 2, width / num_splits)
--     update_lines("y", 2, height / num_splits)
--     update_lines("x", 3, width / 2)
--     update_lines("y", 3, height / 2)
--     delete_grid(4)
--   end

--   bring_to_front(border)
-- end

-- --- @param player LuaPlayer
-- --- @param player_table PlayerTable
-- --- @param origin MapPosition
-- --- @param surface LuaSurface
-- function tape.start_draw(player, player_table, origin, surface)
--   local box = bounding_box.from_position(origin)
--   --- @class TapeData
--   local tape_data = {
--     anchor = origin,
--     box = box,
--     --- @type LuaEntity?
--     highlight_box = nil,
--     last_update_tick = game.ticks_played,
--     origin = origin,
--     surface = surface,
--   }
--   tape_data.objects = create_objects(player, tape_data)
--   player_table.tapes.drawing = tape_data
--   player_table.flags.drawing = true
-- end

-- --- @param player LuaPlayer
-- --- @param player_table PlayerTable
-- --- @param new_position MapPosition?
-- --- @param is_ghost boolean?
-- function tape.update_draw(player, player_table, new_position, is_ghost)
--   local tape_data = player_table.tapes.drawing --[[@as TapeData]]
--   local origin = tape_data.origin

--   if new_position then
--     if not is_ghost then
--       -- TODO: position.vector?
--       if math.abs(new_position.x - origin.x) >= math.abs(new_position.y - origin.y) then
--         new_position.y = math.floor(origin.y)
--       else
--         new_position.x = math.floor(origin.x)
--       end

--       -- Don't do anything if the cursor didn't actually move
--       local anchor = tape_data.anchor
--       if new_position.x == anchor.x and new_position.y == anchor.y then
--         return
--       end
--     end
--     tape_data.anchor = new_position
--   else
--     new_position = tape_data.anchor
--   end

--   tape_data.last_update_tick = game.ticks_played

--   -- update area corners
--   local x_less = new_position.x < origin.x
--   local y_less = new_position.y < origin.y
--   tape_data.box = {
--     left_top = {
--       x = math.floor(x_less and new_position.x or origin.x),
--       y = math.floor(y_less and new_position.y or origin.y),
--     },
--     right_bottom = {
--       x = math.ceil(x_less and origin.x or new_position.x),
--       y = math.ceil(y_less and origin.y or new_position.y),
--     },
--   }

--   -- update origin corner
--   local new_origin_corner = ((x_less and "right" or "left") .. "_" .. (y_less and "bottom" or "top"))
--   tape_data.origin_corner = new_origin_corner

--   update_objects(player.index, tape_data, player_table.tape_settings)
-- end

-- --- @param player LuaPlayer
-- --- @param player_table PlayerTable
-- --- @param auto_clear boolean
-- function tape.complete_draw(player, player_table, auto_clear)
--   local tapes = player_table.tapes
--   local tape_data = tapes.drawing --[[@as TapeData]]
--   local box = tape_data.box
--   local objects = tape_data.objects
--   local settings = player.mod_settings

--   player_table.flags.drawing = false

--   -- immediately destroy the tape if it is 1x1
--   if bounding_box.height(box) == 1 and bounding_box.width(box) == 1 then
--     apply_to_all_objects(objects, destroy)
--     tapes.drawing = nil
--     return
--   end

--   tape_data.anchor = nil

--   if auto_clear then
--     apply_to_all_objects(objects, set_time_to_live, settings["tl-tape-clear-delay"].value * 60)
--     -- update to fix draw order
--     update_objects(player.index, tape_data, player_table.tape_settings)
--   else
--     -- copy settings into tape so they can be changed later
--     tape_data.settings = table.deep_copy(player_table.tape_settings)
--     tapes[#tapes + 1] = tape_data
--   end

--   if settings["tl-log-selection-area"].value then
--     player.print(bounding_box.width(box) .. "x" .. bounding_box.height(box))
--   end
--   tapes.drawing = nil
-- end

-- --- @param player_table PlayerTable
-- function tape.cancel_draw(player_table)
--   player_table.flags.drawing = false

--   local tape_data = player_table.tapes.drawing --[[@as TapeData]]
--   apply_to_all_objects(tape_data.objects, destroy)
--   player_table.tapes.drawing = nil
-- end

-- --- @param player_table PlayerTable
-- --- @param tape_index number
-- function tape.delete(player_table, tape_index)
--   local tapes = player_table.tapes
--   local tape_data = tapes[tape_index] --[[@as TapeData]]
--   apply_to_all_objects(tape_data.objects, destroy)
--   if player_table.flags.editing then
--     tape.exit_edit_mode(player_table)
--   end
--   table.remove(tapes, tape_index)
-- end

-- --- @param player_index uint
-- --- @param box BoundingBox
-- --- @param surface LuaSurface
-- local function create_highlight_box(player_index, box, surface)
--   return surface.create_entity({
--     name = "tl-highlight-box",
--     position = bounding_box.center(box),
--     bounding_box = bounding_box.resize(box, 0.3),
--     cursor_box_type = "electricity",
--     render_player_index = player_index,
--     blink_interval = 30,
--   })
-- end

-- --- @param player LuaPlayer
-- --- @param player_table PlayerTable
-- --- @param tape_index number
-- function tape.enter_edit_mode(player, player_table, tape_index)
--   local tape_data = player_table.tapes[tape_index] --[[@as TapeData]]

--   tape_data.highlight_box = create_highlight_box(player.index, tape_data.box, tape_data.surface)

--   player_table.flags.editing = true
--   player_table.tapes.editing = tape_data
-- end

-- --- @param player_table PlayerTable
-- function tape.exit_edit_mode(player_table)
--   local tape_data = player_table.tapes.editing --[[@as TapeData]]
--   tape_data.highlight_box.destroy()
--   tape_data.anchor = nil
--   player_table.flags.editing = false
--   player_table.tapes.editing = nil
-- end

-- --- @param player_index uint
-- --- @param player_table PlayerTable
-- --- @param mode string
-- --- @param divisor number
-- function tape.edit_settings(player_index, player_table, mode, divisor)
--   local tape_data = player_table.tapes.editing --[[@as TapeData]]
--   tape_data.settings.mode = mode
--   tape_data.settings[mode .. "_divisor"] = divisor

--   update_objects(player_index, tape_data, tape_data.settings, player_table.visual_settings)
-- end

-- --- @param player LuaPlayer
-- --- @param player_table PlayerTable
-- --- @param new_position MapPosition
-- --- @param surface LuaSurface
-- function tape.move(player, player_table, new_position, surface)
--   local tape_data = player_table.tapes.editing --[[@as TapeData]]
--   if surface ~= tape_data.surface then
--     return
--   end

--   local anchor = tape_data.anchor
--   if anchor then
--     -- calculate delta
--     local delta = {
--       x = new_position.x - anchor.x,
--       y = new_position.y - anchor.y,
--     }
--     -- move area and origin
--     tape_data.box = bounding_box.move(tape_data.box, delta)
--     tape_data.origin = {
--       x = tape_data.origin.x + delta.x,
--       y = tape_data.origin.y + delta.y,
--     }
--     -- update last updated tick
--     tape_data.last_update_tick = game.ticks_played
--     -- update render objects
--     update_objects(player.index, tape_data, tape_data.settings, player_table.visual_settings)
--     -- update highlight box
--     tape_data.highlight_box.destroy()
--     tape_data.highlight_box = create_highlight_box(player.index, tape_data.box, tape_data.surface)
--     tape_data.anchor = new_position
--   elseif bounding_box.contains_position(tape_data.box, new_position) then
--     tape_data.anchor = new_position
--   end
-- end

-- --- @param player_table PlayerTable
-- function tape.complete_move(player_table)
--   player_table.tapes.editing.anchor = nil
-- end

-- -- FIXME:
-- -- --- @param tape_data TapeData
-- -- --- @param settings VisualSettings
-- -- function tape.update_visual_settings(tape_data, settings)
-- --   local objects = tape_data.objects

-- --   local line_width = settings.tape_line_width
-- --   local draw_on_ground = settings.draw_tape_on_ground

-- --   local background = objects.background
-- --   set_color(background, settings.tape_background_color)
-- --   set_draw_on_ground(background, draw_on_ground)

-- --   local border = objects.border
-- --   set_color(border, settings.tape_border_color)
-- --   set_draw_on_ground(border, draw_on_ground)
-- --   set_width(border, line_width)

-- --   set_color(objects.labels.x, settings.tape_label_color)
-- --   set_color(objects.labels.y, settings.tape_label_color)

-- --   -- GRID LINES

-- --   local lines = objects.lines
-- --   apply_to_all_objects(lines, set_draw_on_ground, draw_on_ground)
-- --   apply_to_all_objects(lines, set_width, line_width)

-- --   apply_to_all_objects(lines[1], set_color, settings.tape_line_color_1)
-- --   apply_to_all_objects(lines[2], set_color, settings.tape_line_color_2)
-- --   apply_to_all_objects(lines[3], set_color, settings.tape_line_color_3)
-- --   apply_to_all_objects(lines[4], set_color, settings.tape_line_color_4)
-- -- end

-- return tape
