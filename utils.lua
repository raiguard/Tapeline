-- UTILS.LUA

local utils = {}

local debug = false

function utils.log(message, isDebug)

    if isDebug == nil then isDebug = true end

    if debug == true then game.print(message)
    elseif isDebug == false then game.print(message) end

end

function utils.round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function utils.rgb_format(table)

    return { r = (table[1] / 255), g = (table[2] / 255), b = (table[3] / 255), a = (table[4] / 255) or 1 }

end

return utils