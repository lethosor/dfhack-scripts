tiles = {
    _open = {COLOR_RESET, ' '},
    trunk = {COLOR_BROWN, 'O'},
    thick_branches_1 = {COLOR_BROWN, '-'},
    thick_branches_2 = {COLOR_BROWN, '|'},
    thick_branches_3 = {COLOR_BROWN, '-'},
    thick_branches_4 = {COLOR_BROWN, '|'},
    branches = {COLOR_GREEN, string.char(172)},
    twigs = {COLOR_GREEN, ';'},
    blocked = {COLOR_RED, '.'},
}

local plant = dfhack.gui.getSelectedPlant(true) or qerror('No plant selected')
if not plant.tree_info then
    qerror('Not a tree')
end

local info = plant.tree_info
printall(info)
for z = 0, info.body_height - 1 do
    print('\nZ = ' .. z)
    for y = 0, info.dim_y - 1 do
        for x = 0, info.dim_x - 1 do
            local tile = info.body[z]:_displace(y * info.dim_x + x)
            local tile_type = '_open'
            for key, value in pairs(tile) do
                if value then
                    tile_type = key
                    break
                end
            end
            dfhack.color(tiles[tile_type][1])
            dfhack.print(dfhack.df2console(tiles[tile_type][2]))
        end
        dfhack.print('\n')
    end
    dfhack.color()
end
