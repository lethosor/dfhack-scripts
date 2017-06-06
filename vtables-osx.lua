ms = require 'memscan'
cdata = ms.get_data_segment()
data = ms.get_data_segment()

function reverseAndReadString(buf, idx)
	local s = ''
	local min = idx - 200

	while idx > min do
		local c = buf[idx]
		local c1 = buf[idx-1]
		if c >= 0x30 and c <= 0x39 and not (c1 >= 0x30 and c1 <= 0x39) then
			break
		end

		idx = idx - 1
	end

	if idx == min then
		return 0,''
	end

	local start = idx

	while true do
		local c = buf[idx]
		if c == 0 then
			break
		end

		s = s .. string.char(c)
		idx = idx + 1
	end

	return start, s
end

local o = 0
while true do
	local i8 = cdata.uint8_t
	local i64 = data.uint64_t
	local idx,addr = i8:find({0x73,0x74,0}, o+1)

	if not idx then
		break
	end

	local idx2,s = reverseAndReadString(i8,idx)
	-- local classname = s:match('[0-9]+(.+st)')
	local classname = s:match('([0-9a-z_A-Z]+)')

	if classname then
		local idx3,addr3 = i64:find({i8:idx2addr(idx2)})
		if idx3 then
			local idx4,addr4 = i64:find({i64:idx2addr(idx3-1)})

			local vtable = addr4 + 8
			print(string.format("<vtable-address name='%s' value='0x%x'/>",classname,vtable))
		else
			print ('NOT FOUND ', classname)
		end
	end

	o = idx
end
