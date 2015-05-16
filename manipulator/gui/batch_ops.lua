if not manipulator_module then qerror('Only usable from within manipulator') end
local gui = require 'gui'

NICKNAME = {}
PROFNAME = {}

function draw_names(units)
    local p = gui.Painter.new_xy(2, 2, gps.dimx - 3, 2)
    p:string(tostring(#units), COLOR_LIGHTGREEN)
    p:string((' %s selected: '):format(#units == 1 and 'dwarf' or 'dwarves'))
    local last = 1
    for i, u in pairs(units) do
        local name = dfhack.TranslateName(u.name)
        if #name + p.x + 12 >= gps.dimx - 2 then
            break
        end
        last = i
        p:string(name, COLOR_WHITE)
        if i ~= #units then
            p:string(', ', COLOR_WHITE)
        end
    end
    if last ~= #units then
        p:string(('and %i more'):format(#units - last))
    end
end

name_callbacks = {
    [NICKNAME] = function(unit, name)
        dfhack.units.setNickname(unit._native, name)
    end,
    [PROFNAME] = function(unit, name)
        unit.custom_profession = name
    end,
}

function apply_batch(units, func, ...)
    for _, u in pairs(units) do
        func(u, ...)
        u.dirty = true
    end
end

batch_ops = defclass(batch_ops, gui.FramedScreen)
batch_ops.ATTRS = {
    focus_path = 'manipulator/batch',
    options = {
        {'Change nickname', 'edit_nickname'},
        {'Change profession name', 'edit_profname'},
        {'Enable all labors', 'enable_all'},
        {'Disable all labors', 'disable_all'},
        {'Revert labor changes', 'revert_changes'},
    },
    selection_pen = {fg = COLOR_WHITE, bg = COLOR_GREEN},
    frame_style = gui.BOUNDARY_FRAME,
    frame_title = 'Dwarf Manipulator - Batch Operations',
    frame_inset = 1,
}

function batch_ops:init(args)
    self.units = check_nil(args.units)
    self.sel_idx = 1
    self.empty = (#self.units == 0)
end

function batch_ops:onRenderBody(p)
    if self.empty then
        p:string('No dwarves selected!', COLOR_LIGHTRED)
        return
    end
    draw_names(self.units)
    for i = 1, #self.options do
        p:seek(0, i + 1):string(self.options[i][1], i == self.sel_idx and self.selection_pen or nil)
    end
end

function batch_ops:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
        return
    end
    process_keys(keys)
    if self.empty then return end
    if keys.SELECT then
        self:callback(self.options[self.sel_idx][2])()
    elseif keys.CURSOR_UP or keys.CURSOR_DOWN then
        self.sel_idx = scroll_index(self.sel_idx, keys.CURSOR_UP and -1 or 1, 1, #self.options)
    end
end

function batch_ops:edit_nickname()
    name_editor({units = self.units, name = NICKNAME}):show()
end

function batch_ops:edit_profname()
    name_editor({units = self.units, name = PROFNAME}):show()
end

function batch_ops:handle_labors(callback)
    if not callback then return end
    for _, u in pairs(self.units) do
        for _, col in pairs(SKILL_COLUMNS) do
            callback(u, col.labor)
        end
    end
end

function batch_ops:set_all_labors(state)
    local function cb(unit, labor)
        if state and labors.special(labor) then
            return
        end
        labors.set(unit, labor, state)
        unit.dirty = true
    end
    self:handle_labors(cb)
end

function batch_ops:enable_all()
    self:set_all_labors(true)
end

function batch_ops:disable_all()
    self:set_all_labors(false)
end

function batch_ops:revert_changes()
    local function cb(unit, labor)
        labors.set(unit, labor, labors.get_orig(unit, labor))
        unit.dirty = true
    end
    self:handle_labors(cb)
end

name_editor = defclass(name_editor, gui.FramedScreen)
name_editor.ATTRS = {
    focus_path = 'manipulator/batch/name',
    frame_style = gui.BOUNDARY_FRAME,
    frame_inset = 1,
}

function name_editor:init(opts)
    self.units = opts.units
    self.name = opts.name
    self.name_desc = opts.name == NICKNAME and 'Nickname' or 'Profession Name'
    self.frame_title = 'Dwarf Manipulator - Edit ' .. self.name_desc
    self.entry = ''
end

function name_editor:onRenderBody(p)
    local max_width = p.clip_x2 - p.clip_x1
    p.clip_x1 = p.clip_x1 - 1
    p.clip_x2 = p.clip_x2 + 1
    local entry = self.entry
    draw_names(self.units)
    p:seek(0, 2):string('Custom ' .. self.name_desc .. ':')
    p:newline(2)
    if #entry > max_width then
        entry = entry:sub(-max_width)
        p:seek(-1):string('<', COLOR_LIGHTCYAN)
    end
    p:seek(0):string(entry, COLOR_WHITE):string('_', COLOR_LIGHTCYAN)
    p:newline():newline()
    p:seek(0):string('(Leave blank to use original name)', COLOR_DARKGREY)
end

function name_editor:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
        return
    end
    if keys.SELECT then
        apply_batch(self.units, name_callbacks[self.name], self.entry)
        self:dismiss()
    elseif keys.STRING_A000 then
        self.entry = self.entry:sub(1, -2)
    elseif keys._STRING then
        self.entry = self.entry .. string.char(keys._STRING)
    end
end
