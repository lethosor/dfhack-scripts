if not manipulator_module then qerror('Only usable from within manipulator') end

function manipulator_columns:init(args)
    self.parent = args.parent
    if self.parent.focus_path ~= 'manipulator' then error('Invalid context') end
    self.columns = self.parent.columns
    self.all_columns = self.parent.all_columns
    self.col_idx = 1
    self.all_col_idx = 1
    self.cur_list = 1
end

function manipulator_columns:get_selection()
    if self.cur_list == 1 then
        return self.columns[self.col_idx]
    else
        return self.all_columns[self.all_col_idx]
    end
end

function manipulator_columns:onRenderBody(p)
    local x1 = 2
    local x2 = math.floor(gps.dimx / 2) - 1
    local x3 = gps.dimx - 2
    local y1 = 4
    local y2 = gps.dimy - 6
    OutputString(COLOR_GREY, x1, y1 - 2, "Drag column names or use arrow keys to move cursor")
    self.bounds = {x1 = x1, x2 = x2, x3 = x3, y1 = y1, y2 = y2}
    self.bounds.col1 = {x1, y1, x2, y1 + #self.columns - 1}
    self.bounds.col1_full = {x1, y1, x2, y2}
    self.bounds.col2 = {x2 + 1, y1, x3, y1 + #self.all_columns - 1}
    self.bounds.col2_full = {x2 + 1, y1, x3, y2}
    local y = y1
    for i = 1, #self.columns do
        if self.drag_y == y then y = y + 1 end
        OutputString((self.cur_list == 1 and i == self.col_idx and COLOR_LIGHTGREEN) or COLOR_GREEN,
            x1, y, self.columns[i].title:sub(1, x2 - x1 - 1))
        y = y + 1
    end
    for i = 1, #self.all_columns do
        OutputString((self.cur_list == 2 and i == self.all_col_idx and COLOR_YELLOW) or COLOR_BROWN,
            x2 + 1, y1 + i - 1, self.all_columns[i].title:sub(1, x3 - x2 - 1))
    end
    local col = self:get_selection()
    local c_color = self.cur_list == 1 and COLOR_WHITE or COLOR_DARKGREY
    local a_color = self.cur_list == 2 and COLOR_WHITE or COLOR_DARKGREY
    OutputKeyString(c_color, x1, y2 + 1, 'CURSOR_UP_FAST', 'Move up')
    OutputKeyString(c_color, x1, y2 + 2, 'CURSOR_DOWN_FAST', 'Move down')
    OutputKeyString(c_color, x1, y2 + 3, 'CUSTOM_R', 'Remove')
    OutputKeyString(a_color, x2 + 1, y2 + 1, 'CUSTOM_A', 'Add')
    if col then
        OutputString(COLOR_GREY, x1, y2 + 4, col.desc)
    end
    if enabler.mouse_lbut_down == 1 then
        self:handle_drag()
    elseif enabler.mouse_lbut_down == 0 and self.in_drag then
        self:handle_drop()
    end
end

function manipulator_columns:handle_drag()
    local x = gps.mouse_x
    local y = gps.mouse_y
    if not self.in_drag and (in_bounds(x, y, self.bounds.col1) or
            in_bounds(x, y, self.bounds.col2)) then
        self.in_drag = true
        self.drag_add = in_bounds(x, y, self.bounds.col2)
        local col_idx = y - self.bounds.y1 + 1
        local col_list = self.drag_add and self.all_columns or self.columns
        self.drag_text = col_list[col_idx].title
        if in_bounds(x, y, self.bounds.col1) then
            self.drag_column = table.remove(self.columns, col_idx)
            self.drag_dx = x - self.bounds.x1 - 1
        elseif self.drag_add then
            self.drag_column = self.all_columns[col_idx]
            self.drag_dx = x - self.bounds.x2 - 1
        end
        self.col_idx_old = self.col_idx
        self.col_idx = 0
    end
    if self.in_drag then
        if in_bounds(x, y, self.bounds.col1_full) then
            self.drag_y = y
        else
            self.drag_y = nil
        end
        local fg = in_bounds(x, y, self.bounds.col1_full) and COLOR_LIGHTGREEN or COLOR_YELLOW
        OutputString(fg, x - self.drag_dx, y, self.drag_text)
    end
end

function manipulator_columns:handle_drop()
    local x = gps.mouse_x
    local y = gps.mouse_y
    local col_idx = math.min(#self.columns + 1, y - self.bounds.y1 + 1)
    self.in_drag = false
    if in_bounds(x, y, self.bounds.col1_full) then
        table.insert(self.columns, col_idx, self.drag_column)
        self.col_idx = col_idx
    else
        self.col_idx = math.min(#self.columns, self.col_idx_old)
    end
    self.drag_column = nil
    self.drag_y = nil
end

function manipulator_columns:onInput(keys)
    process_keys(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
        return
    elseif keys.CURSOR_LEFT or keys.CURSOR_RIGHT then
        self.cur_list = 3 - self.cur_list
    elseif keys.CURSOR_UP or keys.CURSOR_DOWN then
        if self.cur_list == 1 then
            self.col_idx = self.col_idx + (keys.CURSOR_UP and -1 or 1)
            if self.col_idx < 1 then
                self.col_idx = #self.columns
            elseif self.col_idx > #self.columns then
                self.col_idx = 1
            end
        else
            self.all_col_idx = self.all_col_idx + (keys.CURSOR_UP and -1 or 1)
            if self.all_col_idx < 1 then
                self.all_col_idx = #self.all_columns
            elseif self.all_col_idx > #self.all_columns then
                self.all_col_idx = 1
            end
        end
    end
    if self.cur_list == 1 then
        if keys.CURSOR_UP_FAST and self.col_idx > 1 then
            tmp = self.columns[self.col_idx - 1]
            self.columns[self.col_idx - 1] = self.columns[self.col_idx]
            self.columns[self.col_idx] = tmp
            self.col_idx = self.col_idx - 1
        elseif keys.CURSOR_DOWN_FAST and self.col_idx < #self.columns then
            tmp = self.columns[self.col_idx + 1]
            self.columns[self.col_idx + 1] = self.columns[self.col_idx]
            self.columns[self.col_idx] = tmp
            self.col_idx = self.col_idx + 1
        elseif keys.CUSTOM_R then
            table.remove(self.columns, self.col_idx)
            self.col_idx = math.min(self.col_idx, #self.columns)
        end
    else
        if keys.CUSTOM_A or keys.SELECT then
            table.insert(self.columns, self.col_idx + 1, self:get_selection())
            self.col_idx = self.col_idx + 1
        end
    end
    self.super.onInput(self, keys)
end
