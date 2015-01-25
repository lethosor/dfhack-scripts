-- Adjust display colors

VERSION = '0.2'

if original_colors == nil then
    original_colors = {}
    for i = 0, 15 do
        original_colors[i] = {}
        for j = 0, 2 do
            original_colors[i][j] = df.global.enabler.ccolor[i][j]
        end
    end
end

utils = require 'utils'

function adjust_colors(components, multiplier)
    local rgb = 'rgb'
    if tonumber(multiplier) == nil then
        qerror('Unrecognied number: ' .. multiplier)
    end
    for i = 1, #components do
        local color_id = rgb:find(components:sub(i, i))
        if color_id ~= nil then
            color_id = color_id - 1
            for c = 0, 15 do
                df.global.enabler.ccolor[c][color_id] =
                    df.global.enabler.ccolor[c][color_id] * tonumber(multiplier)
            end
        end
    end
end

function reset_colors()
    for i = 0, 15 do
        for j = 0, 2 do
            df.global.enabler.ccolor[i][j] = original_colors[i][j]
        end
    end
end

args = utils.processArgs({...})
if args['all'] then args['a'] = args['all'] end
if args['a'] then
    adjust_colors('rgb', args['a'])
elseif args['reset'] then
    reset_colors()
else
    for k, v in pairs(args) do
        adjust_colors(k, v)
    end
end

df.global.gps.force_full_display_count = 1
