-- Displays announcements in the DFHack console
--@ enable = true
--[[=begin

devel/annc-monitor
==================
Displays announcements and reports in the console.

:enable|start:      Begins monitoring
:disable|stop:      Stops monitoring
:interval X:        Sets the delay between checks for
                    new announcements to ``X`` frames

=end]]

VERSION = '0.2'

eventful = require 'plugins.eventful'

if enabled == nil then
    enabled = false
end

function usage()
    print [[
Usage:
    annc-monitor start|enable: Begin monitoring
    annc-monitor stop|disable: End monitoring
]]
end

function log(s, color)
    dfhack.color(color)
    print(dfhack.df2utf(s))
    dfhack.color(COLOR_RESET)
end

function annc_handler(id)
    if enabled and dfhack.isWorldLoaded() then
        local annc = df.report.find(id)
        local color = annc.color + (annc.bright and 8 or 0)
        log(annc.text, color)
    end
end

args = {...}
if dfhack_flags and dfhack_flags.enable then
    table.insert(args, dfhack_flags.enable_state and 'enable' or 'disable')
end
if #args >= 1 then
    if args[1] == 'start' or args[1] == 'enable' then
        enabled = true
    elseif args[1] == 'stop' or args[1] == 'disable' then
        enabled = false
    else
        usage()
    end
else
    usage()
end

eventful.enableEvent(eventful.eventType.REPORT, 1)
eventful.onReport.annc_monitor = annc_handler
