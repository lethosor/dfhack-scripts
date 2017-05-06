-- watch for unknown sidebar/menu modes

seen = seen or {}

function check(var_name, enum_name)
    if not seen[var_name] then
        seen[var_name] = {}
    end
    local var = _G
    for _, part in pairs(var_name:split('.')) do
        var = var[part]
    end
    if seen[var_name][var] then
        return
    end
    local desc = tostring(df[enum_name][var]):lower()
    if desc == 'nil' or desc:sub(1, 4) == 'anon' or desc:sub(1, 3) == 'unk' then
        print(('Found unknown UI mode: %s = %i (%s)'):format(var_name, var, df[enum_name][var]))
    end
    seen[var_name][var] = true
end

function tick()
    if not enabled then return end
    check('df.global.ui.main.mode', 'ui_sidebar_mode')
    check('df.global.ui_advmode.menu', 'ui_advmode_menu')
    dfhack.timeout(10, 'frames', tick)
end

if dfhack_flags and dfhack_flags.enable then
    args = {dfhack_flags.enable_state and 'enable' or 'disable'}
else
    args = {...}
end
if args[1] == 'enable' then
    enabled = true
    tick()
elseif args[1] == 'disable' then
    enabled = false
else
    print('Currently ' .. (enabled and 'enabled' or 'disabled'))
end
