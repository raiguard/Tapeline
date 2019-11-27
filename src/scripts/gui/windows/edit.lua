-- ----------------------------------------------------------------------------------------------------
-- EDIT GUI
-- Edit settings on a current tilegrid

local event = require('scripts/lib/event-handler')
local mod_gui = require('mod-gui')
local util = require('scripts/lib/util')

local edit_gui = {}

-- --------------------------------------------------
-- LOCAL UTILITIES

type_to_switch_state = {'left', 'right'}
switch_state_to_type_index = {left=1, right=2}
type_index_to_name = {'increment', 'split'}
type_to_clamps = {{4,13}, {2,11}}

-- --------------------------------------------------
-- EVENT HANDLERS



-- --------------------------------------------------
-- LIBRARY

function edit_gui.create(parent, player_index, settings)
	local window = parent.add{type='frame', name='tl_edit_window', style=mod_gui.frame_style, direction='vertical'}
	
end

function edit_gui.update(player_index)

end

function edit_gui.destroy(window, player_index)
    -- deregister all GUI events if needed
    local con_registry = global.conditional_event_registry
    for cn,h in pairs(handlers) do
        event.gui.deregister(con_registry[cn].id, h, cn, player_index)
    end
	window.destroy()
end

return edit_gui