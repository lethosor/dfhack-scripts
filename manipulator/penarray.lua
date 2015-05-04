if not manipulator_module then qerror('Only usable from within manipulator') end
penarray = {}
function penarray.new(width)
    self = {width = width, grid = {}}
    for i = 1, width do
        self.grid[i] = dfhack.pen.parse({})
    end
    setmetatable(self, {__index = penarray})
    return self
end
function penarray:set_tile(x, y, pen)
    self.grid[x] = dfhack.pen.parse(pen)
end
function penarray:draw(x1, y, width, height, bufx, bufy)
    local x2 = x1 + width - 1
    for x = x1, x2 do
        dfhack.screen.paintTile(self.grid[x - x1 + bufx] or {}, x, y)
    end
end
