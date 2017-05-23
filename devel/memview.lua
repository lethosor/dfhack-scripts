
--@ module = true

local gui = require 'gui'
local utils = require 'utils'

TYPES = {
    invalid = {
        desc = 'Invalid data',
        pen = {fg = COLOR_WHITE, bg = COLOR_RED},
    },
    space = {
        desc = '',
        pen = COLOR_WHITE,
    },
    number = {
        desc = 'Number',
        pen = COLOR_WHITE,
    },
    pointer = {
        desc = 'Pointer',
        pen = COLOR_LIGHTRED,
    },
    vpointer = {
        desc = 'VTable pointer',
        pen = {fg = COLOR_LIGHTRED, bg = COLOR_GREEN},
    },
    vector = {
        desc = 'Vector',
        pen = COLOR_YELLOW,
    },
}


function findVTableAddresses()
    local f = io.open(dfhack.getHackPath() .. 'symbols.xml')
    local contents = f:read('*a')
    f:close()
    local classes = {}
    for cls in contents:gmatch("vtable%-address.-name=['\"](.-)['\"]") do
        classes[cls] = true
    end
    local addrs = {}
    for cls in pairs(classes) do
        local a = dfhack.internal.getVTable(cls)
        if a then
            addrs[a] = cls
        end
    end
    return addrs
end
VTABLES = findVTableAddresses()

function isValidAddr(ranges, addr, length)
    for _, range in pairs(ranges) do
        if range.start_addr <= addr and addr < range.end_addr then
            if length then
                return range.start_addr < addr + length and addr + length <= range.end_addr
            else
                return true
            end
        end
    end
    return false
end

MemoryViewer = defclass(MemoryViewer, gui.Screen)

function MemoryViewer:init(args)
    self.start = args.start
    self.cur_start = args.start - (args.start % 16)
    self.min_start = self.cur_start
    self.length = args.length
    self.end_ = self.start + self.length

    self.data = {}
    self:updateData()
end

function MemoryViewer:onRenderBody(p)
    dfhack.screen.clear()
    p:pen(COLOR_WHITE)
    local default_pen = p.cur_pen
    p:seek(1, 0):string("DFHack Memory Viewer")
    p:seek(1, 2)
    if not self.data then
        p:string("Could not read data from this range", COLOR_LIGHTRED)
        return
    end
    local line_addr = self.cur_start
    local space = {text = '  ', type = 'space'}
    self.coords = {}
    self.coords.x1 = p.x
    self.coords.y1 = p.y
    self.coords.cell_x1 = {}
    self.coords.cell_x2 = {}
    while line_addr < self.start + self.length and p.y < p.y2 do
        p:string(('0x%04x  '):format(line_addr))
        for addr = line_addr, line_addr + 15 do
            local data = self.data[addr] or space
            if p.y == self.coords.y1 then
                table.insert(self.coords.cell_x1, p.x)
            end
            p:string(data.text, TYPES[data.type].pen)
            p:advance(1 + (addr % 4 == 3 and 1 or 0))
            if p.y == self.coords.y1 then
                table.insert(self.coords.cell_x2, p.x - 1)
            end
        end

        if p.y == self.coords.y1 then
            self.coords.x2 = p.x - 1
        end

        for i = 0, 15 do
            local data = self.data[line_addr + i]
            p:string(data and string.char(data.value) or ' ')
        end

        p:newline(1)
        line_addr = line_addr + 16
    end
    self.coords.y2 = p.y - 1
end

function MemoryViewer:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    elseif keys.STANDARDSCROLL_UP then
        self.cur_start = math.max(self.cur_start - 16, self.min_start)
    elseif keys.STANDARDSCROLL_DOWN then
        if self.cur_start + 16 < self.end_ then
            self.cur_start = self.cur_start + 16
        end
    elseif keys._MOUSE_L or keys._MOUSE_R then
        local mx = df.global.gps.mouse_x
        local my = df.global.gps.mouse_y
        if self.coords.x1 <= mx and mx <= self.coords.x2 and self.coords.y1 <= my and my <= self.coords.y2 then
            local addr = self.cur_start + (16 * (my - self.coords.y1))
            for i = 1, 16 do
                if self.coords.cell_x1[i] <= mx and mx <= self.coords.cell_x2[i] then
                    addr = addr + i - 1
                    break
                end
            end
            print(('0x%x'):format(addr))
            local data = self.data[addr]
            if data.type == 'pointer' or data.type == 'vpointer' then
                if keys._MOUSE_L then
                    MemoryViewer{start=data.pointer, length=256}:show()
                end
            elseif data.type == 'vector' then
                if keys._MOUSE_L then
                    MemoryViewer{start=data.vector_start, length=data.vector_length}:show()
                end
            end
        end
    end
end

function MemoryViewer:updateData()
    print('starting')
    local ranges = dfhack.internal.getMemRanges()
    for i = #ranges, 1, -1 do
        if not ranges[i].valid or not ranges[i].read then
            table.remove(ranges, i)
        end
    end

    for addr = self.start, self.end_ - 1 do
        if not self.data[addr] then
            self.data[addr] = {}
        end
    end

    print('reading')
    local raw = {}
    if not isValidAddr(ranges, self.start, self.length) then
        print('invalid!')
        self.data = nil
        return
    end
    for i = 0, self.length - 1 do
        local addr = self.start + i
        raw[addr] = df.reinterpret_cast('uint8_t', addr).value
        self.data[addr].value = raw[addr]
        self.data[addr].text = ('%02X'):format(raw[addr])
        self.data[addr].type = 'number'
    end

    print('ptr scan')
    local sizeof_ptr = df.reinterpret_cast('uintptr_t', self.start):sizeof()
    local ptrs_raw = df.reinterpret_cast('uintptr_t', self.start - (self.start % sizeof_ptr))
    while utils.addressof(ptrs_raw) + sizeof_ptr <= self.end_ do
        local addr = utils.addressof(ptrs_raw)
        if addr >= self.start --[[and isValidAddr(ranges, addr)]] then
            local ptr = ptrs_raw.value
            if VTABLES[ptr] then
                for i = 0, sizeof_ptr - 1 do
                    self.data[addr + i].type = 'vpointer'
                    self.data[addr + i].class = VTABLES[ptr]
                    self.data[addr + i].pointer = ptr
                end
            elseif isValidAddr(ranges, ptr) then
                for i = 0, sizeof_ptr - 1 do
                    self.data[addr + i].type = 'pointer'
                    self.data[addr + i].pointer = ptr
                end
                if self.data[addr - (2 * sizeof_ptr)] and not self.data[addr - (2 * sizeof_ptr)].vector_start and
                        self.data[addr - (2 * sizeof_ptr)].pointer and self.data[addr - sizeof_ptr].pointer and
                        self.data[addr - (2 * sizeof_ptr)].pointer <= self.data[addr - sizeof_ptr].pointer and
                        self.data[addr - sizeof_ptr].pointer <= self.data[addr].pointer then
                    local vector_start = self.data[addr - (2 * sizeof_ptr)].pointer
                    local vector_length = self.data[addr - sizeof_ptr].pointer - vector_start
                    for i = -2 * sizeof_ptr, sizeof_ptr - 1 do
                        self.data[addr + i].type = 'vector'
                        self.data[addr + i].vector_start = vector_start
                        self.data[addr + i].vector_length = vector_length
                    end
                end
            end
        end
        ptrs_raw = ptrs_raw:_displace(1)
    end
    print('done')
end

function main(args)
    local expr = args[1] or qerror('need expression!')
    if tonumber(expr) then
        addr = tonumber(expr)
        length = tonumber(args[2] or qerror('need length!'))
    else
        length, addr = utils.df_expr_to_ref(expr):sizeof()
        if args[2] then
            length = tonumber(args[2]) or qerror('invalid length')
        end
    end
    MemoryViewer{start=addr, length=length}:show()
end

if not dfhack_flags.module then
    main({...})
end
