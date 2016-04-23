-- accessibility game event logging

repeatUtil = require('repeat-util')

logf = logf or io.open('acclog.txt', 'w')
function log(s)
    if not s:endswith('\n') then s = s .. '\n' end
    logf:write(s)
    logf:flush()
end

handlers = {
    viewscreen = {},
    global = {},
}
for k in pairs(df) do
    if k == 'viewscreen' or k:startswith('viewscreen_') or k:find('Screen') then
        handlers.viewscreen[k:gsub('viewscreen_', '')] = {
            field_change = {},
            _field_values = {},
        }
    end
end

function getViewscreenTypeName(scr)
    scr = scr or dfhack.gui.getCurViewscreen()
    return tostring(scr._type):match('<type: ([A-Za-z_]+)'):gsub('viewscreen_', '')
end

function getViewscreenHandler(scr)
    scr = scr or dfhack.gui.getCurViewscreen()
    return handlers.viewscreen[getViewscreenTypeName(scr)] or
        error('no viewscreen handler for ' .. tostring(scr) .. ': ' .. getViewscreenTypeName(scr))
end

handlers.viewscreen.titlest.name = 'title screen'
function handlers.viewscreen.titlest.field_change.sel_menu_line(screen, field, value)
    log('selected: ' .. ({
        [0] = 'Continue Playing',
        [1] = 'Start Playing',
        [2] = 'Create New World',
        [3] = 'Design New World with Advanced Parameters',
        [4] = 'Object Testing Arena',
        [5] = 'About DF',
        [6] = 'Quit',
    })[value])
end

handlers.viewscreen.optionst.name = 'options menu'
function handlers.viewscreen.optionst.field_change.sel_idx(screen, field, value)
    log('selected: ' .. ({
        [0] = 'Back',
        [1] = 'Save',
        [2] = 'Key Bindings',
        [3] = 'Export local image',
        [4] = 'Music and sound',
        [5] = 'Retire or Abort',
        [6] = 'Abandon',
    })[value])
end

handlers.viewscreen.loadgamest.name = 'load game screen'
function handlers.viewscreen.loadgamest.field_change.sel_idx(screen, field, value)
    log('selected game: ' .. screen.saves[value].folder_name)
end

-- add handlers above this line

_last_scr = nil
function tick()
    local scr = dfhack.gui.getCurViewscreen()
    local scr_handler = getViewscreenHandler(scr)
    if scr ~= _last_scr then
        local name = getViewscreenHandler().name
        if name then
            log('switched to ' .. name)
        else
            log('switched to screen: ' .. dfhack.gui.getCurFocus())
        end
        _last_scr = scr
        for k in pairs(scr_handler._field_values) do
            scr_handler._field_values[k] = nil
        end
    end
    if scr_handler.tick then
        scr_handler.tick(scr)
    end
    for field, func in pairs(scr_handler.field_change) do
        if scr_handler._field_values[field] ~= scr[field] then
            func(scr, field, scr[field])
            scr_handler._field_values[field] = scr[field]
        end
    end
end
function safe_tick()
    local ok, err = pcall(tick)
    if not ok then
        dfhack.printerr(err)
    end
end
repeatUtil.cancel('acclog')
if ({...})[1] ~= 'disable' then
    repeatUtil.scheduleEvery('acclog', 10, 'frames', safe_tick)
end
