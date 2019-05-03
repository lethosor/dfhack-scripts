ru = require 'repeat-util'

function feed_key(k)
    dfhack.gui.getCurViewscreen():feed_key(df.interface_key[k])
end

function toassign()
    feed_key 'D_BUILDJOB'
    feed_key 'BUILDJOB_BED_ASSIGN'
    if not df.global.ui_building_in_assign then
        qerror('Select a bed')
    end
end
toassign()

function tomap()
    for i = 1, 10 do
        if df.global.ui.main.mode ~= df.ui_sidebar_mode.Default then
            feed_key 'LEAVESCREEN'
        else
            return
        end
    end
    error('tomap failed')
end

function mkgarbage()
    u = {}
    for i = 1, 100 do
        for _, unit in ipairs(df.global.world.units.all) do
            table.insert(u, unit)
        end
    end
    for i = 1, 4 do
        u = {u, u}
    end
end

state = true
count = 1

function loop()
    if state then
        tomap()
    else
        toassign()
    end
    state = not state
    mkgarbage()
    print(count, collectgarbage('count'))
    count = count + 1
end

ru.scheduleEvery('bld-assign-rep', 10, 'frames', loop)
df.global.pause_state = false

-- df.global.pause_state = false

