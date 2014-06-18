
local gui = require "gui"
local dialog = require 'gui.dialogs'
local widgets = require "gui.widgets"

SETTINGS = {
    init = {
        {id = 'SOUND', type = 'bool', desc = 'Sound enabled'},
        {id = 'VOLUME', type = 'int', desc = 'Volume'},
        {id = 'INTRO', type = 'bool', desc = 'Display intro movies'},
        {id = 'WINDOWED', type = 'select', desc = 'Start in windowed mode',
            choices = {{'YES', 'Yes'}, {'NO', 'No'}, {'PROMPT', 'Prompt'}}
        },
        {id = 'WINDOWEDX', type = 'int', desc = 'Window X dimension (rows)'},
        {id = 'WINDOWEDY', type = 'int', desc = 'Window Y dimension (columns)'},
        {id = 'RESIZABLE', type = 'bool', desc = 'Allow resizing window'},
        {id = 'FONT', type = 'string', desc = 'Font (windowed)', validate = function(s)
            return dfhack.filesystem.exists('data/init/' .. s)
        end},
        
    },
    d_init = {
        
    }
}

BoolPrompt = defclass(BoolPrompt, dialog.MessageBox)

BoolPrompt.ATTRS{
    frame_style = gui.GREY_LINE_FRAME,
    frame_inset = 1,
    on_accept = DEFAULT_NIL,
    on_cancel = DEFAULT_NIL,
    on_close = DEFAULT_NIL,
}
function BoolPrompt:init(info)
    self:addviews{
        widgets.Label{
            view_id = 'label',
            text = {
                {text='Yes', key='CUSTOM_Y', key_sep=':'},
                NEWLINE,
                {text='No', key='CUSTOM_N', key_sep=':'},
            },
            text_pen = info.text_pen,
            frame = {l = 10, t = 10},
            auto_height = true
        }
    }
end

function BoolPrompt:onRenderFrame(dc, rect)
    dialog.MessageBox.super.onRenderFrame(self, dc, rect)
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
        choices = {'a','b','c'},
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
    self.file = choice.text:sub(1, choice.text:find('.', 1, true) - 1)
    self.subviews.pages:setSelected(2)
    self.subviews.settings_list:setChoices(self:get_choice_strings(self.file))
end

function settings_manager:get_choice_strings(file)
    local settings = SETTINGS[file] or error('Invalid settings file: ' .. file)
    local choices = {}
    for i, opt in pairs(settings) do
        table.insert(choices, ('%-40s %s'):format(opt.desc, opt.type))
    end
    return choices
end

function settings_manager:edit_setting(index, choice)
    local setting = SETTINGS[self.file][index]
    if setting.type == 'bool' then
        BoolPrompt{frame_title=setting.desc}:show()
    end
end

function settings_manager:commit_edit(index, value)
    
end

if dfhack.gui.getCurFocus() == 'dfhack/lua' then
    dfhack.screen.dismiss(dfhack.gui.getCurViewscreen())
end
settings_manager():show()
