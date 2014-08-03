-- load-screen

local gui = require 'gui'
local widgets = require 'gui.widgets'

function gui.Painter:keyString(key, str)
    self:string(gui.getKeyDisplay(df.interface_key[key]), COLOR_LIGHTRED)
    self:string(": " .. str, COLOR_WHITE)
end
function keyStringLength(key, str)
    return #(gui.getKeyDisplay(df.interface_key[key]) .. ": " .. str)
end
function paintKeyString(x, y, key, str, opts)
    opts = opts or {}
    key_str = gui.getKeyDisplay(df.interface_key[key])
    paintString({ch=' ', fg=opts.key_color or COLOR_LIGHTRED}, x, y, key_str)
    paintString({ch=' ', fg=COLOR_WHITE}, x + #key_str, y, ": " .. str)
end

function gametypeString(gametype, overrides)
    overrides = overrides or {}
    if overrides[df.game_type[gametype]] then return overrides[df.game_type[gametype]] end
    if gametype == df.game_type.DWARF_MAIN then
        return "Fortress mode"
    elseif gametype == df.game_type.DWARF_RECLAIM then
        return "Reclaim fortress mode"
    elseif gametype == df.game_type.ADVENTURE_MAIN then
        return "Adventure mode"
    elseif gametype == df.game_type.NONE then
        return "None"
    else
        return "Unknown mode"
    end
end
gametypeMap = (function()
    gametypes = {'NONE', 'DWARF_MAIN', 'DWARF_RECLAIM', 'ADVENTURE_MAIN'}
    ret = {}
    for i, t in pairs(gametypes) do
        ret[t] = gametypes[i + 1] or gametypes[1]
    end
    return ret
end)()

paintString = dfhack.screen.paintString
function paintStringCenter(pen, y, str)
    if tonumber(pen) ~= nil then
        pen = math.max(0, math.min(15, pen))
        pen = {ch=' ', fg=pen}
    end
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
    self:reset()
end

function load_screen:reset()
    self.sel_idx = 1
    self.opts = {
        backups = false,
        filter = '',
        filter_mode = df.game_type.NONE,
    }
    self.search_active = false
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
            (#self.opts.filter and not save.folder_name:lower():find(self.opts.filter:lower())) or
            (self.opts.filter_mode ~= df.game_type.NONE and self.opts.filter_mode ~= save.game_type) then
            --pass
        else
            table.insert(saves, save)
        end
    end
    return saves
end

function load_screen:onRender()
    pen = {ch=' ', fg=COLOR_GREY}
    key_pen = {ch=' ', fg=COLOR_LIGHTRED}
    saves = self:get_saves()
    self.sel_idx = math.max(1, math.min(#saves, self.sel_idx))
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
        if save.game_type == df.game_type.DWARF_RECLAIM then
            pen.fg = COLOR_MAGENTA
        elseif save.game_type == df.game_type.ADVENTURE_MAIN then
            pen.fg = COLOR_CYAN
        end
        if i == self.sel_idx then
            pen.fg = pen.fg + 8
        end
        pen.bg = (i == self.sel_idx and COLOR_BLUE) or COLOR_BLACK

        y = y + 2
        year = save.year .. ''
        dfhack.screen.fillRect(pen, 2, y, max_x, y + 1)
        paintString(pen, 2, y, save.fort_name .. " - " .. gametypeString(save.game_type))
        paintString(pen, max_x - #save.world_name, y, save.world_name)
        paintString(pen, 3, y + 1, "Folder: " .. save.folder_name)
        paintString(pen, max_x - #year, y + 1, year)
    end
    if #saves == 0 then
        paintString(COLOR_WHITE, 1, 3, "No results found")
        paintKeyString(1, 5, "CUSTOM_ALT_C", "Clear filters")
    end
    label = self.opts.filter
    if #label > 20 then
        label = '\027' .. label:sub(-20)
    end
    if self.search_active then
        paintKeyString(1, rows - 1, 'CUSTOM_S', label, {key_color = COLOR_RED})
        x = keyStringLength('CUSTOM_S', label) + 1
        paintString({ch=' ', fg=COLOR_LIGHTGREEN}, x, rows - 1, '_')
    else
        paintKeyString(1, rows - 1, 'CUSTOM_S', #label > 0 and label or "Search")
    end
    paintKeyString(27, rows - 1, 'CUSTOM_T', gametypeString(self.opts.filter_mode, {NONE = "Any mode"}))
end

function load_screen:onInput(keys)
    if self.search_active then
        if keys.LEAVESCREEN then
            self.search_active = false
            self.opts.filter = ''
        elseif keys.SELECT then
            self.search_active = false
        elseif keys.STRING_A000 then
            self.opts.filter = self.opts.filter:sub(0, -2)
        elseif keys._STRING then
            self.opts.filter = self.opts.filter .. string.char(keys._STRING)
        elseif keys.CURSOR_DOWN or keys.CURSOR_UP then
            self.search_active = false
            self:onInput(keys)
        elseif keys.CUSTOM_ALT_C then
            self.opts.filter = ''
        end
        return
    end
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
    elseif keys.CUSTOM_S then
        self.search_active = true
    elseif keys.CUSTOM_T then
        self.opts.filter_mode = df.game_type[gametypeMap[df.game_type[self.opts.filter_mode]]]
    elseif keys.CUSTOM_ALT_C then
        self:reset()
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
    if not folder_name then return false end
    parent = self._native.parent
    for i = 0, #parent.saves - 1 do
        if parent.saves[i].folder_name == folder_name then
            parent.sel_idx = i
            self:dismiss()
            gui.simulateInput(parent, {df.interface_key.SELECT})
            return true
        end
    end
    return false
end

load_screen_options = gui.FramedScreen{
    frame_width = 40,
    frame_height = 6,
    frame_title = "",
    frame_inset = 1,
}

function load_screen_options:onRenderBody(painter)
    if self.loading == true then
        self.loading = false
        self.parent:load_game(self.save.folder_name)
        self:dismiss()
        return
    end
    painter:seek(0, self.frame_height - 1)
    painter:keyString('LEAVESCREEN', 'Cancel')
    painter:seek(self.frame_width - keyStringLength('SELECT', 'Play now'), self.frame_height - 1)
    painter:keyString('SELECT', 'Play now')
end

function load_screen_options:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    elseif keys.SELECT then
        self.loading = true
    end
end

function load_screen_options:display(parent, save)
    if not save then return end
    self.parent = parent
    self.save = save
    self.frame_title = "Load game: " .. self.save.folder_name
    self:show()
end

function init()
    prev_focus = ''
    dfhack.onStateChange.load_screen = function()
        cur_focus = dfhack.gui.getCurFocus()
        print(cur_focus)
        if cur_focus == 'loadgame' and prev_focus ~= 'dfhack/lua' and prev_focus ~= 'loadgame' and enabled then
            load_screen():show()
        end
        prev_focus = cur_focus
    end
end
if initialized == nil then
    init()
    initialized = true
    enabled = true
end

args = {...}
if #args == 1 then
    if args[1] == 'enable' then enabled = true
    elseif args[1] == 'disable' then enabled = false
    end
end
