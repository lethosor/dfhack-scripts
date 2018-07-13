cache = cache or {}

dfhack.onStateChange.screen_size = function(force)
    local scr = dfhack.gui.getCurViewscreen()
    local typename = getmetatable(scr)
    if cache[typename] and not force then
        return
    end
    local size, addr = scr:sizeof()
    local real_size = df.reinterpret_cast('int32_t', addr - 16).value
    if size == real_size then
        print(typename .. ' ' .. size .. ' (ok)')
    else
        dfhack.printerr(typename .. ' ' .. size .. ' real=' .. real_size)
    end
    cache[typename] = true
end
dfhack.onStateChange.screen_size(({...})[1] == 'force')
