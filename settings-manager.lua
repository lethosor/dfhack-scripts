
local gui = require "gui"
local widgets = require "gui.widgets"

SETTINGS = {
    init = {
        
    },
    d_init = {
        
    }
}

settings_manager = defclass(settings_manager, gui.FramedScreen)

function settings_manager:reset()
    self.frame_title = "Settings"
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
        frame = {l = 1, t = 1},
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
    page = self.subviews.pages:getSelected()
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
    self.subviews.pages:setSelected(2)
    self.subviews.settings_list:setChoices({choice.text})
    self.frame_title = choice.text
end

function settings_manager:edit_setting(index, choice)
    
end

if dfhack.gui.getCurFocus() == 'dfhack/lua' then
    dfhack.screen.dismiss(dfhack.gui.getCurViewscreen())
end
settings_manager():show()
