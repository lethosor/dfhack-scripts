-- find raw
ms = require 'memscan'
data = ms.get_data_segment()
rawstr = ({...})[1] or qerror('no data given!')
rawtbl = {}
for i = 1, #rawstr, 2 do
    local s = rawstr:sub(i, i + 1)
    table.insert(rawtbl, tonumber('0x' .. s) or qerror('bad hex: ' .. s))
end
if #rawtbl < 1 then
    qerror('not enough data')
end
raw = df.new('uint8_t', #rawtbl)
for i, v in ipairs(rawtbl) do
    raw[i - 1] = v
end

start = data.start_addr
while true do
    count = data.end_addr - start - 1
    -- print('scan', ('0x%x'):format(start), count, 1, raw, #rawtbl, ('end=0x%x'):format(start+count))
    assert(start + count < data.end_addr)
    _, ptr = dfhack.internal.memscan(start, count, 1, raw, #rawtbl)
    if not ptr then
        break
    end
    print(('found sequence at 0x%x'):format(ptr))
    start = ptr + 1
end

df.delete(raw)
