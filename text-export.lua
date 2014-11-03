-- Converts text on textviewer screens to plain text/markup
-- By Lethosor, based on forum-dwarves.lua (Caldfir, expwnent) and markdown.lua (Mchl)

VERSION = '0.1'

utils = require 'utils'

TAGS = {
    TITLE = {content = true},
    HELP = {params = 1},
    CHAR = {params = 1},
    IKEY = {params = 1},
    C = {params = 3, func = 'color'},
    VAR = {ignore = true},
    LINK = {params = 1, content = true},
    LOCX = {params = 1},
    P = {func = 'newline'},
    R = {func = 'newline'},
    B = {func = 'newline2'},
    PAUSE = {},
    CHOICE = {content = true},
}
COLORS = {
    [COLOR_BLACK] = '#000000',
    [COLOR_DARKGREY] = '#808080',
    [COLOR_BLUE] = '#000080',
    [COLOR_LIGHTBLUE] = '#0000ff',
    [COLOR_GREEN] = '#008000',
    [COLOR_LIGHTGREEN] = '#00ff00',
    [COLOR_CYAN] = '#008080',
    [COLOR_LIGHTCYAN] = '#00ffff',
    [COLOR_RED] = '#800000',
    [COLOR_LIGHTRED] = '#ff0000',
    [COLOR_MAGENTA] = '#800080',
    [COLOR_LIGHTMAGENTA] = '#ff00ff',
    [COLOR_BROWN] = '#808000',
    [COLOR_YELLOW] = '#ffff00',
    [COLOR_GREY] = '#c0c0c0',
    [COLOR_WHITE] = '#ffffff',
}

function getTextViewscreen()
    function test(scr)
        return scr.src_text
    end
    scr = dfhack.gui.getCurViewscreen()
    while scr.parent ~= nil do
        if pcall(test, scr) then return scr end
        scr = scr.parent
    end
    qerror("No text viewer found")
end

Parser = defclass(Parser)
function Parser:parse_begin() return '' end
function Parser:parse_end(text) return text end
function Parser:parse_error(msg, ...)
    return qerror(("Parse error: " .. msg):format(...))
end
function Parser:parse_assert(cond, msg, ...)
    if not cond then
        return self:parse_error(msg, ...)
    end
end
function Parser:title(title) return '' end
function Parser:help(path) return '' end
function Parser:color(fg, bg, bright) return '' end
function Parser:locx(path) return '' end
function Parser:newline() return '\n' end
function Parser:newline2() return '\n\n' end
function Parser:pause() return '' end
function Parser:link(path, text) return text end
function Parser:choice(text) return text end
function Parser:text(text)
    return dfhack.df2utf(text)
end
function Parser:char(ch)
    return dfhack.df2utf(string.char(ch))
end
function Parser:ikey(key)
    key = df.interface_key[key]
    if key ~= nil then
        return dfhack.screen.getKeyDisplay(key)
    else
        return ''
    end
end
function Parser:init()
    self.output = ''
end
function Parser:split_tokens(text)
    local tokens = {}
    local end_pos = 0
    while #text do
        local tag_start = text:find('%[')
        local tag_end = text:find('%]')
        if tag_start == nil or tag_end == nil then
            table.insert(tokens, text)
            break
        end
        table.insert(tokens, text:sub(1, tag_start - 1))
        table.insert(tokens, text:sub(tag_start, tag_end))
        text = text:sub(tag_end + 1)
    end
    return tokens
end
function Parser:parse(input)
    self.output = self:parse_begin()
    function append(text)
        self.output = self.output .. text
    end
    local tokens = self:split_tokens(input)
    local i = 1
    while i <= #tokens do
        token = tokens[i]
        if token == '' then
            -- continue
        elseif token:sub(1, 1) == '[' then
            local tag_params = utils.split_string(token, ']')[1]:sub(2)
            tag_params = utils.split_string(tag_params, ':')
            local tag_name = table.remove(tag_params, 1)
            local tag_info = TAGS[tag_name]
            local params = tag_params  -- callback parameters
            if tag_info ~= nil then
                if tag_info.params then
                    self:parse_assert(#tag_params == tag_info.params,
                        "Invalid parameter count for tag %s: Expected %i, got %i",
                        tag_name, tag_info.params, #tag_params)
                end
                if tag_info.content then
                    -- find closing tag
                    local close_pos = false
                    for j = i, #tokens do
                        if tokens[j] == ('[/%s]'):format(tag_name) then
                            close_pos = j
                            break
                        end
                    end
                    self:parse_assert(close_pos, "Unclosed tag: " .. tag_name)
                    local tag_contents = ''
                    for j = i + 1, close_pos - 1 do
                        tag_contents = tag_contents .. tokens[j]
                    end
                    table.insert(params, tag_contents)
                    i = close_pos
                end
                local callback = tag_info.func or tag_name:lower()
                append(self[callback](self, table.unpack(params)))
            end
        else
            -- text
            append(self:text(token))
        end
        i = i + 1
    end
    self.output = self:parse_end(self.output)
    return self.output
end

Parser_bbcode = defclass(Parser_bbcode, Parser)

function Parser_bbcode:parse_begin()
    return self:color(COLOR_GREY, 0, 0)
end

function Parser_bbcode:parse_end(text)
    text = text:gsub('\n +', '\n')
    return text
end

function Parser_bbcode:color(fg, bg, br)
    self.last_color = {fg, bg, br}
    local out = ''
    fg = tonumber(fg) + (tonumber(br) == 1 and 8 or 0)
    if self.output:find('%[color') then
        out = out .. '[/color]'
    end
    out = out .. ('[color=%s]'):format(COLORS[fg])
    return out
end

function Parser_bbcode:link(dest, text)
    local old_color = self.last_color
    return self:color(COLOR_CYAN, 0, 0) .. '\n' ..  text .. '\n' ..
        self:color(table.unpack(old_color))
end

function Parser_bbcode:newline2()
    return '\n'
end

-- Script logic
scr = getTextViewscreen()
args = utils.processArgs({...})
format = string.lower(args['format'] or qerror('No format specified'))
parser_class = _ENV['Parser_' .. format]
if parser_class == nil then
    qerror('Unrecognized format: ' .. format)
end
parser = parser_class()
src_text = ''
for i = 1, #scr.src_text - 1 do  -- skip line 0 (filename or empty)
    src_text = src_text .. scr.src_text[i].value .. ' '
end
print(parser:parse(src_text))
