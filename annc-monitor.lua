-- Displays announcements in the DFHack console

if active == nil then active = false end
if next_annc_id == nil then next_annc_id = 0 end
if timeout_interval == nil then timeout_interval = 2 end

function set_timeout()
    dfhack.timeout(timeout_interval, 'frames', check_announcements)
end

function log(s, color)
    dfhack.color(color)
    print(s)
    dfhack.color(COLOR_RESET)
end

function check_announcements()
    local annc_total = #df.global.world.status.reports
    if annc_total > next_annc_id then
        for i = next_annc_id, annc_total - 1 do
            local annc = df.global.world.status.reports[i]
            local color = annc.color + (annc.bright and 8 or 0)
            log(annc.text, color)
        end
        next_annc_id = annc_total
    end
    if active then set_timeout() end
end

function usage()
    print [[
Usage:
    annc-monitor start: Begin monitoring
    annc-monitor stop: End monitoring
    annc-monitor interval NUMBER: Set poll interval (frames)
]]
end

args = {...}
if #args >= 1 then
    if args[1] == 'start' then
        active = true
        set_timeout()
    elseif args[1] == 'stop' then
        active = false
    elseif args[1] == 'interval' then
        local n = tonumber(args[2])
        if n == nil or n < 1 or n ~= math.floor(n) then
            qerror('"' .. args[2] .. '" is not an integer!')
        end
        timeout_interval = n
    else
        usage()
    end
else
    usage()
end

dfhack.onStateChange.annc_monitor = function(state)
    if state == SC_WORLD_LOADED then
        next_annc_id = 0
    end
end
