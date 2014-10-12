-- A replacement for the fortress mode trade screen

gui = require 'gui'

if enabled == nil then
    enabled = false
    instance = nil
    prev_focus = nil
end

function DrawBorder(title)
    local dimx, dimy = dfhack.screen.getWindowSize()
    dimx = dimx - 1
    dimy = dimy - 1
    local border_pen = {ch = '\xDB', fg = COLOR_DARKGREY}
    local title_pen = {fg = COLOR_BLACK, bg = COLOR_GREY}
    local signature_pen = {fg = COLOR_BLACK, bg = COLOR_DARKGREY}
    for x = 0, dimx do
        dfhack.screen.paintTile(border_pen, x, 0)
        dfhack.screen.paintTile(border_pen, x, dimy)
    end
    for y = 0, dimy do
        dfhack.screen.paintTile(border_pen, 0, y)
        dfhack.screen.paintTile(border_pen, dimx, y)
    end
    dfhack.screen.paintString(signature_pen, dimx - 7, dimy, "DFHack")
    dfhack.screen.paintString(title_pen, math.floor((dimx + 1 - #title) / 2), 0, title)
end

function OutputString(fg, x, y, text)
    dfhack.screen.paintString({fg=fg}, x, y, text)
end

custom_tradegoodsst = defclass(custom_tradegoodsst, gui.Screen)
custom_tradegoodsst.focus_path = 'custom_trade'

function custom_tradegoodsst:init()
end

function custom_tradegoodsst:onRender()
    local dimx, dimy = dfhack.screen.getWindowSize()
    local parent = self._native.parent
    dfhack.screen.clear()
    if parent.is_unloading then
        DrawBorder(parent.title)
        OutputString(COLOR_YELLOW, 2, 2,
            parent.merchant_name .. ": My apologies, but we're still unloading. " ..
            "We'll be ready soon!")
    else
        self._native.parent:render()
    end
end

function custom_tradegoodsst:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss_all()
        return
    end
    --self._native.parent:onInput(keys)
end

function custom_tradegoodsst:dismiss_all()
    dfhack.screen.dismiss(self)
    dfhack.screen.dismiss(self._native.parent)
    instance = nil
end

function show_screen()
    instance = custom_tradegoodsst()
    instance:show()
end

function hide_screen()
    if instance ~= nil then
        instance:dismiss()
        instance = nil
    end
end

dfhack.onStateChange[_ENV] = function(state)
    if dfhack.gui.getCurFocus():find('tradegoods') == 1 and prev_focus ~= 'dfhack/lua/custom_trade'
        and enabled then
        show_screen()
    end
    prev_focus = dfhack.gui.getCurFocus()
end

args = {...}
if #args == 1 then
    if args[1] == 'enable' then
        enabled = true
        if dfhack.gui.getCurFocus():find('tradegoods') == 1 then
            show_screen()
        end
    elseif args[1] == 'disable' then
        enabled = false
        hide_screen()
    end
end
