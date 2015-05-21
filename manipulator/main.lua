-- manipulator

gui = require 'gui'
widgets = require 'gui.widgets'
utils = require 'utils'
enabler = df.global.enabler
gps = df.global.gps

args = {...}
iargs = utils.invert(args)
if iargs['--profile'] then
    PROFILE = true
elseif iargs['--no-profile'] then
    PROFILE = false
end

VERSION = '0.6.1'
PROFILE = PROFILE or false

if PROFILE then
    p_data = {}
    function p_start(name)
        p_data[name] = os.clock()
    end
    function p_end(name)
        if p_data[name] then
            print(('%.5f secs [%s]'):format(os.clock() - p_data[name], name))
        end
    end
    function p_call(name, func, ...)
        p_start(name)
        func(...)
        p_end(name)
    end
else
    function p_start() end
    function p_end() end
    function p_call(name, func, ...) func(...) end
end
p_start('parse')

m_module = m_module or {cache = {}, default_env = {}}
function m_module.load(name, opts)
    if not opts then opts = {} end
    if name:sub(-4) == '.lua' then
        name = name:sub(1, -5)
    end
    name = 'manipulator/' .. name
    p_start('load ' .. name)
    local path = dfhack.findScript(name)
    if not path and not opts.optional then
        error('Could not find script: ' .. name)
    end
    local env = opts.env
    if not env then
        env = m_module.default_env
        clear_table(env)
        setmetatable(env, {__index = _ENV})
    end
    env.manipulator_module = true
    local f
    local cache = m_module.cache[name]
    if cache and path == cache.path and env == cache.env and cache.mtime == dfhack.filesystem.mtime(path) then
        f = cache.callback
    else
        f, err = loadfile(path, 't', env)
        if not f then
            error(('Could not load script "%s": %s'):format(name, err))
        end
        m_module.cache[name] = {
            path = path,
            mtime = dfhack.filesystem.mtime(path),
            callback = f,
            env = env
        }
    end
    f()
    p_end('load ' .. name)
    return env
end

function m_module.autoloader(module_pattern, name_pattern)
    local stub = {}
    if not module_pattern then
        module_pattern = '%s'
    end
    if not name_pattern then
        name_pattern = '%s'
    end
    local function index(self, key)
        local mod = module_pattern
        local name = name_pattern
        if type(mod) == 'function' then
            mod = mod(key)
        else
            mod = mod:format(key)
        end
        if type(name) == 'function' then
            name = name(key)
        else
            name = name:format(key)
        end
        return m_module.load(mod)[name]
    end
    setmetatable(stub, {__index = index})
    return stub
end

m_module.load('grid-config', {env = _ENV})
m_module.load('utils', {env = _ENV})
mgui = m_module.autoloader('gui/%s')

penarray = dfhack.penarray
if not penarray or iargs['--lua-penarray'] then
    penarray = m_module.load('penarray').penarray
end

p_start('validate grid')
for id, col in pairs(SKILL_COLUMNS) do
    check_nil(tonumber(col.group), ('Column %i: Invalid group ID: %s'):format(id, col.group))
    check_nil(tonumber(col.color), ('Column %i: Invalid color ID: %s'):format(id, col.color))
    col.profession = check_nil(df.profession[col.profession], ('Column %i: Unrecognized profession: %s'):format(id, col.profession))
    col.labor = check_nil(df.unit_labor[col.labor], ('Column %i: Unrecognized labor: %s'):format(id, col.labor))
    col.skill = check_nil(df.job_skill[col.skill], ('Column %i: Unrecognized skill: %s'):format(id, col.skill))
    if col.label == nil or type(col.label) ~= 'string' or #tostring(col.label) ~= 2 then
        qerror(('Column %i: Invalid label: %s'):format(id, col.label))
    end
    if col.special == nil then col.special = false end
end

for id, lvl in pairs(SKILL_LEVELS) do
    check_nil(lvl.name, ('Skill level %i: Missing name'):format(id))
    check_nil(tonumber(lvl.points), ('Skill level %i: Invalid points: %s'):format(id, lvl.points))
    lvl.abbr = tostring(check_nil(lvl.abbr, ('Skill level %i: Missing abbreviation'):format(id))):sub(0, 1)
end
p_end('validate grid')

manipulator_columns = defclass(manipulator_columns, gui.FramedScreen)
manipulator_columns.ATTRS = {
    focus_path = 'manipulator/columns',
    frame_title = 'Dwarf Manipulator - Columns',
}

function mkscreen(parent, opts)
    opts = opts or {}
    opts.units = parent.units[parent.page]
    opts.selected = parent.units[parent.page][parent.cursor_pos[parent.page]]
    local scr = mgui.manipulator(opts)
    scr:show()
    return scr
end

function main()
    local scr = dfhack.gui.getCurViewscreen()
    if df.viewscreen_unitlistst:is_instance(scr) then
        cur = mkscreen(scr)
    elseif dfhack.gui.getCurFocus() == 'dwarfmode/Default' then
        gui.simulateInput(scr, 'D_UNITLIST')
        cur = mkscreen(dfhack.gui.getCurViewscreen(), {dismiss_parent = true})
    else
        dfhack.printerr('Invalid context')
    end
end
p_end('parse')
p_call('main', main)
