function str2bytes(s)
    return {s:byte(1, #s)}
end

function str2raw(s)
    local bytes = str2bytes(s)
    local raw = df.new('uint8_t', #bytes)
    for i = 1, #bytes do
        raw[i - 1] = bytes[i]
    end
    return raw
end

function strtbl(s)
    return {
        str = s,
        bytes = str2bytes(s),
        raw = str2raw(s),
        length = #str2bytes(s),
    }
end

str1 = strtbl "catch(:script_finished) { load '"
str1r = strtbl "catch(:script_finished) { load \""
str2 = strtbl "' }"
str2r = strtbl "\" }"

function cleanup()
    for _, s in pairs{str1, str1r, str2, str2r} do
        df.delete(s.raw)
    end
end

function find_raw(range, raw, length)
    local addrs = {}
    local start = range.start_addr
    local ptr = true
    while ptr do
        local count = range.end_addr - start + 1
        local _, ptr = dfhack.internal.memscan(start, count, 1, raw, length)
        if ptr then
            table.insert(addrs, ptr)
            start = ptr + 1
        else
            break
        end
    end
    return addrs
end

function tohex(obj)
    if type(obj) == 'table' then
        for k in pairs(obj) do
            obj[k] = tohex(obj[k])
        end
        return obj
    else
        return ('0x%x'):format(obj)
    end
end

function main()
    assert(str1.length == str1r.length)
    assert(str2.length == str2r.length)
    local str1_addr = nil
    local str1_range = nil
    for _, range in ipairs(dfhack.internal.getMemRanges()) do
        if range.read and (range.name:match('libdfhack') or range.name:match('SDL%.')) then
            local addrs = find_raw(range, str1.raw, str1.length)
            if #addrs > 1 then
                error('multiple addresses found: ' .. table.concat(tohex(addrs), ', '))
            elseif #addrs == 1 then
                if str1_addr then
                    error('conflict: prev=' .. tohex(str1_addr) .. ', new=' .. tohex(addrs[1]))
                else
                    str1_addr = addrs[1]
                    str1_range = range
                end
            end
        end
    end
    if not str1_addr then
        error('could not find str1')
    end
    print('str1 addr: ' .. tohex(str1_addr))

    local str2_addrs = find_raw({
            start_addr = math.max(str1_range.start_addr, str1_addr - 128),
            end_addr = math.min(str1_range.end_addr, str1_addr + 128),
        }, str2.raw, str2.length)
    if #str2_addrs ~= 1 then
        error('bad str2 address candidates: ' .. table.concat(tohex(str2_addrs), ', '))
    end
    local str2_addr = str2_addrs[1]
    print('str2 addr: ' .. tohex(str2_addr))

    dfhack.internal.patchMemory(str1_addr, str1r.raw, str1r.length)
    dfhack.internal.patchMemory(str2_addr, str2r.raw, str2r.length)
end

dfhack.with_finalize(cleanup, main)
