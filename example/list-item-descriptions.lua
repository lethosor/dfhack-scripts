descriptions = {}
function load_descriptions(file)
    if dfhack.findScript(file) then
        for k, v in pairs(dfhack.script_environment(file).descriptions) do
            descriptions[k] = v
        end
    end
end
load_descriptions('example/item-descriptions')
load_descriptions('example/more-item-descriptions')
for k, v in pairs(descriptions) do
    print(k)
    for _, line in pairs(v) do print('  ' .. line) end
end
