-- Export current color scheme

exporter = defclass(exporter)
function exporter:init()
    self.print = dfhack.print
end
function exporter:dump()
    self:dump_begin()
    for i = 0, 15 do
        local cc = df.global.enabler.ccolor[i]
        self:dump_color(i, math.floor(cc[0] * 255), math.floor(cc[1] * 255), math.floor(cc[2] * 255))
    end
    self:dump_end()
end

exporter_txt = defclass(exporter_txt, exporter)
exporter_txt.ATTRS.colors = {
    [COLOR_BLACK] = 'BLACK',
    [COLOR_BLUE] = 'BLUE',
    [COLOR_GREEN] = 'GREEN',
    [COLOR_CYAN] = 'CYAN',
    [COLOR_RED] = 'RED',
    [COLOR_MAGENTA] = 'MAGENTA',
    [COLOR_BROWN] = 'BROWN',
    [COLOR_GREY] = 'LGRAY',
    [COLOR_DARKGREY] = 'DGRAY',
    [COLOR_LIGHTBLUE] = 'LBLUE',
    [COLOR_LIGHTGREEN] = 'LGREEN',
    [COLOR_LIGHTCYAN] = 'LCYAN',
    [COLOR_LIGHTRED] = 'LRED',
    [COLOR_LIGHTMAGENTA] = 'LMAGENTA',
    [COLOR_YELLOW] = 'YELLOW',
    [COLOR_WHITE] = 'WHITE',
}
function exporter_txt:dump_begin()
    self.print [[These are the display colors in RGB.  The game is actually displaying extended ASCII characters in OpenGL, so you can modify the colors.

]]
end
function exporter_txt:dump_color(id, ...)
    for i = 1, 3 do
        self.print(('[%s_%s:%i]\n'):format(self.colors[id], ({'R', 'G', 'B'})[i], ({...})[i]))
    end
end
function exporter_txt:dump_end()

end

exporter_wiki = defclass(exporter_wiki, exporter)
exporter_wiki.ATTRS.colors = {
    [COLOR_BLACK] = 'black',
    [COLOR_BLUE] = 'blue',
    [COLOR_GREEN] = 'green',
    [COLOR_CYAN] = 'cyan',
    [COLOR_RED] = 'red',
    [COLOR_MAGENTA] = 'magenta',
    [COLOR_BROWN] = 'brown',
    [COLOR_GREY] = 'lgray',
    [COLOR_DARKGREY] = 'dgray',
    [COLOR_LIGHTBLUE] = 'lblue',
    [COLOR_LIGHTGREEN] = 'lgreen',
    [COLOR_LIGHTCYAN] = 'lcyan',
    [COLOR_LIGHTRED] = 'lred',
    [COLOR_LIGHTMAGENTA] = 'lmagenta',
    [COLOR_YELLOW] = 'yellow',
    [COLOR_WHITE] = 'white',
}

function exporter_wiki:dump_begin()
    self.print('{{color scheme\n')
end

function exporter_wiki:dump_color(id, ...)
    self.print(('|%s=#'):format(self.colors[id]))
    for _, a in pairs({...}) do
        self.print(('%02x'):format(a))
    end
    self.print('\n')
end
function exporter_wiki:dump_end()
    self.print('}}\n')
end

local args = {...}
local format = args[1] or ''
local cls = _ENV['exporter_' .. format]
if cls then
    cls():dump()
else
    qerror('Invalid format: ' .. format)
end
