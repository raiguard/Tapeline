-- ----------------------------------------------------------------------------------------------------
-- GUI CONTROL SCRIPTING
-- Creation and management of the GUI. Also includes GUI listeners.

local event = require('__stdlib__/stdlib/event/event')
local on_event = event.register
local gui = require('__stdlib__/stdlib/event/gui')
local util = require('util')

local mod_gui = require('__core__/lualib/mod-gui')

local lib = {}

-- ----------------------------------------------------------------------------------------------------
-- GUI ELEMENT MANAGEMENT

local function create_settings_window(player, tilegrid)
    local settings = tilegrid and tilegrid.settings or util.player_table(player).settings
    local window = mod_gui.get_frame_flow(player).add{type='frame', name='tapeline_settings_window', style='dialog_frame', direction='vertical'}
    if tilegrid then
        -- create titlebar
        local titlebar_flow = window.add{type='flow', name='tapeline_settings_titlebar_flow', style='titlebar_flow', direction='horizontal'}
        titlebar_flow.add{type='label', name='tapeline_settings_titlebar_label', style='heading_1_label', caption={'gui-settings.titlebar_label_caption', }}
    end
end

-- ----------------------------------------------------------------------------------------------------

function lib.open(player, tilegrid)
    create_settings_window(player, tilegrid)
end

return lib