-- scan for structs with a specific size
size = tonumber(({...})[1]) or qerror('Invalid number')
list = {}
for n, t in pairs(df) do
    if df.sizeof(t) == size then
        table.insert(list, n)
    end
end
table.sort(list)
for _, n in pairs(list) do
    print(n)
end
