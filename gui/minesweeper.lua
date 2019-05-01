dlg = require 'gui.dialogs'
gui = require 'gui'
guidm = require 'gui.dwarfmode'

COLORS = {
    COLOR_LIGHTBLUE, COLOR_LIGHTGREEN, COLOR_LIGHTRED, COLOR_CYAN, COLOR_MAGENTA, COLOR_BROWN, COLOR_YELLOW, COLOR_LIGHTMAGENTA
}

MSState = defclass(MSState)
MSState.ATTRS{
    width = 10,
    height = 10,
    mines = 10,
}
MSState.instance = MSState.instance or nil

function MSState:init()
    self.grid = self:make_grid(self.width, self.height)
    self.counts = {
        revealed = 0,
        marked = 0,
    }
    self.has_mines = false
    self.won = false
    self.lost = false
    self.safe_cells = self.width * self.height - self.mines
    self.draw_buffer = dfhack.penarray.new(self.width, self.height)
    self:draw()
end

function MSState:make_grid(x, y)
    local grid = {}
    for xi = 1, x do
        local col = {}
        for yi = 1, y do
            table.insert(col, {
                x = xi,
                y = yi,
                mine = false,
                revealed = false,
                marked = false,
                count = 0,
            })
        end
        table.insert(grid, col)
    end
    return grid
end

function MSState:grid_dims()
    return #self.grid, #self.grid[1]
end

function MSState:cell_neighbors(cell)
    local x, y = cell.x, cell.y
    local dimx, dimy = self:grid_dims()
    local out = {}
    for dx = -1, 1 do
        for dy = -1, 1 do
            if (dx ~= 0 or dy ~= 0) and (x + dx >= 1 and x + dx <= dimx) and (y + dy >= 1 and y + dy <= dimy) then
                table.insert(out, self.grid[x + dx][y + dy])
            end
        end
    end
    return out
end

function MSState:add_mines(skipx, skipy)
    local dimx, dimy = self:grid_dims()
    local n = self.mines
    while n > 0 do
        local x = math.ceil(math.random() * dimx)
        local y = math.ceil(math.random() * dimy)
        if (x ~= skipx or y ~= skipy) and not self.grid[x][y].mine then
            self.grid[x][y].mine = true
            n = n - 1
        end
    end
    for x = 1, dimx do
        for y = 1, dimy do
            local count = 0
            for _, neighbor in ipairs(self:cell_neighbors(self.grid[x][y])) do
                if neighbor.mine then
                    count = count + 1
                end
            end
            self.grid[x][y].count = count
        end
    end
    self.has_mines = true
end

function MSState:reveal(x, y)
    if self.lost then return end
    if not self.has_mines then
        self:add_mines(x, y)
    end
    local queue = {self.grid[x][y]}
    while #queue > 0 do
        local cell = table.remove(queue, 1)
        if not cell.revealed and not cell.marked then
            cell.revealed = true
            self.counts.revealed = self.counts.revealed + 1
            if cell.mine then
                self.lost = true
            elseif cell.count == 0 then
                for _, neighbor in ipairs(self:cell_neighbors(cell)) do
                    if not neighbor.revealed then
                        table.insert(queue, neighbor)
                    end
                end
            end
        end
    end
    if self.counts.revealed == self.safe_cells and not self.lost then
        self:mark_all()
        self.won = true
    end
end

function MSState:reveal_all()
    local dimx, dimy = self:grid_dims()
    for x = 1, dimx do
        for y = 1, dimy do
            if not self.grid[x][y].revealed then
                self:reveal(x, y)
            end
        end
    end
end

function MSState:mark(x, y)
    if self.lost then return end
    local cell = self.grid[x][y]
    if not cell.revealed then
        cell.marked = not cell.marked
        self.counts.marked = self.counts.marked + (cell.marked and 1 or -1)
    end
end

function MSState:mark_all()
    local dimx, dimy = self:grid_dims()
    for x = 1, dimx do
        for y = 1, dimy do
            local cell = self.grid[x][y]
            if cell.mine and not cell.revealed and not cell.marked then
                cell.marked = true
                self.counts.marked = self.counts.marked + 1
            end
        end
    end
end

function MSState:draw()
    for x, col in ipairs(self.grid) do
        for y, tile in ipairs(col) do
            if tile.marked then
                pen = {bg = COLOR_DARKGREY, ch = 19, fg = COLOR_WHITE}
            elseif not tile.revealed then
                pen = {bg = COLOR_DARKGREY, ch = ' '}
            elseif tile.mine then
                pen = {fg = COLOR_LIGHTRED, ch = 15}
            elseif tile.count == 0 then
                pen = {fg = COLOR_GREY, ch = '.'}
            else
                pen = {fg = COLORS[tile.count], ch = tostring(tile.count)}
            end
            self.draw_buffer:set_tile(x - 1, y - 1, pen)
        end
    end
end

MSScreen = defclass(MSScreen, gui.FramedScreen)

function MSScreen:init()
    if not MSState.instance then
        self:new_game()
    end
    local dimx, dimy = MSState.instance:grid_dims()
    self.cursor = {x = math.floor(dimx / 2), y = math.floor(dimy / 2)}
end

function MSScreen:new_game()
    MSState.instance = MSState()
end

function MSScreen:onRenderBody(p)
    local state = MSState.instance
    state.draw_buffer:draw(p.x1 + 1, p.y1 + 1, p.x2, p.y2)
    local ctile = dfhack.screen.readTile(p.x1 + self.cursor.x, p.y1 + self.cursor.y)
    ctile.bg = COLOR_YELLOW
    ctile.fg = COLOR_BLACK
    dfhack.screen.paintTile(ctile, p.x1 + self.cursor.x, p.y1 + self.cursor.y)

    local gridx, gridy = state:grid_dims()
    local sidebar = gui.Painter.new_xy(60, p.y1 + 1, p.x2 - 1, p.y2 - 1)
    local dwarf_pen = {fg = COLOR_GREY}
    local status = ''
    if state.won then
        status = 'You win!'
        if math.floor(dfhack.getTickCount() / 333) % 3 == 0 then
            dwarf_pen.fg = COLOR_WHITE
        end
    elseif state.lost then
        dwarf_pen.bg = COLOR_RED
        status = 'You died.'
    end
    sidebar:char(1, dwarf_pen):string(' ' .. status):newline()
    sidebar:string(('Mines: %d/%d'):format(state.counts.marked, state.mines)):newline()
    sidebar:string(('Revealed: %d/%d'):format(state.counts.revealed, gridx * gridy - state.mines)):newline()
    sidebar:newline()
    sidebar:key_string('CUSTOM_SHIFT_N', 'New game')
end

function MSScreen:onInput(keys)
    local state = MSState.instance
    local gridx, gridy = state:grid_dims()

    if keys.LEAVESCREEN then
        self:dismiss()
    elseif keys.SELECT then
        state:reveal(self.cursor.x, self.cursor.y)
    elseif keys.CUSTOM_X or keys.CUSTOM_M then
        state:mark(self.cursor.x, self.cursor.y)
    elseif keys.CUSTOM_SHIFT_D then
        state:reveal_all()
    elseif keys.CUSTOM_SHIFT_N then
        if state.won or state.lost then
            self:new_game()
        else
            dlg.showYesNoPrompt('New game',
                'Are you sure you want to start a new game? All progress will be lost.',
                COLOR_LIGHTRED,
                self:callback('new_game'))
        end
    end

    for k, _ in pairs(keys) do
        local dx, dy, dz = guidm.get_movement_delta(k, 1, 5)
        if dx then
            self.cursor.x = math.max(1, math.min(gridx, self.cursor.x + dx))
            self.cursor.y = math.max(1, math.min(gridy, self.cursor.y + dy))
        end
    end
    state:draw()
end

MSScreen():show()
