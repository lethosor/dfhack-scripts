-- List a directory's contents recurively

args = {...}
path = args[1] or qerror('No path provided')
list, err = dfhack.filesystem.listdir_recursive(path)
if list == nil then
    qerror('Error ' .. err)
end
for i, v in ipairs(list) do
    print(('%-6s %-5s %s'):format('#' .. i .. ':', v.isdir and 'dir:' or 'file:', v.path))
end
