-- Text entry/backspace tests

gui = require 'gui'
dlg = require 'gui.dialogs'

key_offset = df.interface_key.STRING_A000
VERSION = 1

function text(line, text) dfhack.screen.paintString(COLOR_WHITE, 2, line, text) end

bs_tests = {
    function(k)
        return k == 0
    end,
    function(k)
        return k == 127
    end,
    function(k)
        return k == 0 or k == 127
    end,
}
ch_tests = {
    function(k)
        return k >= 32 and k <= 126
    end,
    function(k)
        return k >= 32 and k <= 255
    end,
    function(k)
        return k >= 32 and k <= 255 and k ~= 127
    end,
}

viewscreen_test_backspace = defclass(viewscreen_test_backspace, gui.Screen)

function viewscreen_test_backspace:init()
    self.tests = {}
    self.test_id = 0
    self.entry = ''
    self.completed = false
    for c, ch_test in pairs(ch_tests) do
        for b, bs_test in pairs(bs_tests) do
            table.insert(self.tests,
                {bs = bs_test, ch = ch_test, id = ' (' .. c .. ',' .. b .. ')'})
        end
    end
    self:next_test()
end

function viewscreen_test_backspace:next_test()
    self.test_id = self.test_id + 1
    if self.test_id > #self.tests then
        self.completed = true
        return false
    end
    self.cur_test = self.tests[self.test_id]
    self.entry = '>'
    return true
end

function viewscreen_test_backspace:onRender()
    dfhack.screen.clear()
    if self.completed then
        text(0, "Completed! " .. VERSION)
        for i, test in pairs(self.tests) do
            text(i, 'Test ' .. i .. test.id .. ' : ' .. test.result)
        end
        text(#self.tests + 2, "Alt-Q: Exit")
        return
    end
    text(2, "Test ID: " .. self.test_id .. self.cur_test.id)
    text(3, 'Alt-C: Reset this test')
    text(5, "Entry: " .. self.entry)
end

function viewscreen_test_backspace:onInput(keys)
    if self.completed then
        if keys.CUSTOM_ALT_Q then
            self:dismiss()
        end
        return
    end
    if keys.CUSTOM_ALT_Q then
        self:dismiss()
    elseif keys.SELECT then
        self.cur_test.result = self.entry
        self:next_test()
    elseif keys.CUSTOM_ALT_C then
        self.entry = '>'
    else
        for k, _ in pairs(keys) do
            local keycode = df.interface_key[k]
            if keycode ~= nil then
                keycode = keycode - key_offset
                if self.cur_test.bs(keycode) and #self.entry > 0 then
                    self.entry = self.entry:sub(1, #self.entry - 1)
                elseif self.cur_test.ch(keycode) then
                    self.entry = self.entry .. string.char(keycode)
                end
            end
        end
    end
end

viewscreen_test_backspace():show()
    dlg.showMessage('Instructions', [[
Type A-Backspace-Enter repeatedly. A macro should work,
although low MACRO_MS values have not been tested.
(Enter to close)]])
