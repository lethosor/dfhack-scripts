-- load-screen

local gui = require 'gui'
local widgets = require 'gui.widgets'

paintString = dfhack.screen.paintString
function paintStringCenter(pen, y, str)
    cols, rows = dfhack.screen.getWindowSize()
    paintString(pen, math.floor((cols - #str) / 2), y, str)
end
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
    cols, rows = dfhack.screen.getWindowSize()
    max_rows = math.floor((rows - 5) / 2)
    min = self.sel_idx - math.floor(max_rows / 2)
    max = self.sel_idx + math.ceil(max_rows / 2)
    if max > #saves then
        d = max - #saves
        max = max - d
        min = min - d
    end
    if min < 1 then
        d = 1 - min
        min = min + d
        max = max + d
    end
    max = math.min(max, #saves)

    paintStringCenter(pen, 0, "Load game (DFHack)")
    y = 0
    max_x = 77
    for i = min, max do
        save = saves[i]
        pen.fg = COLOR_GREY
        if self:is_backup(save.folder_name) then pen.fg = COLOR_RED end
        if i == self.sel_idx then
            pen.fg = pen.fg + 8
        end
        pen.bg = (i == self.sel_idx and COLOR_BLUE) or COLOR_BLACK

        y = y + 2
        year = save.year .. ''
        dfhack.screen.fillRect(pen, 2, y, max_x, y + 1)
        paintString(pen, 2, y, save.fort_name)
        paintString(pen, max_x - #save.world_name, y, save.world_name)
        paintString(pen, 3, y + 1, "Folder: " .. save.folder_name)
        paintString(pen, max_x - #year, y + 1, year)
    end
end

function load_screen:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
        dfhack.screen.dismiss(self._native.parent)
    elseif keys.SELECT then
        load_screen_options:display(self, self:get_saves()[self.sel_idx])
    elseif keys.CURSOR_DOWN then
        self:scroll(1)
    elseif keys.CURSOR_UP then
        self:scroll(-1)
    elseif keys.CUSTOM_B then
        self.opts.backups = not self.opts.backups
    end
end

function load_screen:scroll(dist)
    self.sel_idx = self.sel_idx + dist
    saves = self:get_saves()
    if self.sel_idx > #saves then self.sel_idx = 1
    elseif self.sel_idx < 1 then self.sel_idx = #saves
    end
end

function load_screen:load_game(folder_name)
    if not folder_name then return end
    parent = self._native.parent
    parent.saves[0].folder_name = folder_name
    parent.sel_idx = 0
    parent.loading = 1
    self:dismiss()
end

load_screen_options = gui.FramedScreen{
    frame_width = 40,
    frame_height = 6,
    frame_title = "",
    frame_inset = 1,
}

function load_screen_options:onRenderBody(painter)
    if self.load_state ~= 0 then
        dfhack.screen.clear()
        paintString({ch=' ', fg=COLOR_WHITE, bg=COLOR_BLACK}, 2, 2, "Loading game...")
    end
    if self.load_state == 1 then
        self.load_state = 2
    elseif self.load_state == 2 then
        self.parent:load_game(self.save.folder_name)
        self.load_state = 0
        self:dismiss()
        return
    end
    painter:string('Esc: Cancel')
    painter:newline()
    painter:string('Enter: Load')
end

function load_screen_options:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    elseif keys.SELECT then
        self.load_state = 1
    end
end

function load_screen_options:display(parent, save)
    self.parent = parent
    self.save = save
    self.frame_title = "Load game: " .. self.save.folder_name
    self.load_state = 0
    self:show()
end

local prev_focus
function init()
    prev_focus = ''
    dfhack.onStateChange.load_screen = function()
        cur_focus = dfhack.gui.getCurFocus()
        if cur_focus == 'loadgame' and prev_focus ~= 'dfhack/lua' then
            load_screen():show()
        end
        prev_focus = cur_focus
    end
end
if initialized == nil then
    init()
    initialized = true
end
