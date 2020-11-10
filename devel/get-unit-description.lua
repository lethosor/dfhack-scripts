-- Retrieves a unit's physical description
-- similar to dfhack.units.getPhysicalDescription() but parses the text viewer screen instead
-- (this can be slow and produce visible flickering, especially if running this on multiple units in sequence)

unit = dfhack.gui.getSelectedUnit()
if not unit then return end

unit_scr = df.viewscreen_unitst:new()
unit_scr.unit = unit
unit_scr:feed_key(df.interface_key.SELECT)
unit_scr:delete()

text_scr = dfhack.gui.getCurViewscreen()
if not df.viewscreen_textviewerst:is_instance(text_scr) then error('bad screen') end

-- 0x40: bold flag
FORMAT_YELLOW = 0x40 | (COLOR_YELLOW & 0x7)
FORMAT_WHITE = 0x40 | (COLOR_WHITE & 0x7)

function read_c_str(ptr)
    local s = ''
    local i = 0
    while ptr[i] ~= 0 do
        s = s .. string.char(ptr[i])
        i = i + 1
    end
    return s
end

desc_lines = {}
found_yellow = false
for _, line in ipairs(text_scr.formatted_text) do
    if not line.format then
        -- skip (empty line)
    elseif line.format[0] == FORMAT_YELLOW and not found_yellow then
        -- age description is in yellow and is before physical description
        found_yellow = true
    elseif line.format[0] == FORMAT_WHITE and found_yellow then
        table.insert(desc_lines, read_c_str(line.text))
    elseif line.format[0] ~= FORMAT_WHITE and #desc_lines > 0 then
        -- reached end of description
        break
    end
end

desc = table.concat(desc_lines, ' '):gsub('  ', ' ')
print(desc)
