-- Displays the mouse (grid) coordinates when the mouse is clicked
--@ enable = true

VERSION = '0.2'

if active == nil then active = false end

gps = df.global.gps
enabler = df.global.enabler

function usage()
    print [[
Usage:
    tile-info enable|start: Begin monitoring
    tile-info disable|stop: End monitoring
]]
end

function set_timeout()
    dfhack.timeout(1, 'frames', check_click)
end

function check_click()
    local s = ''
    local color = COLOR_RESET
    if enabler.mouse_lbut ~= 0 and (last_x ~= gps.mouse_x or last_y ~= gps.mouse_y) then
        print(('-'):rep(20))
        print(gps.mouse_x, gps.mouse_y)
        printall(dfhack.screen.readTile(gps.mouse_x, gps.mouse_y))
        last_x = gps.mouse_x
        last_y = gps.mouse_y
    elseif enabler.mouse_lbut == 0 then
        last_x = nil
    end
    if active then set_timeout() end
end

args = {...}
if dfhack_flags and dfhack_flags.enable then
    table.insert(args, dfhack_flags.enable_state and 'enable' or 'disable')
end

if #args == 1 then
    if args[1] == 'start' or args[1] == 'enable' then
        active = true
        set_timeout()
    elseif args[1] == 'stop' or args[1] == 'disable' then
        active = false
    else
        usage()
    end
else
    usage()
end
