-- ----------------------------------------------------------------------------------------------------
-- SELECT GUI
-- Select which tilegrid to edit

local event = require('lualib/event')
local mod_gui = require('mod-gui')
local util = require('lualib/util')

local edit_gui = require('scripts/gui/edit')

local select_gui = {}

-- --------------------------------------------------
-- LOCAL UTILITIES

local function attach_highlight_box(gui_data, grid_index, player_index)
  local area = global.tilegrids.registry[gui_data.tilegrids[grid_index]].area
  if gui_data.highlight_box then gui_data.highlight_box.destroy() end
  gui_data.highlight_box = game.get_player(player_index).surface.create_entity{
    name = 'highlight-box',
    position = area.left_top,
    bounding_box = util.area.expand(area, 0.25),
    render_player_index = player_index,
    player = player_index,
    blink_interval = 30
  }
end

-- --------------------------------------------------
-- EVENT HANDLERS

local function selection_listbox_state_changed(e)
  attach_highlight_box(global.players[e.player_index].gui.select, e.element.selected_index, e.player_index)
end

local function back_button_clicked(e)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.gui.select
  player_table.flags.selecting = false
  select_gui.destroy(gui_data.elems.window, e.player_index)
  gui_data.highlight_box.destroy()
  player_table.gui.select = nil
end

local function confirm_button_clicked(e)
  local player_table = global.players[e.player_index]
  player_table.flags.selecting = false
  local select_gui_data = player_table.gui.select
  local tilegrid_index = select_gui_data.tilegrids[select_gui_data.elems.selection_listbox.selected_index]
  player_table.flags.editing = tilegrid_index
  local tilegrid_registry = global.tilegrids.registry[tilegrid_index]
  local edit_gui_elems, last_value = edit_gui.create(select_gui_data.elems.window.parent, e.player_index, tilegrid_registry.settings,
                             tilegrid_registry.hot_corner)
  select_gui.destroy(select_gui_data.elems.window, e.player_index)
  player_table.gui.edit = {elems=edit_gui_elems, highlight_box=select_gui_data.highlight_box, last_divisor_value=last_value}
  player_table.gui.select = nil
end

local handlers = {
  select_back_button_clicked = back_button_clicked,
  select_confirm_button_clicked = confirm_button_clicked
}

event.on_load(function()
  event.load_conditional_handlers(handlers)
end)

-- --------------------------------------------------
-- LIBRARY

function select_gui.create(parent, player_index)
  local window = parent.add{type='frame', name='tl_select_window', style=mod_gui.frame_style, direction='vertical'}
  window.style.width = gui_window_width
  local hint_flow = window.add{type='flow', name='tl_select_hint_flow', style='tl_horizontally_centered_flow', direction='vertical'}
  local hint_label = hint_flow.add{type='label', name='tl_select_hint', style='caption_label', caption={'tl-gui-select.hint-label-caption'}}
  local selection_listbox = window.add{type='list-box', name='tl_select_listbox', items={}}
  selection_listbox.visible = false
  event.on_gui_selection_state_changed(selection_listbox_state_changed, {name='select_selection_listbox_state_changed', player_index=player_index,
    gui_filters=selection_listbox})
  local dialog_flow = window.add{type='flow', name='tl_select_dialog_flow', style='dialog_buttons_horizontal_flow', direction='horizontal'}
  local back_button = dialog_flow.add{type='button', name='tl_select_back_button', style='back_button', caption={'gui.cancel'}}
  event.on_gui_click(back_button_clicked, {name='select_back_button_clicked', player_index=player_index, gui_filters=back_button})
  local confirm_button = dialog_flow.add{type='button', name='tl_select_confirm_button', style='confirm_button', caption={'gui.confirm'}}
  event.on_gui_click(confirm_button_clicked, {name='select_confirm_button_clicked', player_index=player_index, gui_filters=confirm_button})
  dialog_flow.visible = false
  return {window=window, hint_label=hint_label, selection_listbox=selection_listbox, dialog_flow=dialog_flow, back_button=back_button,
      confirm_button=confirm_button}
end

function select_gui.populate_listbox(player_index, tilegrids)
  local player_table = global.players[player_index]
  local gui_data = player_table.gui.select
  local elems = gui_data.elems
  local listbox = elems.selection_listbox
  local registry = global.tilegrids.registry
  -- populate listbox
  for _,i in ipairs(tilegrids) do
    local area = registry[i].area
    listbox.add_item(area.width..', '..area.height)
  end
  listbox.selected_index = 1
  -- change element visibility
  listbox.visible = true
  elems.dialog_flow.visible = true
  -- add data to global table
  gui_data.highlight_box = highlight_box
  gui_data.tilegrids = tilegrids
  -- attach a highlight box to the first grid on the list
  attach_highlight_box(gui_data, 1, player_index)
end

function select_gui.destroy(window, player_index)
  -- deregister all GUI events if needed
  for cn,h in pairs(handlers) do
    event.deregister_conditional(h, {name=cn, player_index=player_index})
  end
  window.destroy()
end

return select_gui