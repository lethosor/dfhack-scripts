local utils = require 'utils'

if enabled == nil then
    enabled = false
    interval = 5
end

function tick()
    dfhack.screen.zoom(df.zoom_commands.zoom_resetgrid)
    if enabled then
        dfhack.timeout(interval, 'frames', tick)
    end
end

args = {...}
iargs = utils.invert(args)

if args[1] == 'enable' then
    if df.global.enabler.renderer:uses_opengl() and iargs['no-opengl'] then
        enabled = false
        return
    end
    if not enabled then
        enabled = true
        tick()
    end
elseif args[1] == 'disable' then
    enabled = false
elseif args[1] == 'interval' then
    new = tonumber(args[2])
    if new == nil or new < 1 then
        qerror('Invalid interval: ' .. (args[2] or ''))
    end
    interval = new
else
    print('Usage: autoresetgrid enable|disable|interval')
end
