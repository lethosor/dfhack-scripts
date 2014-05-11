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

embark_overlay = defclass(embark_overlay, gui.Screen)
function embark_overlay:init()
    self.embark_label = widgets.Label{text="-", frame={b=1, l=20}, text_pen={fg=COLOR_WHITE}}
    self.enabled_label = widgets.Label{text="-", frame={b=4, l=1}, text_pen={fg=COLOR_LIGHTMAGENTA}}
    self:addviews{
        widgets.Panel{
            subviews = {
                self.embark_label,
                self.enabled_label,
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
    self.enabled_label:setText('Enabled')
    self:render()
end

function embark_overlay:onInput(keys)
    local interceptKeys = {"SETUP_EMBARK"}
    if keys.LEAVESCREEN then
        prev_state = 'embark_overlay'
        self:dismiss()
        self:sendInputToParent('LEAVESCREEN')
        return
    end
    for name, _ in pairs(keys) do
        if tableIndex(interceptKeys, name) ~= nil then
            print("Intercepting " .. name)
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
