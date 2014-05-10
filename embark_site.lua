--[[ embark_site (by Lethosor)
Allows embarking in disabled locations (e.g. too small or on an existing site)

Note that this script is not yet complete (although it's mostly functional).
Notably, there is currently no GUI integration - you can either run it from the
console or add keybindings.

Some example keybindings:
keybinding add Alt-N@choose_start_site "embark_site nano"
keybinding add Alt-E@choose_start_site "embark_site here"
]]

usage = [[embark_site
* To set embark size to 1x1:
 > embark_site nano
  - note that this can be increased to 2x1 or 1x2 with the normal UMKH keys
* To force an embark on the current location, regardless of warnings:
 > embark_site here
* To set coordinates manually:
 > embark_site {x1} {y1} {x2} {y2}
  - "1 1" = upper left, "16 16" = bottom right
* To set size manually (using the upper left corner:
 > embark_site size {width} {height}
* To display coordinates:
 > embark_site
]]

args = {...}
scr = dfhack.gui.getCurViewscreen()

function set_embark_pos(coords)
    if coords[1] > coords[3] then coords[1], coords[3] = coords[3], coords[1] end
    if coords[2] > coords[4] then coords[2], coords[4] = coords[4], coords[2] end
    scr.embark_pos_min.x = coords[1]
    scr.embark_pos_min.y = coords[2]
    scr.embark_pos_max.x = coords[3]
    scr.embark_pos_max.y = coords[4]
end

function set_embark_size(width, height)
    width, height = tonumber(width), tonumber(height)
    if width == nil or height == nil then
        dfhack.printerr('Embark size requires width and height')
        return false
    end
    scr.embark_pos_max.x = math.min(15, scr.embark_pos_min.x + width - 1)
    scr.embark_pos_max.y = math.min(15, scr.embark_pos_min.y + height - 1)
    scr.embark_pos_min.x = math.max(0, scr.embark_pos_max.x - width + 1)
    scr.embark_pos_min.y = math.max(0, scr.embark_pos_max.y - height + 1)
end


function get_embark_pos()
    return {scr.embark_pos_min.x + 1, scr.embark_pos_min.y + 1, scr.embark_pos_max.x + 1, scr.embark_pos_max.y + 1}
end

function main()
    if #args == 4 then
        -- set coords
        coords = {}
        for i = 1, 4 do
            n = tonumber(args[i])
            if n == nil then
                dfhack.printerr('Argument '..i..' ("'..args[i]..'") is not a number')
                return
            end
            -- Boundary checking and make origin (1,1) instead of (0,0)
            coords[i] = math.min(15, math.max(0, n - 1))
        end
        set_embark_pos(coords)
    elseif #args == 0 then
        -- get coords
        print(table.concat(get_embark_pos(), ', '))
    elseif args[1] == 'size' then
        -- set size
        set_embark_size(args[2], args[3])
    elseif args[1] == 'nano' then
        -- set size to 1x1
        scr.embark_pos_max.x = scr.embark_pos_min.x
        scr.embark_pos_max.y = scr.embark_pos_min.y
    elseif args[1] == 'here' then
        -- force embark
        print('Forcing embark here (press [Enter] in DF to accept)')
        dfhack.gui.getCurViewscreen().in_embark_normal = true
    else
        dfhack.printerr('Invalid argument(s). "embark_site help" for help')
    end
end

function check_screen()
    if not pcall(get_embark_pos) then
        dfhack.printerr('Must be called on the embark screen!')
        return false
    end
    return true
end
if #args and args[1] == 'help' then
    print(usage)
    return
end
if check_screen() then main() end