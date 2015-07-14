-- test display colors
gui = require 'gui'

color_test = defclass(color_test, gui.FramedScreen)
color_test.ATTRS = {
    ch = 'X'
}

function color_test:onRenderBody(p)
    p:seek(0, 3)
    for fg = 0, 15 do
        p:newline(4)
        for bg = 0, 15 do
            p:string(self.ch, {fg=fg, bg=bg})
        end
    end
    for n = 0, 15 do
        s = tostring(n)
        if #s == 1 then s = ' ' .. s end
        p:seek(1, n + 4):string(s)
        p:seek(n + 4, 1):string(s:sub(1, 1)):newline(n + 4):string(s:sub(2, 2))
    end
end

function color_test:onInput(keys)
    if keys.SELECT or keys.LEAVESCREEN then
        self:dismiss()
    end
    for k in pairs(keys) do
        ch = dfhack.screen.keyToChar(df.interface_key[k] or df.interface_key.NONE)
        if ch then
            self.ch = string.char(ch)
        end
    end
end

color_test():show()
