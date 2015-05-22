if not manipulator_module then qerror('Only usable from within manipulator') end

manipulator = defclass(manipulator, gui.FramedScreen)
manipulator.focus_path = 'manipulator'
manipulator.ATTRS = {
    frame_style = gui.BOUNDARY_FRAME,
    frame_inset = 1,
    top_margin = 2,
    bottom_margin = 2,
    left_margin = 2,
    right_margin = 2,
    list_top_margin = 3,
    list_bottom_margin = 7,
}

function manipulator:init(args)
    p_start('init')
    self.units = {}
    for i, u in pairs(args.units) do
        self.units[i + 1] = unit_wrapper(u)
    end
    self.dismiss_parent = args.dismiss_parent
    self.unit_max = #self.units
    self.bounds = {}
    self.gframe = 0
    self.list_start = 1   -- unit index
    self.list_end = 1     -- unit index
    self.list_height = 1  -- list_end - list_start + 1
    self.list_idx = 1
    self.grid_start = 1   -- SKILL_COLUMNS index
    self.grid_end = 1     -- SKILL_COLUMNS index
    self.grid_width = 0   -- grid_end - grid_start + 1
    self.grid_idx = 1
    self.grid_rows = {}
    self.diff_enabled = storage.diff_enabled
    self.labor_changes = {added = 0, removed = 0}
    p_start('init units')
    for idx, u in pairs(self.units) do
        self.grid_rows[u] = penarray.new(#SKILL_COLUMNS, 1)
        if u._native == args.selected then
            self.list_idx = idx
        end
        u.allow_edit = true
        if not dfhack.units.isOwnRace(u._native) or not dfhack.units.isOwnCiv(u._native) or
                u.flags1.dead or not df.profession.attrs[u.profession].can_assign_labor then
            u.allow_edit = false
        end
        u.legendary = false
        if u.status.current_soul then
            for _, unit_skill in pairs(u.status.current_soul.skills) do
                if unit_skill.rating >= 15 then
                    u.legendary = true
                    break
                end
            end
        end
        u.on_fire = false
        for i, stat in pairs(u.body.components.body_part_status) do
            if stat.on_fire then
                u.on_fire = true
                break
            end
        end
        u.orig_labors = {}
        for k, v in ipairs(u.status.labors) do
            u.orig_labors[k] = v
        end
        u.labor_changes = {added = 0, removed = 0}
    end
    p_end('init units')
    self:draw_grid()
    self.all_columns = load_columns(self)
    self.columns = {}
    p_start('populate columns')
    for k, c in pairs(self.all_columns) do
        if c.default then table.insert(self.columns, c) end
        c:clear_cache()
        c:populate(self.units)
    end
    p_end('populate columns')
    if type(storage.default_columns) ~= 'table' then
        storage.default_columns = get_column_ids(self.columns)
    else
        self.columns = get_columns(self.all_columns, storage.default_columns)
    end
    self:set_title('Manage Labors')
    p_end('init')
end

function manipulator:set_title(title)
    self.frame_title = 'Dwarf Manipulator - ' .. title
end

function manipulator:onRenderBody(p)
    p.clip_y2 = gps.dimy - 2  -- extend lower clip boundary by 1 row
    self.gframe = self.gframe + 1
    if self.gframe > enabler.gfps then self.gframe = 0 end
    self.blink_state = (self.gframe < enabler.gfps / 3)
    local col_start_x = {}
    local x = self.left_margin
    local y = self.top_margin
    for id, col in pairs(self.columns) do
        col_start_x[id] = x
        OutputString(COLOR_GREY, x, y, col.title)
        x = x + col.width + 1
    end
    local grid_start_x = x
    self.grid_start = math.max(1, self.grid_start)
    self.grid_width = gps.dimx - x - self.right_margin + 1
    self.grid_end = math.min(self.grid_start + self.grid_width - 1, #SKILL_COLUMNS)
    if self.grid_end > #SKILL_COLUMNS then
        self.grid_start = self.grid_start - (self.grid_end - #SKILL_COLUMNS)
        self.grid_end = #SKILL_COLUMNS
    end
    for i = self.grid_start, self.grid_end do
        local col = SKILL_COLUMNS[i]
        local fg = col.color
        local bg = COLOR_BLACK
        if i == self.grid_idx then
            fg = COLOR_BLACK
            bg = COLOR_GREY
        end
        OutputString({fg = fg, bg = bg}, x, 1, col.label:sub(1, 1))
        OutputString({fg = fg, bg = bg}, x, 2, col.label:sub(2, 2))
        x = x + 1
    end
    if gps.mouse_x >= grid_start_x and gps.mouse_y >= 1 and gps.mouse_y <= 2 then
        local caption = ''
        local col = SKILL_COLUMNS[gps.mouse_x - grid_start_x + self.grid_start]
        if col.labor ~= df.unit_labor.NONE then
            caption = df.unit_labor.attrs[col.labor].caption
        elseif col.skill ~= df.job_skill.NONE then
            caption = df.job_skill.attrs[col.skill].caption_noun
        end
        OutputString(COLOR_GREY, math.min(gps.mouse_x, gps.dimx - #caption - 1), 3, caption)
    end
    y = self.list_top_margin + 1
    self.list_end = self.list_start + math.min(self.unit_max - self.list_start, gps.dimy - self.list_bottom_margin - self.list_top_margin - 2)
    self.list_height = self.list_end - self.list_start + 1
    if self.list_idx > self.list_end then
        local d = self.list_idx - self.list_end
        self.list_start = self.list_start + d
        self.list_end = self.list_end + d
    elseif self.list_idx < self.list_start then
        local d = self.list_start - self.list_idx
        self.list_start = self.list_start - d
        self.list_end = self.list_end - d
    end
    for _, u in pairs(self.units) do
        if u.dirty then
            self:update_labor_changes()
            break
        end
    end
    for i = self.list_start, self.list_end do
        local unit = self.units[i]
        if unit.dirty then
            self:draw_unit_row(unit)
        end
        for id, col in pairs(self.columns) do
            x = col_start_x[id]
            local fg = col:lookup_color(unit)
            local bg = COLOR_BLACK
            local text = col:lookup(unit)
            if i == self.list_idx and col.highlight then
                bg = COLOR_GREY
                fg = COLOR_BLACK
                text = text .. (' '):rep(col.width - #text)
            end
            OutputString({fg = fg, bg = bg}, x, y, text)
        end
        self.grid_rows[unit]:draw(grid_start_x, self.list_top_margin + i - self.list_start + 1,
            gps.dimx - grid_start_x - 1, 1,
            self.grid_start - 1, 0)
        y = y + 1
        unit.dirty = false
    end
    local unit = self.units[self.list_idx]
    local col = SKILL_COLUMNS[self.grid_idx]
    do
        local p = gui.Painter.new_wh(2, 1, gps.dimx - 3, 1)
        p:pen{fg = COLOR_DARKGREY}
        p:seek(0, 0):string('Labor changes: ')
        if self.labor_changes.added ~= 0 or self.labor_changes.removed ~= 0 then
            if self.labor_changes.added ~= 0 then
                p:string('+' .. self.labor_changes.added, COLOR_GREEN)
            end
            if self.labor_changes.removed ~= 0 then
                p:string('-' .. self.labor_changes.removed, COLOR_RED)
            end
        else
            p:string('None')
        end
        if unit.labor_changes.added ~= 0 or unit.labor_changes.removed ~= 0 then
            p:string(' (Unit: ')
            if unit.labor_changes.added ~= 0 then
                p:string('+' .. unit.labor_changes.added, COLOR_GREEN)
            end
            if unit.labor_changes.removed ~= 0 then
                p:string('-' .. unit.labor_changes.removed, COLOR_RED)
            end
            p:string(')')
        end
    end
    p:pen{fg = COLOR_WHITE}
    p:seek(0, gps.dimy - self.list_bottom_margin - 1)
    p:string(dfhack.units.isMale(unit._native) and string.char(11) or string.char(12)):string(' ')
    local translated_name = dfhack.TranslateName(unit.name)
    p:string(translated_name)
    if #translated_name > 0 then
        p:string(', ')
    end
    p:string(dfhack.units.getProfessionName(unit._native)):string(': ')
    if col.skill == df.job_skill.NONE then
        if col.labor ~= df.unit_labor.NONE then
            p:string(df.unit_labor.attrs[col.labor].caption, {fg = COLOR_LIGHTBLUE}):string(' ')
        end
        p:string(unit.status.labors[col.labor] and 'Enabled' or 'Not Enabled', {fg = COLOR_LIGHTBLUE})
    else
        local lvl = skills.rating(unit, col.skill)
        local prof = df.job_skill.attrs[col.skill].caption_noun
        p:string((lvl > 0 and SKILL_LEVELS[lvl].name or 'Not') .. ' ' .. prof, {fg = COLOR_LIGHTBLUE})
        if lvl < #SKILL_LEVELS then
            p:string(' '):string(('(%i/%i)'):format(skills.experience(unit, col.skill),
                SKILL_LEVELS[lvl > 0 and lvl or 1].points), {fg = COLOR_LIGHTBLUE})
        end
    end
    p:newline()
    p:key('SELECT'):string(': Toggle labor ')
    p:key('SELECT_ALL'):string(': Toggle group ')
    p:key('UNITJOB_VIEW'):string(': View Unit ')
    p:key('UNITJOB_ZOOM_CRE'):string(': Go to Unit')
    p:newline()
    p:key('SECONDSCROLL_UP'):key('SECONDSCROLL_DOWN'):string(': Sort by skill')
    p:newline()
    p:key('CUSTOM_X'):key('CUSTOM_SHIFT_X'):string(': Select ')
    p:key('CUSTOM_A'):key('CUSTOM_SHIFT_A'):string(': all/none, ')
    p:key('CUSTOM_B'):string(': Batch ')
    p:key('CUSTOM_E'):string(': Edit, ')
    p:key('CUSTOM_D'):string(': Diff '):string(self.diff_enabled and '(Y)' or '(N)',
        self.diff_enabled and COLOR_GREEN or COLOR_RED)
    p:newline()
    p:key('CUSTOM_SHIFT_C'):string(': Columns ')
    self.bounds.grid = {grid_start_x, self.list_top_margin + 1, gps.dimx - 2, self.list_top_margin + self.list_height}
    self.bounds.grid_header = {self.bounds.grid[1], 1, self.bounds.grid[3], 2}
    self.bounds.columns = {}
    for id, col in pairs(self.columns) do
        self.bounds.columns[id] = {col_start_x[id], self.list_top_margin + 1,
            col_start_x[id] + col.width - 1, self.list_top_margin + self.list_height}
    end
    OutputString({fg=COLOR_BLACK, bg=COLOR_DARKGREY}, 2, gps.dimy - 1, "manipulator " .. VERSION)
end

function manipulator:update_grid_tile(x, y)
    if x == nil then x = self.grid_idx end
    if y == nil then y = self.list_idx end
    local unit = self.units[y]
    local fg = COLOR_WHITE
    local bg = COLOR_BLACK
    local c = string.char(0xFA)
    local skill = SKILL_COLUMNS[x].skill
    local labor = SKILL_COLUMNS[x].labor
    if skill ~= df.job_skill.NONE then
        local level = skills.rating(unit, skill)
        c = level > 0 and SKILL_LEVELS[level].abbr or '-'
    end
    if labor ~= df.unit_labor.NONE then
        if unit.status.labors[labor] then
            bg = COLOR_GREY
            if skill == df.job_skill.NONE then
                c = string.char(0xF9)
            end
        end
        if self.diff_enabled then
            if unit.status.labors[labor] and not unit.orig_labors[labor] then
                bg = COLOR_GREEN
            elseif (not unit.status.labors[labor]) and unit.orig_labors[labor] then
                bg = COLOR_RED
            end
        end
    else
        bg = COLOR_CYAN
    end
    if x == self.grid_idx and y == self.list_idx then
        fg = COLOR_LIGHTBLUE
    end
    self.grid_rows[unit]:set_tile(x - 1, 0, {fg = fg, bg = bg, ch = c})
end

function manipulator:update_unit_grid_tile(unit, x)
    for y, u in pairs(self.units) do
        if u == unit then
            self:update_grid_tile(x, y)
            return
        end
    end
    error('Could not find unit in unit list')
end

function manipulator:draw_grid()
    p_start('draw_grid')
    for y = 1, #self.units do
        for x = 1, #SKILL_COLUMNS do
            self:update_grid_tile(x, y)
        end
    end
    p_end('draw_grid')
end

function manipulator:draw_unit_row(unit)
    for x = 1, #SKILL_COLUMNS do
        self:update_unit_grid_tile(unit, x)
    end
end

function manipulator:update_viewport()
    if self.list_idx > self.list_end then
        self.list_start = self.list_idx - self.list_height + 1
    elseif self.list_idx < self.list_start then
        self.list_start = self.list_idx
    end
    if self.grid_idx > self.grid_end then
        self.grid_start = self.grid_idx - self.grid_width + 1
    elseif self.grid_idx < self.grid_start then
        self.grid_start = self.grid_idx
    end
end

function manipulator:onInput(keys)
    local cur_x = self.grid_idx
    local cur_y = self.list_idx
    local cur_unit = self.units[self.list_idx]
    local old_x = cur_x
    local old_y = cur_y
    local old_unit = cur_unit
    process_keys(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
        return
    end
    if keys.CURSOR_UP or keys.CURSOR_DOWN or keys.CURSOR_UP_FAST or keys.CURSOR_DOWN_FAST then
        self.list_idx = scroll_index(self.list_idx,
            ((keys.CURSOR_UP or keys.CURSOR_UP_FAST) and -1 or 1)
            * ((keys.CURSOR_UP_FAST or keys.CURSOR_DOWN_FAST) and 10 or 1),
            1, self.unit_max
        )
        self:update_viewport()
    end
    if keys.CURSOR_LEFT or keys.CURSOR_RIGHT or keys.CURSOR_LEFT_FAST or keys.CURSOR_RIGHT_FAST then
        self.grid_idx = scroll_index(self.grid_idx,
            ((keys.CURSOR_LEFT or keys.CURSOR_LEFT_FAST) and -1 or 1)
            * ((keys.CURSOR_LEFT_FAST or keys.CURSOR_RIGHT_FAST) and 10 or 1),
            1, #SKILL_COLUMNS, {wrap = false}
        )
        self:update_viewport()
    end
    if keys.CURSOR_DOWN_Z then
        self:update_grid_tile()
        local newgroup = SKILL_COLUMNS[self.grid_idx].group + 1
        for i = self.grid_idx, #SKILL_COLUMNS do
            if SKILL_COLUMNS[i].group == newgroup then
                self.grid_idx = i
                self:update_grid_tile()
                self:update_viewport()
                break
            end
        end
    elseif keys.CURSOR_UP_Z then
        self:update_grid_tile()
        local newgroup = SKILL_COLUMNS[math.max(1, self.grid_idx - 1)].group
        while self.grid_idx > 1 and SKILL_COLUMNS[self.grid_idx - 1].group == newgroup do
            self.grid_idx = self.grid_idx - 1
        end
        self:update_grid_tile()
        self:update_viewport()
    end
    if keys.SELECT then
        self:toggle_labor(self.grid_idx, self.list_idx)
    elseif keys.SELECT_ALL then
        self:toggle_labor_group(self.grid_idx, self.list_idx)
    elseif keys.CUSTOM_SHIFT_C then
        mgui.manipulator_columns{parent = self}:show()
    elseif keys.UNITJOB_VIEW then
        self:view_unit(self.units[self.list_idx])
    elseif keys.UNITJOB_ZOOM_CRE then
        self:zoom_unit(self.units[self.list_idx])
    elseif keys.SECONDSCROLL_UP or keys.SECONDSCROLL_DOWN then
        self:sort_skill(SKILL_COLUMNS[self.grid_idx].skill, keys.SECONDSCROLL_UP)
        self:update_unit_grid_tile(old_unit, old_x)
    elseif keys.CUSTOM_X then
        self:selection_start(cur_unit)
    elseif keys.CUSTOM_SHIFT_X then
        self:selection_extend(cur_unit)
    elseif keys.CUSTOM_A or keys.CUSTOM_SHIFT_A then
        for i, u in pairs(self.units) do
            self:_select_unit(u, keys.CUSTOM_A)
        end
        self.selection_state = nil
    elseif keys.CUSTOM_E then
        mgui.batch_ops({units = {cur_unit}}):show()
    elseif keys.CUSTOM_B then
        local units = {}
        for _, u in pairs(self.units) do
            if u.selected then
                table.insert(units, u)
            end
        end
        mgui.batch_ops({units = units}):show()
    elseif keys.CUSTOM_D then
        self.diff_enabled = not self.diff_enabled
        self:draw_grid()
    elseif keys._MOUSE_L or keys._MOUSE_R then
        self:onMouseInput(gps.mouse_x, gps.mouse_y,
            {left = keys._MOUSE_L, right = keys._MOUSE_R}, dfhack.internal.getModifiers())
    end
    self:update_grid_tile(old_x, old_y)
    self:update_grid_tile()
end

function manipulator:onMouseInput(x, y, buttons, mods)
    local old_grid_col = self.grid_idx
    local old_grid_row = self.list_idx
    local old_unit = self.units[old_grid_row]
    local grid_col = x - self.bounds.grid[1] + self.grid_start
    local grid_row = y - self.bounds.grid[2] + self.list_start
    if in_bounds(x, y, self.bounds.grid) then
        if buttons.left then
            if mods.shift then
                self:toggle_labor_group(grid_col, grid_row)
            else
                self:toggle_labor(grid_col, grid_row)
            end
        elseif buttons.right then
            self.grid_idx = grid_col
            self.list_idx = grid_row
            self:update_grid_tile(old_grid_col, old_grid_row)
            self:update_grid_tile()
        end
    elseif in_bounds(x, y, self.bounds.grid_header) then
        if buttons.right or mods.shift then
            self:sort_skill(SKILL_COLUMNS[grid_col].skill, false)
        else
            self:sort_skill(SKILL_COLUMNS[grid_col].skill, true)
        end
        self:update_unit_grid_tile(old_unit, old_grid_col)
    else
        for id, col in pairs(self.columns) do
            if in_bounds(x, y, self.bounds.columns[id]) then
                col.on_click(self.units[grid_row], buttons, mods)
            end
        end
    end
end

function manipulator:sort_skill(skill, descending)
    p_start('sort_skill')
    self.units = merge_sort(self.units, make_sort_order(sort.skill, descending, skill))
    self.selection_state = nil
    p_end('sort_skill')
end

function manipulator:update_labor_changes()
    p_start('update_labor_changes')
    self.labor_changes.added = 0
    self.labor_changes.removed = 0
    for _, unit in pairs(self.units) do
        unit.labor_changes.added = 0
        unit.labor_changes.removed = 0
        for labor, state in ipairs(unit.status.labors) do
            if state and not unit.orig_labors[labor] then
                self.labor_changes.added = self.labor_changes.added + 1
                unit.labor_changes.added = unit.labor_changes.added + 1
            elseif not state and unit.orig_labors[labor] then
                self.labor_changes.removed = self.labor_changes.removed + 1
                unit.labor_changes.removed = unit.labor_changes.removed + 1
            end
        end
    end
    p_end('update_labor_changes')
end

function manipulator:set_labor(x, y, state)
    local unit = self.units[y] or error('Invalid unit ID: ' .. y)
    local labor = SKILL_COLUMNS[x].labor or error('Invalid column id: ' .. x)
    local changed = false
    local function cb(unit, labor, state)
        self:update_unit_grid_tile(unit, labors.get_column_index(labor))
        changed = true
    end
    labors.set(unit, labor, state, cb)
    if changed then
        self:update_labor_changes()
    end
end

function manipulator:toggle_labor(x, y)
    local col = SKILL_COLUMNS[x] or error('Invalid column ID: ' .. x)
    local unit = self.units[y] or error('Invalid unit ID: ' .. y)
    if not labors.valid(unit, col.labor) then return end
    self:set_labor(x, y, not unit.status.labors[col.labor])
end

function manipulator:toggle_labor_group(x, y)
    local col = SKILL_COLUMNS[x] or error('Invalid column ID: ' .. x)
    local unit = self.units[y] or error('Invalid unit ID: ' .. y)
    local labor = col.labor
    local group = col.group
    if not labors.valid(unit, labor) then return end
    local state = not unit.status.labors[labor]
    for x, col in pairs(SKILL_COLUMNS) do
        if col.group == group then
            self:set_labor(x, y, state)
        end
    end
end

function manipulator:parent_select_unit(unit)
    local parent = self._native.parent
    for id, u in pairs(parent.units[parent.page]) do
        if u == unit._native then
            parent.cursor_pos[parent.page] = id
            return true
        end
    end
    return false
end

function manipulator:view_unit(u)
    local parent = self._native.parent
    if self:parent_select_unit(u) then
        u.dirty = true
        gui.simulateInput(parent, {UNITJOB_VIEW = true})
    end
end

function manipulator:zoom_unit(u)
    local parent = self._native.parent
    if self:parent_select_unit(u) then
        gui.simulateInput(parent, {UNITJOB_ZOOM_CRE = true})
        self:dismiss()
    end
end

function manipulator:_unit_index(unit)
    for i, u in pairs(self.units) do
        if unit == u then
            return i
        end
    end
end

function manipulator:_select_unit(u, state)
    if state ~= u.selected and u.allow_edit then
        u.selected = state
        u.dirty = true
    end
end

function manipulator:selection_start(u)
    self.selection_state = {start = u, state = not u.selected}
    self:_select_unit(u, not u.selected)
end

function manipulator:selection_extend(u)
    if not self.selection_state then
        return self:selection_start(u)
    end
    for i in irange(self:_unit_index(self.selection_state.start), self:_unit_index(u)) do
        self:_select_unit(self.units[i], self.selection_state.state)
    end
end

function manipulator:onResize(...)
    self.super.onResize(self, ...)
end

function manipulator:onDismiss(...)
    storage.default_columns = get_column_ids(self.columns)
    storage.diff_enabled = self.diff_enabled
    self.super.onDismiss(...)
    if self.dismiss_parent then
        dfhack.screen.dismiss(self._native.parent)
    end
end

function manipulator:onGetSelectedUnit()
    local u = self.units[self.list_idx]
    u.dirty = true
    return u._native
end
