-- Inverts DF's color scheme while DF is running

VERSION = '0.2'

function usage()
    print([[Usage:
    invert-colors:           Invert display colors
    invert-colors no-redraw: Invert display colors without refreshing display
    invert-colors help:      Display this help
v]] .. VERSION)
end

function invert()
    for i = 0,15 do
        for j = 0,2 do
            df.global.enabler.ccolor[i][j] = 1-df.global.enabler.ccolor[i][j]
        end
    end
end
args = {}
for k, v in pairs({...}) do
    args[v] = true
end

if args['help'] or args['version'] then
    usage()
else
    invert()
    if not args['no-redraw'] then
        df.global.gps.force_full_display_count = 1
    end
end
