-- Displays the mouse (grid) coordinates when the mouse is clicked
--@ enable = true
--[[=begin

devel/click-monitor
===================
Displays the grid coordinates of mouse clicks in the console.
Useful for plugin/script development.

Usage: ``devel/click-monitor start|stop``

=end]]

VERSION = '0.2'

if active == nil then active = false end

function usage()
    print [[
Usage:
    click-monitor enable|start: Begin monitoring
    click-monitor disable|stop: End monitoring
]]
end

function set_timeout()
    dfhack.timeout(1, 'frames', check_click)
end

function log(s, color)
    -- prevent duplicate output
    if s ~= last_msg then
        dfhack.color(color)
        print(s)
        last_msg = s
    end
end

function check_click()
    local s = ''
    local color = COLOR_RESET
    for _, attr in pairs({'mouse_lbut', 'mouse_rbut', 'mouse_lbut_down',
        'mouse_rbut_down', 'mouse_lbut_lift', 'mouse_rbut_lift'}) do
        if df.global.enabler[attr] ~= 0 then
            s = s .. '[' .. attr:sub(7) .. ']  '
        end
    end
    if s ~= '' then
        s = ('x = %2i, y = %2i  '):format(df.global.gps.mouse_x, df.global.gps.mouse_y) .. s
        if s:find('rbut') then
            color = (s:find('lbut') and COLOR_GREEN) or COLOR_BLUE
        end
        if df.global.gps.mouse_x == -1 then color = COLOR_RED end
        log(s, color)
    else
        last_msg = nil
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
