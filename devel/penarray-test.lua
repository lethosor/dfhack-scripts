gui = require 'gui'
scr = defclass(scr, gui.Screen)

function scr:init(args)
    self.slow = args.slow
    self.nocache = args.nocache
    if self.slow then
        self.array = {}
    elseif not self.nocache then
        self.array = dfhack.penarray.new(80, 200)
    end
    for x = 1, 80 do
        if self.slow then self.array[x] = {} end
        for y = 1, 200 do
            local row = ('row %-3i '):format(y):rep(11)
            if self.slow then
                self.array[x][y] = dfhack.pen.parse{ch = row:sub(x, x)}
            elseif not self.nocache then
                self.array:set_tile(x - 1, y - 1, {ch = row:sub(x, x)})
            end
        end
    end
    self.y = 0
end

function scr:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    elseif keys.CURSOR_UP then
        self.y = math.max(0, self.y - 1)
    elseif keys.CURSOR_DOWN then
        self.y = math.min(199, self.y + 1)
    end
end

function scr:onRender()
    dfhack.screen.clear()
    if self.slow then
        for x = 2, df.global.gps.dimx - 4 do
            for y = 2, df.global.gps.dimy - 4 do
                if self.array[x] and self.array[x][y] then
                    dfhack.screen.paintTile(self.array[x][y], x, y)
                end
            end
        end
    elseif self.nocache then
        for y = 1, math.max(df.global.gps.dimy - 1, 200) do
            local row = ('row %-3i '):format(y):rep(11)
            for x = 1, 80 do
                dfhack.screen.paintTile({ch = row:sub(x, x)}, x, y)
            end
        end
    else
        self.array:draw(2, 2, df.global.gps.dimx - 4, df.global.gps.dimy - 4, 0, self.y)
    end
end

args = {...}

scr{
    slow = (args[1] == 'slow'),
    nocache = (args[1] == 'nocache'),
}:show()
