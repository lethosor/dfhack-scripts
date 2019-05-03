--@module=true
ft = {}

function ft.__band(f, g)
    return function(...)
        return f(...) and g(...)
    end
end

function ft.__bor(f, g)
    return function(...)
        return f(...) or g(...)
    end
end

function ft.__bnot(f)
    return function(...)
        return not f(...)
    end
end

function ft.__concat(f, g)
    return function(...)
        return f(g(...))
    end
end

debug.setmetatable(debug.setmetatable, ft)

for _, t in pairs(df) do
    if t._kind ~= 'global' then
        debug.getmetatable(t).__call = function(self, obj)
            local inst = t:new()
            pcall(inst.assign, inst, obj or {})
            return inst
        end
    end
end

