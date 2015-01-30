-- List a directory's contents recurively

args = {...}
path = args[1] or qerror('No path provided')
list = dfhack.filesystem.listdir_recursive(path)
for i, v in ipairs(list) do
    print(('%-6s %-5s %s'):format('#' .. i .. ':', v.isdir and 'dir:' or 'file:', v.path))
end
