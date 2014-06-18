
local gui = require "gui"
local dialog = require 'gui.dialogs'
local widgets = require "gui.widgets"

SETTINGS = {
    init = {
        {id = 'SOUND', type = 'bool', desc = 'Sound enabled'},
        {id = 'VOLUME', type = 'int', desc = 'Volume', min = 0, max = 255},
        {id = 'INTRO', type = 'bool', desc = 'Display intro movies'},
        {id = 'WINDOWED', type = 'select', desc = 'Start in windowed mode',
            choices = {{'YES', 'Yes'}, {'PROMPT', 'Prompt'}, {'NO', 'No'}}
        },
        {id = 'WINDOWEDX', type = 'int', desc = 'Window X dimension (rows)'},
        {id = 'WINDOWEDY', type = 'int', desc = 'Window Y dimension (columns)'},
        {id = 'RESIZABLE', type = 'bool', desc = 'Allow resizing window'},
        {id = 'FONT', type = 'string', desc = 'Font (windowed)', validate = function(s)
            return #s > 0 and file_exists('data/art/' .. s)
        end},
        
    },
    d_init = {
        
    }
}

function file_exists(path)
    local f = io.open(path, "r")
    if f ~= nil then io.close(f) return true
    else return false
    end
end

function settings_load()
    for file, settings in pairs(SETTINGS) do
        local contents = io.open('data/init/' .. file .. '.txt'):read('*all')
        for i, s in pairs(settings) do
            local a, b = contents:find('[' .. s.id .. ':', 1, true)
            if a ~= nil then
                s.value = contents:sub(b + 1, contents:find(']', b, true) - 1)
            else
                return false, 'Could not find ' .. s.id .. ' in ' .. file .. '.txt'
            end
        end
    end
    return true
end

function settings_save()
    for file, settings in pairs(SETTINGS) do
        
    end
end

function dialog.showValidationError(str)
    dialog.showMessage('Error', str, COLOR_LIGHTRED)
end

settings_manager = defclass(settings_manager, gui.FramedScreen)

function settings_manager:reset()
    self.frame_title = "Settings"
    self.file = nil
end

function settings_manager:init()
    self:reset()
    local file_list = widgets.List{
        choices = {"init.txt", "d_init.txt"},
        text_pen = {fg = COLOR_GREEN},
        cursor_pen = {fg = COLOR_LIGHTGREEN},
        on_submit = self:callback("select_file"),
        frame = {l = 1, t = 3},
        view_id = "file_list",
    }
    local file_page = widgets.Panel{
        subviews = {
            widgets.Label{
                text = 'File:',
                frame = {l = 1, t = 1},
            },
            file_list,
            widgets.Label{
                text = {
                    {key = 'LEAVESCREEN', text = ': Back'}
                },
                frame = {l = 1, t = 6},
            },
        },
    }
    local settings_list = widgets.List{
        choices = {},
        text_pen = {fg = COLOR_GREEN},
        cursor_pen = {fg = COLOR_LIGHTGREEN},
        on_submit = self:callback("edit_setting"),
        frame = {l = 1, t = 1, b = 3},
        view_id = "settings_list",
    }
    local settings_page = widgets.Panel{
        subviews = {
            settings_list,
            widgets.Label{
                text = {
                    {key = "LEAVESCREEN", text = ": Back"},
                },
                frame = {l = 1, b = 1},
            },
        },
        view_id = "settings_page",
    }
    local pages = widgets.Pages{
        subviews = {file_page, settings_page},
        view_id = "pages"
    }
    self:addviews{
        pages
    }
end

function settings_manager:onInput(keys)
    local page = self.subviews.pages:getSelected()
    if keys.LEAVESCREEN then
        if page == 2 then
            self.subviews.pages:setSelected(1)
            self:reset()
        else
            self:dismiss()
        end
    end
    self.super.onInput(self, keys)
end

function settings_manager:select_file(index, choice)
    local res, err = settings_load()
    if not res then
        dialog.showMessage('Error loading settings', err, COLOR_LIGHTRED, self:callback('dismiss'))
    end
    self.frame_title = choice.text
    self.file = choice.text:sub(1, choice.text:find('.', 1, true) - 1)
    self.subviews.pages:setSelected(2)
    self.subviews.settings_list:setChoices(self:get_choice_strings(self.file))
end

function settings_manager:get_value_string(opt)
    local value_str = '<unknown>'
    if opt.type == 'int' or opt.type == 'string' then
        value_str = opt.value
    elseif opt.type == 'bool' then
        value_str = opt.value:lower():gsub("^%l", string.upper)
    elseif opt.type == 'select' then
        for i, c in pairs(opt.choices) do
            if c[1] == opt.value then
                value_str = c[2]
            end
        end
    end
    return value_str
end

function settings_manager:get_choice_strings(file)
    local settings = SETTINGS[file] or error('Invalid settings file: ' .. file)
    local choices = {}
    for i, opt in pairs(settings) do
        table.insert(choices, ('%-40s %s'):format(opt.desc, self:get_value_string(opt)))
    end
    return choices
end

function settings_manager:edit_setting(index, choice)
    local setting = SETTINGS[self.file][index]
    if setting.type == 'bool' then
        dialog.showListPrompt(
            setting.desc,
            nil,
            COLOR_WHITE,
            {'Yes', 'No'},
            self:callback('commit_edit', index)
        )
    elseif setting.type == 'int' then
        local text = ''
        if setting.min then
            text = text .. 'min: ' .. setting.min
        end
        if setting.max then
            text = text .. ', max: ' .. setting.max
        end
        while text:sub(1, 1) == ' ' or text:sub(1, 1) == ',' do
            text = text:sub(2)
        end
        dialog.showInputPrompt(
            setting.desc,
            text,
            COLOR_WHITE,
            '',
            self:callback('commit_edit', index)
        )
    elseif setting.type == 'string' then
        dialog.showInputPrompt(
            setting.desc,
            nil,
            COLOR_WHITE,
            setting.value,
            self:callback('commit_edit', index)
        )
    elseif setting.type == 'select' then
        local choices = {}
        for i, c in pairs(setting.choices) do
            table.insert(choices, c[2])
        end
        dialog.showListPrompt(
            setting.desc,
            nil,
            COLOR_WHITE,
            choices,
            self:callback('commit_edit', index)
        )
    end
end

function settings_manager:commit_edit(index, value)
    local setting = SETTINGS[self.file][index]
    if setting.type == 'bool' then
        if value == 1 then
            value = 'YES'
        else
            value = 'NO'
        end
    elseif setting.type == 'int' then
        value = tonumber(value)
        if value == nil or value ~= math.floor(value) then
            dialog.showValidationError('Must be a number!')
            return false
        end
        if setting.min and value < setting.min then
            dialog.showValidationError(value .. ' is too low!')
            return false
        end
        if setting.max and value > setting.max then
            dialog.showValidationError(value .. ' is too high!')
            return false
        end
    elseif setting.type == 'string' then
        if setting.validate and not setting.validate(value) then
            dialog.showValidationError('Invalid value')
            return false
        end
    elseif setting.type == 'select' then
        value = setting.choices[value][1]
    end
    print(index, setting.id .. ' =', value)
end

if dfhack.gui.getCurFocus() == 'dfhack/lua' then
    dfhack.screen.dismiss(dfhack.gui.getCurViewscreen())
end
settings_manager():show()
