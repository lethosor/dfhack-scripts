-- Generate a wikitext table of emotions

VERSION = '1.0'

utils = require 'utils'
args = utils.processArgs({...}, utils.invert{'file', 'overwrite'})
f = nil
if args.file ~= nil then
    if dfhack.filesystem.exists(args.file) and not args.overwrite then
        qerror('File exists, -overwrite not specified')
    end
    f, err = io.open(args.file, 'w')
    if f == nil then
        qerror('Could not open file: ' .. err)
    end
    write = function(...) f:write(...) end
else
    write = dfhack.print
end

write([[{| class="wikitable sortable"
|-
! ID !! Emotion !! Divider
]])
for id, emotion in ipairs(df.emotion_type) do
    if emotion ~= nil and id >= 0 then
        attrs = df.emotion_type.attrs[id]
        if attrs.color >= 8 then
            color = (attrs.color - 8) .. ':1'
        else
            color = attrs.color .. ':0'
        end
        write('|-\n')
        write(('|| %i || {{DFtext|%s|%s}} || %i\n'):format(id, emotion, color, attrs.divider))
    end
end
write('|}\n')

if f ~= nil then
    f:close()
end
