
function dump(gv, gk, indent)
    if tostring(gk):sub(1, 5) == 'anon_' then return end
    if #indent > 6 then return end
    if type(gv) == 'userdata' then
        print(indent .. tostring(gk) .. ':')
        for k, v in pairs(gv) do
            dump(v, k, indent .. '  ')
        end
    else
        print(indent .. gk .. '=' .. tostring(gv))
    end
end

for k, v in pairs(df.global) do
    if k ~= 'world' and k ~= 'gview' and k ~= 'enabler' then
        dump(v, k, '')
    end
end
