-- A replacement for the options menu

gui = require 'gui'

if enabled == nil then
    enabled = false
    instance = nil
    prev_focus = nil
end

OPTIONS = {
    {title = 'Back', native = true, native_id = 0},
    {title = 'Key Bindings', native = true, native_id = 2},
    {title = 'Music and sound', native = true, native_id = 4},
}

function inRegion(point, bounds)
    
end

custom_optionst = defclass(custom_optionst, gui.Screen)
custom_optionst.focus_path = 'custom_options'

function custom_optionst:init()
    self.margin_x = 10
    self.margin_y = 2
    self.options = {}
    for i, opt in pairs(OPTIONS) do
        table.insert(self.options, i)
    end
    self.sel_idx = 1
end

function custom_optionst:onRender()
    local dimx, dimy = dfhack.screen.getWindowSize()
    dfhack.screen.clear()
    dfhack.screen.paintString(COLOR_WHITE, self.margin_x, self.margin_y, "Dwarf Fortress: Options")
    dfhack.screen.paintString(COLOR_GREY, dimx - 8, dimy - 1, "DFHack")
    for _, id in pairs(self.options) do
        local opt = OPTIONS[id]
        local x = self.margin_x + 2
        local y = self.margin_y + 2 + id
        local fg = (id == self.sel_idx and COLOR_WHITE) or COLOR_LIGHTGRAY
        local bg = (inRegion({df.global.gps.mouse_x, df.global.gps.mouse_y},
                    {x, y, x + #opt.title, y}) and COLOR_BLUE) or COLOR_BLACK
        dfhack.screen.paintString({fg = fg, bg = bg}, x, y, opt.title)
    end
end

function custom_optionst:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss_all()
    elseif keys.STANDARDSCROLL_UP then
        self:scroll(-1)
    elseif keys.STANDARDSCROLL_DOWN then
        self:scroll(1)
    end
end

function custom_optionst:scroll(delta)
    self.sel_idx = self.sel_idx + delta
    if self.sel_idx > #self.options then self.sel_idx = 1 end
    if self.sel_idx < 1 then self.sel_idx = #self.options end
end

function custom_optionst:dismiss_all()
    dfhack.screen.dismiss(self)
    dfhack.screen.dismiss(self._native.parent)
    instance = nil
end

function show_screen()
    instance = custom_optionst()
    instance:show()
end

function hide_screen()
    if instance ~= nil then
        instance:dismiss()
        instance = nil
    end
end

dfhack.onStateChange[_ENV] = function(state)
    if dfhack.gui.getCurFocus() == 'option' and prev_focus ~= 'dfhack/lua/custom_options'
        and enabled then
        show_screen()
    end
    prev_focus = dfhack.gui.getCurFocus()
end

args = {...}
if #args == 1 then
    if args[1] == 'enable' then
        enabled = true
        if dfhack.gui.getCurFocus() == 'option' then
            show_screen()
        end
    elseif args[1] == 'disable' then
        enabled = false
        hide_screen()
    end
end
