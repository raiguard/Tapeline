local color = require('__stdlib__/stdlib/utils/color')

-- constants

local constants = {}

constants.modName = 'Tapeline'
constants.modAssetName = '__' .. constants.modName .. '__'

-- file paths
constants.itemAssetPath = constants.modAssetName .. '/graphics/icons/item/'
constants.shortcutAssetPath = constants.modAssetName .. '/graphics/icons/shortcut-bar/'

-- debug logging
constants.isDebugMode = false

-- colors
constants.possible_colors = {
    'white',
    'black',
    'darkgrey',
    'grey',
    'lightgrey',
    'darkred',
    'red',
    'lightred',
    'darkgreen',
    'green',
    'lightgreen',
    'darkblue',
    'blue',
    'lightblue',
    'orange',
    'yellow',
    'pink',
    'purple',
    'brown'
}

-- positioning / graphics
constants.tilegrid_width = 1.4

return constants