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

constants.colors.tilegrid_div[1] = {r=0.3,g=0.3,b=0.7,a=1}
constants.colors.tilegrid_div[2] = {r=0.3,g=0.8,b=0.3,a=1}
constants.colors.tilegrid_div[3] = {r=0.9,g=0.3,b=0.3,a=1}
constants.colors.tilegrid_div[4] = {r=0.8,g=0.8,b=0.3,a=1}
constants.colors.tilegrid_background = {r=0,g=0,b=0,a=0.4}
constants.colors.tilegrid_border = {r=0.6,g=0.6,b=0.6,a=1}
constants.colors.tilegrid_label = {r=0.7,g=0.7,b=0.7,a=0.8}

-- positioning / graphics
constants.tilegrid_width = 1.4

return constants