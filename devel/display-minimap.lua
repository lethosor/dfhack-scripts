-- Displays the minimap contents in the console

local minimap = df.global.ui_sidebar_menus.minimap

for j = 0, 22 do
    for i = 0, 22 do
        dfhack.color(minimap.tile_fg[i][j] + (8 * minimap.tile_bold[i][j]))
        dfhack.print(dfhack.df2utf(string.char(minimap.tile[i][j])))
    end
    print('')
end

dfhack.color()
