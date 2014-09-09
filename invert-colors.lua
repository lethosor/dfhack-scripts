-- Inverts DF's color scheme while DF is running
--[[ By Lethosor
Last tested on 0.40.11-r1
]]

for i = 0,15 do
    for j = 0,2 do
    	df.global.enabler.ccolor[i][j] = 1-df.global.enabler.ccolor[i][j]
    end
end
df.global.gps.force_full_display_count = 1