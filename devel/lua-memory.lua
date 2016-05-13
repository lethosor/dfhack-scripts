-- Display a graph of Lua memory usage
--@ module = true
gui = require 'gui'

storage = storage or {}
function storage.get(name, default)
    if storage[name] == nil then
        return default
    else
        return storage[name]
    end
end

mem = defclass(mem, gui.FramedScreen)
mem.ATTRS = {
    frame_title = 'Lua Memory Usage',
    focus_path = 'lua-memory',
}

function mem:init()
    if dfhack.gui.getCurFocus() == 'dfhack/lua/lua-memory' then
        qerror('Already active')
    end
    if storage.graph then
        self.graph = storage.graph
    else
        self.graph = {}
        for i = 1, 70 do table.insert(self.graph, 0) end
    end
    self:updateYAxis()
    self.tick = 0
    self.graph_tick = 0
    self.speed = storage.get('speed', 2)
    self.show_parent = storage.get('show_parent', false)
    self.input_to_parent = false
    self.show_graph = storage.get('show_graph', true)
end

function mem:getCount()
    return math.floor(collectgarbage('count'))
end

function mem:makeGarbage()
    local t = {}
    for a = 1, 10 do
        t[a] = {}
        for b = 1, 10 do
            t[a][b] = {}
            for c = 1, 10 do
                t[a][b][c] = {}
                for d = 1, 10 do
                    t[a][b][c][d] = {}
                end
            end
        end
    end
end

function mem:updateYAxis()
    self.max = 4
    for _, v in pairs(self.graph) do
        self.max = math.max(v, self.max)
    end
    self.max = math.ceil(self.max / 4000) * 4000
    self.y_axis = {}
    for i = 0, 4 do
        table.insert(self.y_axis, math.floor(self.max * (4 - i) / 4))
    end
end

function mem:onIdle()
    storage.speed = self.speed
    storage.show_parent = self.show_parent
    storage.show_graph = self.show_graph
    if self.tick > df.global.enabler.calculated_fps / self.speed then
        self.tick = 0
        table.remove(self.graph, 1)
        table.insert(self.graph, self:getCount())
        self:updateYAxis()
        self.graph_tick = self.graph_tick + 1
        if self.graph_tick >= 3 then
            self.graph_tick = 0
        end
    end
    self.tick = self.tick + 1
end

function mem:onRenderBody(p)
    local function draw_yn(x)
        p:string(x and '(Y)' or '(N)', (x and COLOR_GREEN or COLOR_RED) + (self.show_parent and 8 or 0))
        p:string(' ')
    end
    p:pen{fg = COLOR_WHITE}
    if self.show_parent then
        self._native.parent:render()
        p:pen{fg = COLOR_WHITE, bg = COLOR_DARKGREY}
        p:key_pen{fg = COLOR_LIGHTGREEN, bg = COLOR_DARKGREY}
        for x = 0, p.width do
            for y = 0, 2 do
                p:seek(x, y):string(' ')
            end
        end
    end
    p:seek(0, 0)
    p:string('KB: ' .. self:getCount())
    if self.input_to_parent then
        p:pen{fg = COLOR_GREY, bg = COLOR_DARKGREY}
    end
    p:seek(10):key('CUSTOM_C'):string(': Collect garbage, ')
    p:key('CUSTOM_A'):key('CUSTOM_S'):string(': Speed = ' .. self.speed .. ', ')
    p:key('CUSTOM_I'):string(': Allocate garbage')
    p:newline(10)
    p:key('CUSTOM_P'):string(': Show parent ')
    draw_yn(self.show_parent)
    if self.show_parent then
        p:key('CUSTOM_ALT_P'):string(': Send input to parent ', COLOR_WHITE)
        draw_yn(self.input_to_parent)
    end
    p:newline(10)
    p:key('CUSTOM_G'):string(': Show graph ')
    draw_yn(self.show_graph)
    p:key('CUSTOM_Z'):string(': Auto-collect ')
    draw_yn(collectgarbage('isrunning'))
    if self.show_graph then
        p:newline():newline()
        local top_y = p.y
        local bottom_y
        for i, v in pairs(self.y_axis) do
            p:string(tostring(v), COLOR_WHITE)
            if i == 5 then
                bottom_y = p.y - 1
            else
                for _ = 1, 4 do p:newline() end
            end
        end
        for x, v in pairs(self.graph) do
            p:pen{bg = COLOR_LIGHTGREEN - ((((x + self.graph_tick) % 3) % 2) * 8)}
            local start_y = math.floor((1 - (v / self.max)) * (bottom_y - top_y + 1)) + top_y
            for y = start_y, bottom_y do
                p:seek(x + 6, y):string(' ')
            end
        end
    end
end

function mem:onInput(keys)
    if keys.CUSTOM_ALT_P and self.show_parent then
        self.input_to_parent = not self.input_to_parent
        return
    end
    if keys.LEAVESCREEN then
        self:dismiss()
        return
    end
    if self.input_to_parent and self.show_parent then
        gui.simulateInput(self._native.parent, keys)
        return
    end
    if keys.CUSTOM_C then
        collectgarbage()
    elseif keys.CUSTOM_G then
        self.show_graph = not self.show_graph
    elseif keys.CUSTOM_A or keys.CUSTOM_S then
        self.speed = math.max(1, math.min(10, self.speed + (keys.CUSTOM_S and 1 or -1)))
    elseif keys.CUSTOM_I then
        self:makeGarbage()
    elseif keys.CUSTOM_P then
        self.show_parent = not self.show_parent
    elseif keys.CUSTOM_Z then
        collectgarbage(collectgarbage('isrunning') and 'stop' or 'restart')
    end
end

function mem:onDismiss()
    storage.graph = self.graph
end

if not moduleMode then mem():show() end
