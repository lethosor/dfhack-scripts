--[[ Lua manipulator column definitions
By default, columns are ordered in the order they appear here

Valid parameters to Column{}:
- callback (required): A function taking a unit and returning an appropriate
         value to be displayed.
- color (required): Either a color ID (e.g. COLOR_WHITE) or a function
        taking a unit and returning an appropriate color.
    NOTE: Use wrap() when using an existing function (e.g. dfhack.units.getProfessionColor)
        to ensure that only the unit is passed to the function.
- title (required): The column title.
- desc: An extended description. Defaults to the value of `title`.
- default: Whether to display the column by default. Defaults to false.
- highlight: Whether to highlight the corresponding row in this column when a
        unit is selected. Defaults to false.
- right_align: Defaults to false.
- max_width: Column maximum width. Defaults to 0 (no maximum width).
]]

Column{
    callback = function(unit)
        return unit.status.current_soul and unit.status.current_soul.personality.stress_level or 0
    end,
    color = function(unit, stress)
        stress = tonumber(stress)
        if stress >= 500000 then return COLOR_LIGHTMAGENTA
        elseif stress >= 250000 then return COLOR_LIGHTRED
        elseif stress >= 100000 then return COLOR_YELLOW
        elseif stress >= 0 then return COLOR_GREEN
        else return COLOR_LIGHTGREEN
        end
    end,
    title = 'Stress',
    default = true,
    right_align = true
}

Column{
    callback = function(unit)
        return dfhack.TranslateName(unit.name)
    end,
    color = COLOR_WHITE,
    title = 'Name',
    default = true,
    highlight = true
}

Column{
    callback = wrap(dfhack.units.getProfessionName),
    color = wrap(dfhack.units.getProfessionColor),
    title = 'Profession',
    default = true
}

Column{
    callback = wrap(dfhack.units.getSquadName),
    color = COLOR_LIGHTCYAN,
    title = 'Squad',
}

Column{
    callback = function(unit)
        return unit.job.current_job and dfhack.job.getName(unit.job.current_job) or 'No Job'
    end,
    color = function(unit)
        return unit.job.current_job and COLOR_LIGHTCYAN or COLOR_YELLOW
    end,
    title = 'Job',
}
