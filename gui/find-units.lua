guidm = require 'gui.dwarfmode'
widgets = require 'gui.widgets'

function getName(unit)
    local name = dfhack.TranslateName(dfhack.units.getVisibleName(unit))
    if name == '' then
        name = dfhack.units.getProfessionName(unit)
    end
    return name
end

UnitSidebar = defclass(UnitSidebar, guidm.MenuOverlay)

function UnitSidebar:init(opts)
    local units = {}
    for _, u in pairs(df.global.world.units.all) do
        table.insert(units, {
            text = getName(u) .. '\n' ..
                   df.tiletype_material[df.tiletype.attrs[dfhack.maps.getTileType(u.pos) or df.tiletype.Void].material],
            pos = xyz2pos(pos2xyz(u.pos)),
        })
    end

    self:addviews{
        widgets.List{
            frame = {t=1, l=1, b=1},
            choices = units,
            row_height = 2,
            scroll_keys = widgets.SECONDSCROLL,
            on_select = function(idx, choice)
                dfhack.gui.revealInDwarfmodeMap(choice.pos)
                df.global.cursor:assign(choice.pos)
            end,
        }
    }
end

function UnitSidebar:onAboutToShow(parent)
    UnitSidebar.super.onAboutToShow(self, parent)
    if df.global.cursor.x == -30000 then
        qerror('A cursor is required')
    end
end

function UnitSidebar:onInput(keys)
    if keys.LEAVESCREEN or keys.LEAVESCREEN_ALL then
        self:dismiss()
        return
    end
    for k in pairs(guidm.MOVEMENT_KEYS) do
        if keys[k] then
            self:sendInputToParent(k)
            return
        end
    end
    self:inputToSubviews(keys)
end

UnitSidebar():show()
