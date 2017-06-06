dims = require('gui.dwarfmode').getPanelLayout()
for _, k in pairs{'area_pos', 'menu_pos', 'menu_forced', 'area_map', 'map', 'menu'} do
    print('\n' .. k)
    if type(dims[k]) == 'table' then
        local keys = {}
        for k2 in pairs(dims[k]) do
            table.insert(keys, k2)
        end
        table.sort(keys)
        for _, k2 in ipairs(keys) do
            printall{[k2] = dims[k][k2]}
        end
    else
        print(dims[k])
    end
end
