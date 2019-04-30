gui = require 'gui'
guidm = require 'gui.dwarfmode'

COLORS = {
    COLOR_LIGHTBLUE, COLOR_LIGHTGREEN, COLOR_LIGHTRED, COLOR_CYAN, COLOR_MAGENTA, COLOR_BROWN, COLOR_YELLOW, COLOR_LIGHTMAGENTA
}

MSState = defclass(MSState)
MSState.instance = MSState.instance or nil

function MSState:init(opts)
    self.grid = self:make_grid(opts.width or 10, opts.height or 10)
    self.has_mines = false
    self.draw_buffer = dfhack.penarray.new(opts.width or 10, opts.height or 10)
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

function MSState:add_mines(n, skipx, skipy)
    local dimx, dimy = self:grid_dims()
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
    if not self.has_mines then
        self:add_mines(10, x, y)
    end
    local queue = {self.grid[x][y]}
    while #queue > 0 do
        local cell = table.remove(queue, 1)
        if not cell.revealed and not cell.marked then
            cell.revealed = true
            if not cell.mine and cell.count == 0 then
                for _, neighbor in ipairs(self:cell_neighbors(cell)) do
                    if not neighbor.revealed then
                        table.insert(queue, neighbor)
                    end
                end
            end
        end
    end
end

function MSState:mark(x, y)
    self.grid[x][y].marked = not self.grid[x][y].marked
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
        MSState.instance = MSState()
    end
    local dimx, dimy = MSState.instance:grid_dims()
    self.cursor = {x = math.floor(dimx / 2), y = math.floor(dimy / 2)}
end

function MSScreen:onRenderBody(p)
    MSState.instance.draw_buffer:draw(p.x1 + 1, p.y1 + 1, p.x2, p.y2)
    local ctile = dfhack.screen.readTile(p.x1 + self.cursor.x, p.y1 + self.cursor.y)
    ctile.bg = COLOR_YELLOW
    ctile.fg = COLOR_BLACK
    dfhack.screen.paintTile(ctile, p.x1 + self.cursor.x, p.y1 + self.cursor.y)
    -- MSState.instance.draw_buffer:draw(0, 0, 11, 11)
end

function MSScreen:onInput(keys)
    local state = MSState.instance
    if keys.LEAVESCREEN then
        self:dismiss()
    elseif keys.SELECT then
        state:reveal(self.cursor.x, self.cursor.y)
    elseif keys.CUSTOM_X or keys.CUSTOM_M then
        state:mark(self.cursor.x, self.cursor.y)
    elseif keys.CUSTOM_R then
        for x, col in pairs(state.grid) do
            for y, tile in pairs(col) do
                tile.revealed = true
            end
        end
    elseif keys.CUSTOM_SHIFT_R then
        MSState.instance = MSState()
    end

    local gridx, gridy = state:grid_dims()
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