stdlib = {}
stdlib.area = require('__stdlib__/stdlib/area/area')
stdlib.color = require('__stdlib__/stdlib/utils/color')
stdlib.event = require('__stdlib__/stdlib/event/event')
stdlib.gui = require('__stdlib__/stdlib/event/gui')
stdlib.logger = require('__stdlib__/stdlib/misc/logger').new('Tapeline_Debug', true)
stdlib.position = require('__stdlib__/stdlib/area/position')
stdlib.table = require('__stdlib__/stdlib/utils/table')
stdlib.tile = require('__stdlib__/stdlib/area/tile')

require('scripts/gui')
require('scripts/rendering')
require('scripts/settings')
require('scripts/tilegrid')

mod_gui = require('mod-gui')