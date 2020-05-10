local draw_gui = {}

local gui = require("__flib__.gui")
local util = require("scripts.util")

type_to_switch_state = {"left", "right"}
switch_state_to_type_index = {left=1, right=2}
type_index_to_name = {"increment", "split"}
type_to_clamps = {{4,13}, {2,11}}

gui.add_handlers{
  draw = {
    auto_clear_checkbox = {
      on_gui_checked_state_changed = function(e)
        local player_table = global.players[e.player_index]
        player_table.settings.auto_clear = e.element.state
      end
    },
    cardinals_checkbox = {
      on_gui_checked_state_changed = function(e)
        local player_table = global.players[e.player_index]
        player_table.settings.cardinals_only = e.element.state
      end
    },
    grid_type_switch = {
      on_gui_switch_state_changed = function(e)
        local player_table = global.players[e.player_index]
        player_table.settings.grid_type = switch_state_to_type_index[e.element.switch_state]
        draw_gui.update(e.player_index)
      end
    },
    divisor_slider = {
      on_gui_value_changed = function(e)
        local player_table = global.players[e.player_index]
        local gui_data = player_table.gui.draw
        local divisor_name = type_index_to_name[player_table.settings.grid_type].."_divisor"
        if e.element.slider_value == tonumber(gui_data.last_divisor_value) then return end
        gui_data.last_divisor_value = e.element.slider_value
        player_table.settings[divisor_name] = e.element.slider_value
        gui_data.elems.divisor_textfield.text = e.element.slider_value
      end
    },
    divisor_textfield = {
      on_gui_text_changed = function(e)
        local player_table = global.players[e.player_index]
        local gui_data = player_table.gui.draw
        local new_value = util.textfield.clamp_number_input(e.element, type_to_clamps[player_table.settings.grid_type], gui_data.last_divisor_value)
        if new_value ~= gui_data.last_divisor_value then
          gui_data.last_divisor_value = new_value
          gui_data.elems.divisor_slider.slider_value = new_value
        end
      end,
      on_gui_confirmed = function(e)
        local player_table = global.players[e.player_index]
        local final_text = util.textfield.set_last_valid_value(e.element, player_table.gui.draw.last_divisor_value)
        player_table.settings[type_index_to_name[player_table.settings.grid_type].."_divisor"] = tonumber(final_text)
      end
    }
  }
}

function draw_gui.create(parent, player_index, default_settings)
  local grid_type = default_settings.grid_type
  local data = gui.build(parent, {
    {template="window", name="tl_draw_window", children={
      -- checkboxes
      {type="flow", direction="horizontal", children={
        {type="checkbox", caption={"", {"tl-gui.auto-clear"}, " [img=info]"}, tooltip={"tl-gui.auto-clear-tooltip"}, state=default_settings.auto_clear,
          handlers="draw.auto_clear_checkbox", save_as="auto_clear_checkbox"},
        {template="pushers.horizontal"},
        {type="checkbox", caption={"", {"tl-gui.cardinals-only"}, " [img=info]"}, tooltip={"tl-gui.cardinals-only-tooltip"},
          state=default_settings.cardinals_only, handlers="draw.cardinals_checkbox", save_as="cardinals_checkbox"}
      }},
      -- grid type switch
      {type="flow", style_mods={vertical_align="center"}, direction="horizontal", children={
        {type="label", caption={"tl-gui.grid-type"}},
        {template="pushers.horizontal"},
        {type="switch", left_label_caption={"tl-gui.gridtype-increment"}, right_label_caption={"tl-gui.gridtype-split"},
          switch_state=type_to_switch_state[grid_type], handlers="draw.grid_type_switch", save_as="grid_type_switch"}
      }},
      -- divisor label
      {type="flow", style_mods={horizontal_align="center", horizontally_stretchable=true}, children={
        {type="label", style="caption_label", caption={"tl-gui."..type_index_to_name[grid_type].."-divisor-label"}, save_as="divisor_label"},
      }},
      -- divisor slider and textfield
      {type="flow", style_mods={horizontal_spacing=8, vertical_align="center"}, direction="horizontal", children={
        {type="slider", style="notched_slider", style_mods={horizontally_stretchable=true}, minimum_value=type_to_clamps[grid_type][1],
          maximum_value=type_to_clamps[grid_type][2], value_step=1, value=default_settings[type_index_to_name[grid_type].."_divisor"], discrete_slider=true,
          discrete_values=true, handlers="draw.divisor_slider", save_as="divisor_slider"},
        {type="textfield", style="tl_slider_textfield", numeric=true, lose_focus_on_confirm=true,
          text=default_settings[type_index_to_name[grid_type].."_divisor"], handlers="draw.divisor_textfield", save_as="divisor_textfield"}
      }}
    }}
  })
  return data
end

function draw_gui.update(player_index)
  local player_table = global.players[player_index]
  local settings = player_table.settings
  local elems = player_table.gui.draw.elems
  -- update values and names of divisor elements
  local grid_type = settings.grid_type
  elems.divisor_label.caption = {"tl-gui."..type_index_to_name[grid_type].."-divisor-label"}
  elems.divisor_slider.set_slider_minimum_maximum(type_to_clamps[grid_type][1], type_to_clamps[grid_type][2])
  elems.divisor_slider.slider_value = settings[type_index_to_name[grid_type].."_divisor"]
  elems.divisor_textfield.text = settings[type_index_to_name[grid_type].."_divisor"]
end

function draw_gui.destroy(window, player_index)
  gui.update_filters("draw", player_index, nil, "remove")
  window.destroy()
end

return draw_gui