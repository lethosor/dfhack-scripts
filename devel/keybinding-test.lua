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

function modDesc(n, trailing_dash, default)
    local mods = ''
    if bit32.band(n, DFH_MOD_SHIFT) ~= 0 then mods = mods .. 'Shift-' end
    if bit32.band(n, DFH_MOD_ALT) ~= 0   then mods = mods .. 'Alt-'   end
    if bit32.band(n, DFH_MOD_CTRL) ~= 0  then mods = mods .. 'Ctrl-'  end
    if not trailing_dash then
        mods = mods:gsub('-$', '')
    end
    if #mods == 0 and default then
        return tostring(default)
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
            self:export()
            return
        end
    end
    if not self.triggered[self.want_modstate] then
        self.triggered[self.want_modstate] = {count=0}
        for n, ch in letterChars() do
            self.triggered[self.want_modstate][ch] = false
        end
    end
end

function Scr:countTriggered(key)
    local t = self.triggered[key]
    local count = 0
    t.count = nil
    for _, v in pairs(t) do
        if v then
            count = count + 1
        end
    end
    t.count = count
end

function Scr:trigger(ch)
    if dfhack.internal.getModstate() ~= self.want_modstate then
        self.flash_timer = 4
        return
    end
    self.triggered[self.want_modstate][ch] = true
    self:countTriggered(self.want_modstate)
    for _, ok in pairs(self.triggered[self.want_modstate]) do
        if ok == false then return end
    end
    self:next()
end

function Scr:export()
    self.summary = {}
    for i = 0, 7 do
        local msg = modDesc(i, false, 'none') .. ': '
        local failed = {}
        local color
        for n, ch in letterChars() do
            if not self.triggered[i][ch] then
                table.insert(failed, ch)
            end
        end
        if #failed > 0 then
            msg = msg .. tostring(#failed) .. ' failed: ' .. table.concat(failed, ', ')
            color = COLOR_LIGHTRED
        else
            msg = msg .. 'all passed'
            color = COLOR_LIGHTGREEN
        end
        table.insert(self.summary, {msg, color})
        dfhack.color(color)
        dfhack.print(msg .. '\n')
        dfhack.color()
        io.stdout:write(msg .. '\n')
    end
    io.stdout:flush()
end

function Scr:onRenderBody(p)
    self.flash_timer = math.max(0, (self.flash_timer or 0) - 1)
    dfhack.screen.clear()
    if self.done then
        p:string('Test complete! Press any key to exit'):newline():newline()
        if self.summary then
            for _, row in pairs(self.summary) do
                p:string(table.unpack(row)):newline()
            end
            p:newline():string('Also logged to DFHack console and stdout.log')
        end
        return
    end
    p:string('Press ' .. modDesc(self.want_modstate, false, 'no modifiers'),
        dfhack.internal.getModstate() == self.want_modstate and COLOR_LIGHTGREEN or
            (self.flash_timer % 2 == 0 and COLOR_LIGHTRED or COLOR_YELLOW)
    ):newline():string(('group %i/8, %i/26 bindings (%.1f%%)'):format(
        self.want_modstate + 1,
        self.triggered[self.want_modstate].count,
        self.triggered[self.want_modstate].count / 26 * 100
    )):newline()
    for n, ch in letterChars() do
        p:string(ch, self.triggered[self.want_modstate][ch] and COLOR_LIGHTGREEN or COLOR_DARKGREY):string(' ')
    end
    p:newline():newline()
    p:key('CURSOR_LEFT'):key('CURSOR_RIGHT'):string(' (cursor left/right): Navigate'):newline()
    p:key('LEAVESCREEN_ALL'):string(': Exit'):newline():newline()
    if self.want_modstate == DFH_MOD_CTRL then
        p:pen(COLOR_YELLOW)
        p:string('Warning: macro bindings may be triggered:'):newline()
            :key('RECORD_MACRO'):string(', ')
            :key('PLAY_MACRO'):string(', ')
            :key('SAVE_MACRO'):string(', ')
            :key('LOAD_MACRO')
    end
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
