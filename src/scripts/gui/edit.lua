-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EDIT GUI
-- Edit settings on a current tilegrid

local gui = require('lualib/gui')
local util = require('scripts/util')

local tilegrid = require('scripts/tilegrid')

local table_remove = table.remove

local self = {}

-- -----------------------------------------------------------------------------
-- LOCAL UTILITIES

type_to_switch_state = {'left', 'right'}
switch_state_to_type_index = {left=1, right=2}
type_index_to_name = {'increment', 'split'}
type_to_clamps = {{4,13}, {2,11}}

origin_localized_items = {
  {'tl-gui.origin-left_top'},
  {'tl-gui.origin-right_top'},
  {'tl-gui.origin-left_bottom'},
  {'tl-gui.origin-right_bottom'}
}
corner_to_index = {
  left_top = 1,
  right_top = 2,
  left_bottom = 3,
  right_bottom = 4
}
index_to_corner = {'left_top', 'right_top', 'left_bottom', 'right_bottom'}

local function get_settings_table(player_index)
  local tilegrids = global.players[player_index].tilegrids
  return tilegrids.registry[tilegrids.editing].settings
end

-- -----------------------------------------------------------------------------
-- GUI DATA

gui.add_templates(util.gui_templates)
gui.add_handlers('edit', {
  save_changes_button = {
    on_gui_click = function(e)
      local player_table = global.players[e.player_index]
      player_table.tilegrids.editing = false
      self.destroy(player_table.gui.edit.elems.window, game.get_player(e.player_index))
      player_table.gui.edit.highlight_box.destroy()
      player_table.gui.edit = nil
    end
  },
  delete_button = {
    on_gui_click = function(e)
      e.element.parent.visible = false
      e.element.parent.parent.children[2].visible = true
    end
  },
  confirm_yes_button = {
    on_gui_click = function(e)
      local player_table = global.players[e.player_index]
      tilegrid.destroy(player_table.tilegrids.registry[player_table.tilegrids.editing])
      table_remove(player_table.tilegrids.registry, player_table.tilegrids.editing)
      player_table.tilegrids.editing = false
      local gui_data = player_table.gui.edit
      self.destroy(gui_data.elems.window, game.get_player(e.player_index))
      gui_data.highlight_box.destroy()
      player_table.gui.edit = nil
      -- clean player cursor
      local player = game.get_player(e.player_index)
      local stack = player.cursor_stack
      if stack and stack.valid_for_read and stack.name == 'tapeline-adjust' then
        player.clean_cursor()
      end
    end
  },
  confirm_no_button = {
    on_gui_click = function(e)
      e.element.parent.visible = false
      e.element.parent.parent.children[1].visible = true
    end
  },
  origin_dropdown = {
    on_gui_selection_state_changed = function(e)
      local player_table = global.players[e.player_index]
      local data = player_table.tilegrids.registry[player_table.tilegrids.editing]
      data.hot_corner = util.area.opposite_corner(index_to_corner[e.element.selected_index])
      tilegrid.refresh(data, e.player_index, player_table.settings.visual)
    end
  },
  grid_type_switch = {
    on_gui_switch_state_changed = function(e)
      local player_table = global.players[e.player_index]
      local data = player_table.tilegrids.registry[player_table.tilegrids.editing]
      data.settings.grid_type = switch_state_to_type_index[e.element.switch_state]
      self.update(e.player_index, data.settings)
      tilegrid.refresh(data, e.player_index, player_table.settings.visual)
    end
  },
  divisor_slider = {
    on_gui_value_changed = function(e)
      local player_table = global.players[e.player_index]
      local gui_data = player_table.gui.edit
      if e.element.slider_value == tonumber(gui_data.last_divisor_value) then return end
      gui_data.last_divisor_value = e.element.slider_value
      local data = player_table.tilegrids.registry[player_table.tilegrids.editing]
      local textfield = gui_data.elems.divisor_textfield
      local divisor_name = type_index_to_name[data.settings.grid_type]..'_divisor'
      data.settings[divisor_name] = e.element.slider_value
      textfield.text = e.element.slider_value
      tilegrid.refresh(data, e.player_index, player_table.settings.visual)
    end
  },
  divisor_textfield = {
    on_gui_text_changed = function(e)
      local player_table = global.players[e.player_index]
      local settings_table = get_settings_table(e.player_index)
      local gui_data = player_table.gui.edit
      local new_value = util.textfield.clamp_number_input(e.element, type_to_clamps[settings_table.grid_type], gui_data.last_divisor_value)
      if new_value ~= gui_data.last_divisor_value then
        gui_data.last_divisor_value = new_value
        gui_data.elems.divisor_slider.slider_value = new_value
      end
    end,
    on_gui_confirmed = function(e)
      local player_table = global.players[e.player_index]
      local data = player_table.tilegrids.registry[player_table.tilegrids.editing]
      local final_text = util.textfield.set_last_valid_value(e.element, player_table.gui.edit.last_divisor_value)
      data.settings[type_index_to_name[data.settings.grid_type]..'_divisor'] = tonumber(final_text)
      tilegrid.refresh(data, e.player_index, player_table.settings.visual)
    end
  },
  reposition_button = {
    on_gui_click = function(e)
      local player = game.get_player(e.player_index)
      player.clean_cursor()
      player.cursor_stack.set_stack{name='tapeline-adjust'}
    end
  }
})

-- -----------------------------------------------------------------------------
-- LIBRARY

function self.create(parent, player_index, settings, hot_corner)
  local grid_type = settings.grid_type
  local data = gui.create(parent, 'edit', player_index,
    {template='window', name='tl_edit_window', children={
      {type='flow', direction='horizontal', children={
        -- default titlebar
        {template='vertically_centered_flow', children={
          {type='label', style='heading_1_label', caption={'tl-gui.edit-settings'}},
          {template='pushers.horizontal'},
          {type='sprite-button', style={name='tl_green_icon_button', top_margin=0}, sprite='utility/confirm_slot', tooltip={'tl-gui.save-changes'},
            handlers='save_changes_button'},
          {type='sprite-button', style='red_icon_button', sprite='utility/trash', tooltip={'tl-gui.delete-tilegrid'}, handlers='delete_button'}
        }},
        -- confirmation titlebar
        {template='vertically_centered_flow', mods={visible=false}, children={
          {type='label', style='tl_invalid_bold_label', caption={'tl-gui.confirm-delete'}},
          {template='pushers.horizontal'},
          {type='sprite-button', style='tool_button', sprite='utility/reset', handlers='confirm_no_button'},
          {type='sprite-button', style='red_icon_button', sprite='utility/trash', handlers='confirm_yes_button'},
        }}
      }},
      -- origin
      {template='vertically_centered_flow', children={
        {type='label', caption={'', {'tl-gui.origin'}, ' [img=info]'}, tooltip={'tl-gui.origin-tooltip'}},
        {template='pushers.horizontal'},
        {type='drop-down', items=origin_localized_items, selected_index=corner_to_index[util.area.opposite_corner(hot_corner)], handlers='origin_dropdown'}
      }},
      -- grid type switch
      {type='flow', style={vertical_align='center'}, direction='horizontal', children={
        {type='label', caption={'tl-gui.grid-type'}},
        {template='pushers.horizontal'},
        {type='switch', left_label_caption={'tl-gui.gridtype-increment'}, right_label_caption={'tl-gui.gridtype-split'},
          switch_state=type_to_switch_state[grid_type], handlers='grid_type_switch', save_as=true}
      }},
      -- divisor label
      {type='flow', style={horizontal_align='center', horizontally_stretchable=true}, children={
        {type='label', style='caption_label', caption={'tl-gui.'..type_index_to_name[grid_type]..'-divisor-label'}, save_as='divisor_label'},
      }},
      -- divisor slider and textfield
      {type='flow', style={horizontal_spacing=8, vertical_align='center'}, direction='horizontal', children={
        {type='slider', style={name='notched_slider', horizontally_stretchable=true}, minimum_value=type_to_clamps[grid_type][1],
          maximum_value=type_to_clamps[grid_type][2], value_step=1, value=settings[type_index_to_name[grid_type]..'_divisor'], discrete_slider=true,
          discrete_values=true, handlers='divisor_slider', save_as=true},
        {type='textfield', style='tl_slider_textfield', numeric=true, lose_focus_on_confirm=true,
          text=settings[type_index_to_name[grid_type]..'_divisor'], handlers='divisor_textfield', save_as=true}
      }},
      -- reposition button
      {type='button', style={horizontally_stretchable=true, top_margin=4}, caption={'tl-gui.reposition'}, handlers='reposition_button', save_as=true}
    }}
  )
  if game.is_multiplayer() then
    data.reposition_button.enabled = false
    data.reposition_button.tooltip = {'tl-gui.multiplayer-broken'}
  end
  return data
end

function self.update(player_index, settings)
  local player_table = global.players[player_index]
  settings = settings or player_table.tilegrids.registry[player_table.tilegrids.editing]
  local elems = player_table.gui.edit.elems
  -- update values and names of divisor elements
  local grid_type = settings.grid_type
  elems.divisor_label.caption = {'tl-gui.'..type_index_to_name[grid_type]..'-divisor-label'}
  elems.divisor_slider.set_slider_minimum_maximum(type_to_clamps[grid_type][1], type_to_clamps[grid_type][2])
  elems.divisor_slider.slider_value = settings[type_index_to_name[grid_type]..'_divisor']
  elems.divisor_textfield.text = settings[type_index_to_name[grid_type]..'_divisor']
end

function self.destroy(window, player)
  gui.destroy(window, 'edit', player.index)
  -- remove capsule from hand if it's there
  local stack = player.cursor_stack
  if stack and stack.valid_for_read and stack.name == 'tapeline-adjust' then
    player.clean_cursor()
  end
end

return self