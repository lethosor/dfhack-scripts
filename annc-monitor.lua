-- Displays announcements in the DFHack console

VERSION = '0.2'

eventful = require 'plugins.eventful'

if enabled == nil then
    enabled = false
end

function usage()
    print [[
Usage:
    annc-monitor start: Begin monitoring
    annc-monitor stop: End monitoring
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
if #args >= 1 then
    if args[1] == 'start' then
        enabled = true
    elseif args[1] == 'stop' then
        enabled = false
    else
        usage()
    end
else
    usage()
end

eventful.enableEvent(eventful.eventType.REPORT, 1)
eventful.onReport.annc_monitor = annc_handler
