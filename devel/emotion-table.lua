-- Generate a wikitext table of emotions

VERSION = '1.2'

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
! ID !! Emotion !! Strength
]])
for id, emotion in ipairs(df.emotion_type) do
    if emotion ~= nil and id >= 0 then
        attrs = df.emotion_type.attrs[id]
        if attrs.color >= 8 then
            color = (attrs.color - 8) .. ':1'
        else
            color = attrs.color .. ':0'
        end
        strength = attrs.divider
        strength_bg = 'inherit'
        if strength ~= 0 then
            strength = -8 / strength
            if strength >= 4 then strength_bg = '#99E699'
            elseif strength >= 0 then strength_bg = '#CCFFB2'
            elseif strength > -4 then strength_bg = '#FFCCCC'
            else strength_bg = '#FFA3A3'
            end
            if strength >= 0 then
                strength = '+' .. strength
            end
            strength = tostring(strength)
        end
        emotion = emotion:gsub('[A-Z]', ' %1'):sub(2)
        write('|-\n')
        write(('| %i || {{DFtext|%s|%s}} ||style="background-color:%s;"| %s\n')
              :format(id, emotion, color, strength_bg, strength))
    end
end
write('|}\n')

if f ~= nil then
    f:close()
end
