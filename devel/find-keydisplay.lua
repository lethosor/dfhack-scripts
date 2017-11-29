-- scan for keydisplay offset

ptr_size = dfhack.getArchitecture() / 8

local file = io.open('data/init/interface.txt') or qerror('could not open interface.txt')
local text = file:read('*all')
file:close()
local kb_length = 0
for _ in text:gmatch('BIND:') do
    kb_length = kb_length + 1
end

data = require('memscan').get_data_segment()

for addr = data.start_addr, data.end_addr - 1, 4 do
    if df.reinterpret_cast('int32_t', addr).value == kb_length then
        print(("<global-address name='keydisplay' value='0x%x'/>")
            :format(addr - (ptr_size * 5)))
    end
end

-- local i = 0
-- while true do
--     if data[i] == 0 and data[i + 1] == 0 and data[i + 2] == 0 and data[i + 3] == 0 then
--         if data[i + 5] == 1 and data[i + 7] == 1 and data[i + 9] == 1 then
--             if data[i + 10] == kb_length and data[i + 11] == 0 then
--                 print(('0x%x'):format(data.start + data.esize * i))
--             end
--         end
--     end
--     i = i + 1
-- end
