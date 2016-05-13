-- A crude structure validity check
--@module = true

utils = require 'utils'

MAX_DEPTH = 20
MAX_LENGTH = 1000
MAX_ARRAY_LENGTH = 10
BLACKLIST = utils.invert{
    'df.global.world.enemy_status_cache.rel_map',
    'df.global.world.pathfinder.boundary_heap',
    'df.global.world.entities',
    'df.global.world.poetic_forms',
}

function blacklisted(expr)
    if BLACKLIST[expr] then
        return true
    end
    if expr:find('gview.view', 1, true) and expr:find('.child.parent', 1, true) then
        return true
    end
    if expr:find('entity_raw%.symbols%.symbols%d') then
        return true
    end
    if expr:find('df%.global%.world%.world_data%.region_details%.%d+%.features%.%d+') then
        return true
    end
end

function split_string(self, delimiter, raw)
    local result = { }
    local from = 1
    local delim_from, delim_to = self:find(delimiter, from, raw)
    while delim_from do
        table.insert(result, self:sub(from, delim_from-1))
        from  = delim_to + 1
        delim_from, delim_to = self:find(delimiter, from, raw)
    end
    table.insert(result, self:sub(from))
    return result
end

function eval(s)
    local f, err = load("return " .. s, "expression", "t")
    if err then qerror(err) end
    return f()
end

function safe_pairs(item)
    local ret = table.pack(pcall(function() return pairs(item) end))
    local ok = ret[1]
    table.remove(ret, 1)
    if ok then
        return table.unpack(ret)
    else
        return function() end
    end
end

function get_field_addr(object, name)
    local ok, f = pcall(function() return object:_field(name) end)
    if ok and f and f.sizeof then
        return ({f:sizeof()})[2]
    end
end

function get_addr(object)
    local ok, _, addr = pcall(function() return object:sizeof() end)
    if ok then return addr end
end

function walk(name, value, prefix, depth, scanned)
    local start_time
    if depth == nil then
        depth = 0
        start_time = os.clock()
    end
    if scanned == nil then scanned = {} end
    depth = depth + 1
    if depth > MAX_DEPTH then
        dfhack.printerr('max depth exceeded')
        return
    end
    local show = 1 or tonumber(name) == nil
    name = ((prefix and prefix .. '.') or '') .. name
    if blacklisted(name) then
        dfhack.printerr('skipping: ' .. name)
        return
    end
    if show then print(name) end
    local addr = get_addr(value)
    if addr then
        if scanned[addr] then
            dfhack.printerr('already scanned')
            return
        else
            scanned[addr] = true
        end
    end
    tostring(value)
    local count = 0
    local in_union = {}
    for k in safe_pairs(value) do
        local faddr = get_field_addr(value, k)
        if faddr then
            if in_union[faddr] == nil then
                in_union[faddr] = false
            elseif in_union[faddr] == false then
                in_union[faddr] = true
            end
        end
    end
    for k, v in safe_pairs(value) do
        if count > MAX_LENGTH or (count == k and count > MAX_ARRAY_LENGTH) then
            dfhack.printerr('max length exceeded')
            break
        end
        local faddr = get_field_addr(value, k)
        if faddr and in_union[faddr] then
            goto continue
        end
        count = count + 1
        walk(k, v, name, depth, scanned)
        ::continue::
    end
    if depth == 1 then
        print(('- elapsed: %f seconds'):format(os.clock() - start_time))
    end
end

if not moduleMode then
    local expr = ({...})[1] or qerror('usage: "devel/walk-structures expression"')
    walk(expr, eval(expr))
end
