-- test keybinding recognition interactively
gui = require 'gui'

DFH_MOD_SHIFT = 1
DFH_MOD_CTRL = 2
DFH_MOD_ALT = 4

function letterChars()
    local i = string.byte('A') - 1
    return function()
        i = i + 1
        if i <= string.byte('Z') then
            return i, string.char(i)
        end
    end
end

function modDesc(n, trailing_dash)
    local mods = ''
    if bit32.band(n, DFH_MOD_SHIFT) ~= 0 then mods = mods .. 'Shift-' end
    if bit32.band(n, DFH_MOD_ALT) ~= 0   then mods = mods .. 'Alt-'   end
    if bit32.band(n, DFH_MOD_CTRL) ~= 0  then mods = mods .. 'Ctrl-'  end
    if not trailing_dash then
        mods = mods:gsub('-$', '')
    end
    return mods
end

Scr = defclass(Scr, gui.FramedScreen)
Scr.focus_path = 'keybinding-test'
function Scr:init()
    self.triggered = {}
    self:next()
    instance = self
end

function Scr:next()
    if not self.want_modstate then
        self.want_modstate = 0
    else
        self.want_modstate = math.min(8, self.want_modstate + 1)
        if self.want_modstate >= 8 then
            self.done = true
            return
        end
    end
    if not self.triggered[self.want_modstate] then
        self.triggered[self.want_modstate] = {}
        for n, ch in letterChars() do
            self.triggered[self.want_modstate][ch] = false
        end
    end
end

function Scr:trigger(ch)
    if dfhack.internal.getModstate() ~= self.want_modstate then
        self.flash_timer = 3
        return
    end
    self.triggered[self.want_modstate][ch] = true
    for _, ok in pairs(self.triggered[self.want_modstate]) do
        if not ok then return end
    end
    self:next()
end

function Scr:onRenderBody(p)
    dfhack.screen.clear()
    if self.done then
        p:string('Test complete! Press any key to exit')
        return
    end
    local desc = self.want_modstate ~= 0 and modDesc(self.want_modstate) or 'no modifiers'
    p:string(('Press %s (%i/8)'):format(desc, self.want_modstate + 1),
        dfhack.internal.getModstate() == self.want_modstate and COLOR_LIGHTGREEN or COLOR_LIGHTRED
    ):newline()
    for n, ch in letterChars() do
        p:string(ch, self.triggered[self.want_modstate][ch] and COLOR_LIGHTGREEN or COLOR_DARKGREY):string(' ')
    end
    p:newline():newline()
    p:key('LEAVESCREEN_ALL'):string(': Exit'):newline():newline()
    p:pen(COLOR_YELLOW)
    p:string('Warning: Conflicts may occur with macro bindings:'):newline()
        :key('RECORD_MACRO'):string(', ')
        :key('PLAY_MACRO'):string(', ')
        :key('SAVE_MACRO'):string(', ')
        :key('LOAD_MACRO')
end

function Scr:onInput(keys)
    if keys.CURSOR_LEFT then
        self.want_modstate = math.max(0, self.want_modstate - 1)
        self.done = false
    elseif self.done or keys.LEAVESCREEN_ALL then
        self:dismiss()
    elseif keys.CURSOR_RIGHT then
        self:next()
    end
end

function Scr:onDismiss()
    instance = nil
end

args = {...}
if args[1] == 'trigger' then
    if not instance then qerror('keybinding-test: screen not displayed!') end
    instance:trigger(args[2])
    return
end

for ch = string.byte('A'), string.byte('Z') do
    for i = 0, 7 do
        dfhack.run_command{'keybinding', 'add',
            modDesc(i, true) .. string.char(ch) .. '@dfhack/lua/keybinding-test',
            'devel/keybinding-test trigger ' .. string.char(ch)
        }
    end
end
Scr():show()
