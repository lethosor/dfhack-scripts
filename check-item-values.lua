script = require 'gui.script'
args = {...}
verbose = args[1] == 'verbose'

function readScreenLine(y)
    local line = ''
    for x = 0, df.global.gps.dimx - 1 do
        local ch = dfhack.screen.readTile(x,2).ch
        if ch ~= 0 then
            line = line .. string.char(ch)
        end
    end
    return line
end

script.start(function()
    local bld = dfhack.gui.getSelectedBuilding(true)
    if bld and df.global.ui.main.mode == df.ui_sidebar_mode.BuildingItems then
        for i = 0, #bld.contained_items - 1 do
            if verbose then
                print(i .. '/' .. (#bld.contained_items - 1))
            end
            local item = bld.contained_items[i].item
            df.global.ui_building_item_cursor = i
            local name = dfhack.df2console(tostring(i) .. ': ' .. dfhack.items.getDescription(item, 0))
            local d_scr = dfhack.gui.getViewscreenByType(df.viewscreen_dwarfmodest) or qerror('wrong screen')
            d_scr:feed_key(df.interface_key.SELECT)
            script.sleep(10, 'frames')

            local i_scr = dfhack.gui.getViewscreenByType(df.viewscreen_itemst) or qerror('wrong item screen')
            if i_scr.item ~= item then
                qerror('item mismatch ' .. i .. tostring(item) .. tostring(i_scr.item))
            end
            local tries = 0
            local value = nil
            while tries < 20 and not value do
                value = tonumber(readScreenLine(2):match('Value:%s*(%d+)'))
                tries = tries + 1
                script.sleep(1, 'frames')
            end
            if value then
                local dfhack_value = dfhack.items.getValue(item)
                if value ~= dfhack_value then
                    dfhack.printerr(('%s: Mismatch: real=%d, DFHack=%d'):format(name, value, dfhack_value))
                end
            else
                dfhack.printerr(name .. ': Could not find value')
            end
            i_scr:feed_key(df.interface_key.LEAVESCREEN)
            while dfhack.gui.getCurViewscreen(false) == i_scr do
                script.sleep(1, 'frames')
            end
        end
    else
        qerror("Unknown mode - try 't' on a building")
    end
end)
