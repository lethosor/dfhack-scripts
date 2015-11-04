-- Displays changes in the key modifier state
--@ enable = true
--[[=begin

devel/modstate-monitor
======================
Display changes in key modifier state, ie Ctrl/Alt/Shift.

:enable|start:  Begin monitoring
:disable|stop:  End monitoring

=end]]

VERSION = '0.1'

if active == nil then active = false end

if dfhack.internal.getModstate == nil or dfhack.internal.getModifiers == nil then
    qerror('Required internal functions are missing')
end

function usage()
    print [[
Usage:
    modstate-monitor enable|start: Begin monitoring
    modstate-monitor disable|stop: End monitoring
]]
end

function set_timeout()
    dfhack.timeout(1, 'frames', check)
end

function log(s, color)
    -- prevent duplicate output
    if s ~= last_msg then
        dfhack.color(color)
        print(s)
        last_msg = s
    end
end

function check()
    local msg = ''
    local modstate = dfhack.internal.getModstate()
    if modstate ~= last_modstate then
        last_modstate = modstate
        for k, v in pairs(dfhack.internal.getModifiers()) do
            msg = msg .. k .. '=' .. (v and 1 or 0) .. ' '
        end
        log(msg)
    end
    if active then set_timeout() end
end

args = {...}
if dfhack_flags and dfhack_flags.enable then
    table.insert(args, dfhack_flags.enable_state and 'enable' or 'disable')
end

if #args == 1 then
    if args[1] == 'enable' or args[1] == 'start' then
        set_timeout()
        active = true
    elseif args[1] == 'disable' or args[1] == 'stop' then
        active = false
    else
        usage()
    end
else
    usage()
end
