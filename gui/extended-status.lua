-- Adds more z-status subpages
--@ enable = true
--[[=begin

gui/extended-status
===================
Adds more subpages to the ``z`` status screen.

Usage::

    gui/extended-status enable|disable|help|subpage_names
    enable|disable gui/extended-status

=end]]

gui = require 'gui'
dialogs = require 'gui.dialogs'
gps = df.global.gps
world = df.global.world

if enabled == nil then
    enabled = false
end

subpages = {
    {key = 'CUSTOM_B', desc = 'Bedrooms', screen = 'bedroom_list'},
}

function derror(msg)
    dialogs.showMessage('Error', msg, COLOR_LIGHTRED)
end

subpage_classes = {}
subpage_names = {}
function defsubpage(name)
    if subpage_classes[name] then
        error('Duplicate definition of subpage ' .. name)
    end
    local class = defclass(_ENV[name], gui.FramedScreen)
    class.ATTRS = {
        focus_path = 'extended_status/' .. name,
        frame_inset = 1,
    }
    subpage_classes[name] = class
    table.insert(subpage_names, name)
    _ENV[name] = class
end

status_overlay = defclass(status_overlay, gui.Screen)
status_overlay.ATTRS = {
    focus_path = 'status_overlay'
}

function status_overlay:init()
    self.show_menu = false
end

function status_overlay:onRender()
    local parent = self._native.parent
    parent:render()
    if self.show_menu then
        dfhack.screen.paintString({fg=COLOR_BLACK, bg=COLOR_DARKGREY},
            gps.dimx - 8, gps.dimy - 1, "DFHack")
        local p = gui.Painter.new_xy(2, 2, gps.dimx - 3, gps.dimy - 3)
        p:key_pen(COLOR_LIGHTRED)
        dfhack.screen.fillRect({}, 1, 1, gps.dimx - 2, gps.dimy - 2)
        for i, opt in pairs(subpages) do
            p:key(opt.key):string(': ' .. opt.desc):newline()
        end
        p:seek(0, p.height - 1):key('LEAVESCREEN'):string(': Back')
    else
        local p = gui.Painter.new_xy(1, 1, gps.dimx - 2, 3)
        p:key_pen(COLOR_LIGHTRED)
        p:seek(3, 2):key('CUSTOM_X'):string(': Additional options (DFHack)')
    end
end

function status_overlay:onInput(keys)
    local parent = self._native.parent
    if self.show_menu then
        if keys.LEAVESCREEN then
            self.show_menu = false
        end
        for _, opt in pairs(subpages) do
            if keys[opt.key] then
                local class = _ENV[opt.screen]
                if class then
                    class():show()
                else
                    derror('Undefined screen: ' .. opt.screen)
                end
                break
            end
        end
    else
        if keys.CUSTOM_X then
            self.show_menu = true
            return
        end
        if keys.LEAVESCREEN then
            self:dismiss()
        end
        gui.simulateInput(parent, keys)
    end
end

defsubpage('bedroom_list')
bedroom_list.ATTRS.frame_title = 'Bedroom status'

function bedroom_list:init()
    self.data = {
        {'Beds', 'beds'},
        {'Built beds', 'bbeds'},
        {'Unbuilt beds', 'ubeds'},
        {'Bedrooms', 'brooms'},
        {'Owned Bedrooms', 'obrooms'},
        {'Unowned Bedrooms', 'ubrooms'},
        {'Units', 'units'},
        {'Units with bedrooms', 'uwith'},
        {'Units without bedrooms', 'uwithout'}
    }
    for _, d in pairs(self.data) do d.list = {} end
    local function add(key, item)
        for _, d in pairs(self.data) do
            if d[2] == key then
                table.insert(d.list, item)
            end
        end
    end
    for _, u in pairs(world.units.active) do
        if dfhack.units.isCitizen(u) then
            add('units', u)
            local has_bed = false
            for _, b in pairs(u.owned_buildings) do
                if df.building_bedst:is_instance(b) then
                    has_bed = true
                end
            end
            if has_bed then
                add('uwith', u)
            else
                add('uwithout', u)
            end
        end
    end
    for _, bed in pairs(world.items.other.BED) do
        add('beds', bed)
        add(bed.flags.in_building and 'bbeds' or 'ubeds', bed)
    end
    for _, building in pairs(world.buildings.other.BED) do
        if building.is_room then
            add('brooms', building)
            add(building.owner and 'obrooms' or 'ubrooms', building)
        end
    end
end

function bedroom_list:onRenderBody(p)
    for _, item in pairs(self.data) do
        p:string(item[1]):string(': '):string(tostring(#item.list)):newline()
    end
end

function bedroom_list:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    end
end

screen_history = screen_history or {'', ''}
dfhack.onStateChange['gui/extended-status'] = function(e)
    table.insert(screen_history, dfhack.gui.getCurFocus())
    table.remove(screen_history, 1)
    if enabled and screen_history[2] == 'overallstatus' and screen_history[1]:sub(1, 6) ~= 'dfhack' then
        status_overlay():show()
    end
end

args = {...}
if dfhack_flags and dfhack_flags.enable then
    args = {dfhack_flags.enable_state and 'enable' or 'disable'}
end
if args[1] == 'enable' then
    enabled = true
elseif args[1] == 'disable' then
    enabled = false
elseif subpage_classes[args[1]] then
    subpage_classes[args[1]]():show()
else
    print((([[Usage:
    gui/extended-status enable|disable|help|subpage_names
    enable|disable gui/extended-status
    ]]):gsub('subpage_names', table.concat(subpage_names, '|'))))
end
