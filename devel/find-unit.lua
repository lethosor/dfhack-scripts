utils = require 'utils'

function search(list, list_name, id, verbose)
    local function p(msg, color)
        dfhack.color(color)
        dfhack.print(('[%s]: %s\n'):format(list_name, msg))
        dfhack.color()
    end
    local found = false
    for i, unit in pairs(list) do
        if verbose then
            p('checking index ' .. i)
        end
        if unit.id == id then
            p('found at index ' .. i, COLOR_LIGHTGREEN)
            found = true
            break
        end
    end
    if not found then
        p('Unit not in list')
    end
end

args = {...}
id = tonumber(args[1]) or qerror('invalid unit ID')
search_bad = (args[2] == 'bad')
if search_bad then
    local start = tonumber(args[3]) or 0
    dfhack.printerr("Warning: This option can crash DF!\n")
    print([[
Unit indices will be displayed as they are checked. If DF crashes, you can skip
a problematic index next time by passing the number after the last displayed
index as a third argument to this script.
]])
    print('Starting at index ' .. start)
    if not utils.prompt_yes_no("Did you save before running this script? ") then
        qerror('aborted')
    end
    search(df.global.world.units.bad, 'bad', id, true)
else
    search(df.global.world.units.all, 'all', id)
    search(df.global.world.units.active, 'active', id)
    search(df.global.world.units.other.ANY_RIDER, 'other.ANY_RIDER', id)
    search(df.global.world.units.other.ANY_BABY2, 'other.ANY_BABY2', id)
end
