gui = require 'gui'
guidm = require 'gui.dwarfmode'
widgets = require 'gui.widgets'

PlantList = defclass(PlantList, gui.FramedScreen)

function PlantList:init()
    self.filters = {}

    self:addviews{
        widgets.List{
            view_id = 'list',
            text_pen = COLOR_GREEN,
            cursor_pen = COLOR_LIGHTGREEN,
            frame = {l=1, t=1, b=5},
        },
        widgets.Label{
            view_id = 'filters_label',
            text = 'Filters:',
            frame = {l=1, b=3},
        },
        widgets.ToggleLabel{
            text = 'Tree',
            key = 'CUSTOM_T',
            frame = {l=1, b=2},
            allow_off = true,
            on_change = self:callback('changeFilter', 'tree'),
        },
        widgets.ToggleLabel{
            text = 'Shrub',
            key = 'CUSTOM_S',
            frame = {l=14, b=2},
            allow_off = true,
            on_change = self:callback('changeFilter', 'shrub'),
        },
        widgets.ToggleLabel{
            text = 'Watery',
            key = 'CUSTOM_W',
            frame = {l=28, b=2},
            allow_off = true,
            on_change = self:callback('changeFilter', 'watery'),
        },
        widgets.ToggleLabel{
            text = 'Burning',
            key = 'CUSTOM_B',
            frame = {l=43, b=2},
            allow_off = true,
            on_change = self:callback('changeFilter', 'burning'),
        },
        widgets.ToggleLabel{
            text = 'Drowning',
            key = 'CUSTOM_D',
            frame = {l=59, b=2},
            allow_off = true,
            on_change = self:callback('changeFilter', 'drowning'),
        },
        widgets.KeyLabel{
            text = 'Clear Filters',
            key = 'CUSTOM_ALT_C',
            frame = {l=1, b=1},
            on_activate = self:callback('clearFilter'),
        }
    }

    self:generateList()
end

function PlantList:matchFilters(plant)
    if self.filters.tree ~= nil and self.filters.tree ~= (plant.tree_info ~= nil) then
        return false
    end
    if self.filters.shrub ~= nil and self.filters.shrub ~= plant.flags.is_shrub then
        return false
    end
    if self.filters.watery ~= nil and self.filters.watery ~= plant.flags.watery then
        return false
    end
    if self.filters.burning ~= nil and self.filters.burning ~= plant.damage_flags.is_burning then
        return false
    end
    if self.filters.drowning ~= nil and self.filters.drowning ~= plant.damage_flags.is_drowning then
        return false
    end
    return true
end

function PlantList:generateList()
    local choices = {}

    for i, p in pairs(df.global.world.plants.all) do
        if self:matchFilters(p) then
            table.insert(choices, {
                text = ('Plant %d at (%d,%d,%d) %s'):format(i, p.pos.x, p.pos.y, p.pos.z, p.flags.is_shrub and 'Shrub' or 'No'),
                index = i,
            })
        end
    end
    self.subviews.list:setChoices(choices, 1)
    self.subviews.filters_label:setText(('Filters (%d/%d):'):format(#choices, #df.global.world.plants.all))
end

function PlantList:changeFilter(name, value)
    self.filters[name] = value
    self:generateList()
end

function PlantList:clearFilter()
    self.filters = {}
    self:generateList()
    for _, view in pairs(self.subviews) do
        if view.resetState then
            view:resetState()
        end
    end
end

function PlantList:onInput(keys)
    if keys.LEAVESCREEN then
        return self:dismiss()
    elseif keys.SELECT then
        local plant = dfhack.gui.getSelectedPlant(true)
        if plant then
            PlantSidebar{plant=plant}:show()
        end
    end
    self:inputToSubviews(keys)
end

function PlantList:onGetSelectedPlant()
    local _, choice = self.subviews.list:getSelected()
    if choice then
        return df.global.world.plants.all[choice.index]
    end
end


PlantSidebar = defclass(PlantSidebar, guidm.MenuOverlay)

function PlantSidebar:init(args)
    PlantSidebar.super.init(self, args)
    self.plant = args.plant
    self:addviews{
        widgets.KeyLabel{
            key = 'LEAVESCREEN',
            text = 'Back to list',
            frame = {l=1, b=2},
            on_activate = self:callback('dismiss'),
        },
        widgets.KeyLabel{
            key = 'LEAVESCREEN_ALL',
            text = 'Exit to map',
            frame = {l=1, b=1},
            on_activate = self:callback('exitToMap'),
        },
    }
end

function PlantSidebar:onGetSelectedPlant()
    return self.plant
end

function PlantSidebar:onAboutToShow()
    -- skip checks
    df.global.ui.main.mode = df.ui_sidebar_mode.LookAround
    dfhack.gui.revealInDwarfmodeMap(self.plant.pos, true)
    df.global.cursor:assign(xyz2pos(pos2xyz(self.plant.pos)))
end

function PlantSidebar:sendInputToParent(keys)
    gui.simulateInput(dfhack.gui.getViewscreenByType(df.viewscreen_dwarfmodest, 0), keys)
end

function PlantSidebar:renderParent()
    dfhack.gui.getViewscreenByType(df.viewscreen_dwarfmodest, 0):render()
end

function PlantSidebar:render(dc)
    PlantSidebar.super.render(self, dc)
    local p = gui.Painter.new(self.df_layout.menu)
    p:seek(1,1):string('Stuff')
end

function PlantSidebar:onInput(keys)
    for k in pairs(guidm.MOVEMENT_KEYS) do
        if keys[k] then
            self:sendInputToParent(keys)
            return
        end
    end
    self:inputToSubviews(keys)
end

function PlantSidebar:exitToMap()
    dfhack.screen.dismiss(dfhack.gui.getCurViewscreen(), true)
end

PlantList():show()
