--[[ embark_site (by Lethosor)
Allows embarking in disabled locations (e.g. too small or on an existing site)

Note that this script is not yet complete (although it's mostly functional).
Notably, there is currently no GUI integration - you can either run it from the
console or add keybindings.

Some example keybindings:
keybinding add Alt-N@choose_start_site "embark_site nano"
keybinding add Alt-E@choose_start_site "embark_site here"
]]

usage = [[Usage:
embark_site nano enable
embark_site nano disable
embark_site anywhere enable
embark_site anywhere disable
]]

local gui = require 'gui'
local widgets = require 'gui.widgets'
local eventful = require 'plugins.eventful'

prev_state = ''

if enabled == nil then
    enabled = {
        anywhere = false,
        nano = false,
    }
end

function tableIndex(tbl, value)
    for k, v in pairs(tbl) do
        if tbl[k] == value then
            return k
        end
    end
    return nil
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

embark_settings = gui.FramedScreen{
    frame_style = gui.GREY_LINE_FRAME,
    frame_title = 'Embark settings',
    frame_width = 32,
    frame_height = 8,
    frame_inset = 1,
}
function embark_settings:onRenderBody(body)
    body:string('a', COLOR_LIGHTGREEN)
    body:string(': Embark anywhere ', COLOR_WHITE)
    if enabled.anywhere then
        body:string('(enabled)', COLOR_WHITE)
    else
        body:string('(disabled)', COLOR_WHITE)
    end
    body:newline()
    body:string('n', COLOR_LIGHTGREEN)
    body:string(': Nano embark ', COLOR_WHITE)
    if enabled.nano then
        body:string('(enabled)', COLOR_WHITE)
    else
        body:string('(disabled)', COLOR_WHITE)
    end
    body:seek(0, 7)
    body:string('Esc', COLOR_LIGHTGREEN)
    body:string(': Done', COLOR_WHITE)
end
function embark_settings:onInput(keys)
    if keys.CUSTOM_A then
        enabled.anywhere = not enabled.anywhere
    end
    if keys.CUSTOM_N then
        enabled.nano = not enabled.nano
    end
    if keys.LEAVESCREEN then
        self:dismiss()
    end
end

embark_overlay = defclass(embark_overlay, gui.Screen)
function embark_overlay:init()
    self.embark_label = widgets.Label{text="-", frame={b=1, l=20}, text_pen={fg=COLOR_WHITE}}
    self.enabled_label = widgets.Label{text="-", frame={b=4, l=1}, text_pen={fg=COLOR_LIGHTMAGENTA}}
    self:addviews{
        widgets.Panel{
            subviews = {
                self.embark_label,
                self.enabled_label,
                widgets.Label{text="Esc", frame={b=5, l=52}, text_pen={fg=COLOR_LIGHTRED}},
                widgets.Label{text=": Disable", frame={b=5, l=52+3}, text_pen={fg=COLOR_WHITE}},
                widgets.Label{text="Alt+e", frame={b=4, l=52}, text_pen={fg=COLOR_LIGHTRED}},
                widgets.Label{text=": Options", frame={b=4, l=52+5}, text_pen={fg=COLOR_WHITE}},
            }
        }
    }
end
function embark_overlay:onRender()
    self._native.parent:render()
    if enabled.anywhere then
        self.embark_label:setText(': Embark!')
    else
        self.embark_label:setText('')
    end
    enabled_text = 'Enabled: '
    if enabled.anywhere then
        enabled_text = enabled_text .. 'Embark anywhere'
    end
    if enabled.nano then
        if enabled.anywhere then enabled_text = enabled_text .. ', ' end
        enabled_text = enabled_text .. 'Nano embark'
    end
    if enabled_text == 'Enabled: ' then
        enabled_text = ''
    end
    self.enabled_label:setText(enabled_text)
    self:render()
end

function embark_overlay:onInput(keys)
    local interceptKeys = {"CUSTOM_ALT_E"}
    if enabled.anywhere then
        table.insert(interceptKeys, "SETUP_EMBARK")
    end
    if keys.LEAVESCREEN then
        prev_state = 'embark_overlay'
        self:dismiss()
        self:sendInputToParent('LEAVESCREEN')
        return
    end
    for name, _ in pairs(keys) do
        if tableIndex(interceptKeys, name) ~= nil then
            print("Intercepting " .. name)
            handle_key(name)
        else
            self:sendInputToParent(name)
        end
    end
end

function onStateChange(...)
    if dfhack.gui.getCurFocus() ~= 'choose_start_site' or prev_state == 'embark_overlay' then
        prev_state = ''
        return
    end
    prev_state = ''
    print('embark_site: Creating overlay')
    overlay = embark_overlay()
    overlay:show()
end
dfhack.onStateChange.embark_site = onStateChange

function handle_key(key)
    scr = dfhack.gui.getCurViewscreen().parent
    if key == "SETUP_EMBARK" then
        --overlay:dismiss()
        scr.in_embark_normal = true
    elseif key == "CUSTOM_ALT_E" then
        embark_settings:show()
    end
end

function main(...)
    args = {...}
    if #args == 2 then
        feature = args[1]
        state = args[2]
        if enabled[feature] ~= nil then
            if state == 'enable' then
                enabled[feature] = true
            elseif state == 'disable' then
                enabled[feature] = false
            else
                print('Usage: embark_site ' .. feature .. ' (enable/disable)')
            end
        else
            print('Invalid: ' .. args[1])
        end
    elseif #args == 0 then
        for feature, state in pairs(enabled) do
            print(feature .. ':' .. string.rep(' ', 10 - #feature) .. (state and 'enabled' or 'disabled'))
        end
    elseif args[1] == 'init' then
        -- pass
    else
        print(usage)
    end
end
main(...)
