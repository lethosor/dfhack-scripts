-- load-screen

local gui = require 'gui'
local widgets = require 'gui.widgets'

function string:split(sep)
    local sep, fields = sep or " ", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

load_screen = defclass(load_screen, gui.Screen)

function load_screen:init()
    self.saves = nil
    self.sel_idx = 1
    self.opts = {
        backups = false,
        filter = '',
    }
end

function load_screen:is_backup(folder_name)
    parts = folder_name:split('-')
    if #parts >= 3 and
        (string.find('spr,sum,aut,win', parts[#parts - 1])) and
        (parts[#parts]:match('^%d+$')) then
        return true
    else
        return false
    end
end

function load_screen:init_saves()
    self.saves = {}
    parent_saves = self._native.parent.saves
    for i = 0, #parent_saves - 1 do
        table.insert(self.saves, parent_saves[i])
    end
end

function load_screen:get_saves()
    if not self.saves then self:init_saves() end
    saves = {}
    for i = 1, #self.saves do
        save = self.saves[i]
        if (self:is_backup(save.folder_name) and not self.opts.backups) or
            (#self.opts.filter and not save.folder_name:lower():find(self.opts.filter:lower())) then
            --pass
        else
            table.insert(saves, save)
        end
    end
    return saves
end

function load_screen:onRender()
    pen = {ch=' ', fg=COLOR_GREY}
    saves = self:get_saves()
    dfhack.screen.clear()
    for i = 1, #saves do
        save = saves[i]
        pen.fg = (i == self.sel_idx and COLOR_WHITE) or COLOR_GREY
        pen.bg = (i == self.sel_idx and COLOR_BLUE) or COLOR_BLACK
        dfhack.screen.paintString(pen, 2, i+1, save.folder_name)
    end
end

function load_screen:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
        dfhack.screen.dismiss(self._native.parent)
    elseif keys.CURSOR_DOWN then
        self:scroll(1)
    elseif keys.CURSOR_UP then
        self:scroll(-1)
    end
end

function load_screen:scroll(dist)
    self.sel_idx = self.sel_idx + dist
    if self.sel_idx > #self.saves then self.sel_idx = 0
    elseif self.sel_idx < 1 then self.sel_idx = #self.saves
    end
end

prev_focus = ''
dfhack.onStateChange.load_screen = function()
    cur_focus = dfhack.gui.getCurFocus()
    if cur_focus == 'loadgame' and prev_focus ~= 'dfhack/lua' then
        load_screen():show()
    end
    prev_focus = cur_focus
end
