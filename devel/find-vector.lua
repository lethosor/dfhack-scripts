function inRange(addr)
    for _, r in pairs(dfhack.internal.getMemRanges()) do
        if addr >= r.start_addr and addr < r.end_addr then
            return true
        end
    end
    return false
end

ms = require 'memscan'
data = ms.get_data_segment()
length = math.floor(tonumber(({...})[1])) or qerror('bad length!')

rawstr = ({...})[2]
if rawstr then
    rawtbl = {}
    for i = 1, #rawstr, 2 do
        local s = rawstr:sub(i, i + 1)
        table.insert(rawtbl, tonumber('0x' .. s) or qerror('bad hex: ' .. s))
    end
    raw = df.new('uint8_t', #rawtbl)
    for i, v in ipairs(rawtbl) do
        raw[i - 1] = v
    end
end

uptr = data.uintptr_t
for i = 0, uptr.count - 3 do
    if uptr.data[i] + length == uptr.data[i + 1] and uptr.data[i + 1] <= uptr.data[i + 2] then
        for j = 0, 2 do
            if not inRange(uptr.data[i + j]) then
                goto next_vector
            end
        end
        local addr = uptr.start + (i * uptr.esize)
        if rawtbl then
            local _, ptr = dfhack.internal.memscan(uptr.data[i], #rawtbl, 1, raw, #rawtbl)
            if ptr ~= uptr.data[i] then
                goto next_vector
            end
        end
        print(('0x%x: start 0x%x, length %d, allocated %d'):format(
            addr, uptr.data[i], length, uptr.data[i + 2] - uptr.data[i]))
    end
    ::next_vector::
end

if raw then
    df.delete(raw)
end
