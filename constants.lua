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
constants.colors = {}
constants.colors.tilegrid_div = {}

constants.colors.tilegrid_div[1] = color.set(defines.color.grey)
constants.colors.tilegrid_div[2] = color.set(defines.color.lightgreen)
constants.colors.tilegrid_div[3] = color.set(defines.color.lightred)
constants.colors.tilegrid_div[4] = color.set(defines.color.yellow)
constants.colors.tilegrid_background = color.set(defines.color.black, 0.6)
constants.colors.tilegrid_border = color.set(defines.color.grey)
constants.colors.tilegrid_label = color.set(defines.color.lightgrey, 0.8)

-- positioning / graphics
constants.tilegrid_width = 1.4

return constants