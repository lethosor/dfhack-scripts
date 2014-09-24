-- An in-game init file editor
--[[ By Lethosor
Sample usage:
    keybinding add Alt-S@title settings-manager
    keybinding add Alt-S@dwarfmode/Default settings-manager

Last tested on 0.40.13-r1
]]

VERSION = '0.5.2'

local gui = require "gui"
local dialog = require 'gui.dialogs'
local widgets = require "gui.widgets"

-- settings-manager display settings
ui_settings = {
    color = COLOR_GREEN,
    highlightcolor = COLOR_LIGHTGREEN,
}

ANNC_FLAGS = {
    {id = 'D_D', in_game = 'D_DISPLAY', short = 'Dwf'},
    {id = 'A_D', in_game = 'A_DISPLAY', short = 'Adv'},
    {id = 'BOX', in_game = 'DO_MEGA', short = 'Box'},
    {id = 'P', in_game = 'PAUSE', short = 'Pause'},
    {id = 'R', in_game = 'RECENTER', short = 'Rec'},
    {id = 'UCR', in_game = 'UNIT_COMBAT_REPORT', short = 'Rep'},
    {id = 'UCR_A', in_game = 'UNIT_COMBAT_REPORT_ALL_ACTIVE', short = 'ActRep'},
}

annc_header_text = ''
for _, annc in pairs(ANNC_FLAGS) do
    annc_header_text = annc_header_text .. annc.short .. ' '
end
annc_header_text = annc_header_text:sub(0, -1)

annc_flags = defclass(annc_flags)
function annc_flags:init()
end

function annc_to_string(raw)
    flags = raw:split(':')
    for _, flag in pairs(flags) do
        --for _, annc in 
    end
    return raw
end

function dup_table(tbl)
    -- Given {a, b, c}, returns {{a, a}, {b, b}, {c, c}}
    local t = {}
    for i = 1, #tbl do
        table.insert(t, {tbl[i], tbl[i]})
    end
    return t
end

function set_variable(name, value)
    -- Sets a global variable specified by 'name' to 'value'
    local parts = name:split('.')
    local last_field = table.remove(parts, #parts)
    parent = _G
    for _, field in pairs(parts) do
        parent = parent[field]
    end
    parent[last_field] = value
end

-- Validation, used in FONT, FULLFONT, GRAPHICS_FONT, and GRAPHICS_FULLFONT
function font_exists(font)
    if font ~= '' and file_exists('data/art/' .. font) then
        return true
    else
        return false, '"' .. font .. '" does not exist'
    end
end

-- Used in NICKNAME_DWARF, NICKNAME_ADVENTURE, and NICKNAME_LEGENDS
local nickname_choices = {
    {'REPLACE_FIRST', 'Replace first name'},
    {'CENTRALIZE', 'Display between first and last name'},
    {'REPLACE_ALL', 'Replace entire name'}
}

-- Used in PRINT_MODE
local print_modes = {
    {'2D', '2D (default)'}, {'2DSW', '2DSW'}, {'2DASYNC', '2DASYNC'},
    {'STANDARD', 'STANDARD (OpenGL)'}, {'PROMPT', 'Prompt (STANDARD/2D)'},
    {'ACCUM_BUFFER', 'ACCUM_BUFFER'}, {'FRAME_BUFFER', 'FRAME_BUFFER'}, {'VBO', 'VBO'}
}
if dfhack.getOSType() == 'linux' then
    table.insert(print_modes, {'TEXT', 'TEXT (ncurses)'})
end

--[[
Setting descriptions

Settings listed MUST exist, but settings not listed will be ignored

Fields:
- id: "Tag name" in file (e.g. [id:params])
- type: Data type (used for entry). Valid choices:
  - 'bool' - boolean - "Yes" and "No", saved as "YES" and "NO"
  - 'int' - integer
  - 'string'
  - 'select' - string input restricted to the values given in the 'choices' field
- desc: Human-readable description
    '>>' is converted to string.char(192) .. ' '
- min (optional): Minimum
    Requires type 'int'
- max (optional): Maximum
    Requires type 'int'
- choices: A list of valid options
    Requires type 'select'
    Each choice should be a table of the following format:
    { "RAW_VALUE", "Human-readable value" [, "Enum value"] }
- validate (optional): Function that recieves string as input, should return true or false
    Requires type 'string'
- in_game (optional): Value to modify to change setting in-game (as a string)
    For type 'select', requires 'enum' to be specified
- enum: Enum to convert string setting values to in-game (numeric) values
    Uses "Enum value" specified in 'choices', or "RAW_VALUE" if not specified

Reserved field names:
- value (set to current setting value when settings are loaded)
]]
SETTINGS = {
    init = {
        {id = 'SOUND', type = 'bool', desc = 'Enable sound'},
        {id = 'VOLUME', type = 'int', desc = '>>Volume', min = 0, max = 255},
        {id = 'INTRO', type = 'bool', desc = 'Display intro movies'},
        {id = 'WINDOWED', type = 'select', desc = 'Start in windowed mode',
            choices = {{'YES', 'Yes'}, {'PROMPT', 'Prompt'}, {'NO', 'No'}}
        },
        {id = 'WINDOWEDX', type = 'int', desc = 'Windowed X dimension (columns)', min = 80},
        {id = 'WINDOWEDY', type = 'int', desc = 'Windowed Y dimension (rows)', min = 25},
        {id = 'RESIZABLE', type = 'bool', desc = 'Allow resizing window'},
        {id = 'FONT', type = 'string', desc = 'Font (windowed)', validate = font_exists},
        {id = 'FULLSCREENX', type = 'int', desc = 'Fullscreen X dimension (columns)', min = 0},
        {id = 'FULLSCREENY', type = 'int', desc = 'Fullscreen Y dimension (rows)', min = 0},
        {id = 'FULLFONT', type = 'string', desc = 'Font (fullscreen)', validate = font_exists},
        {id = 'BLACK_SPACE', type = 'select', desc = 'Mismatched resolution behavior',
            choices = {{'YES', 'Pad with black space'}, {'NO', 'Stretch tiles'}}
        },
        {id = 'GRAPHICS', type = 'bool', desc = 'Enable graphics'},
        {id = 'GRAPHICS_WINDOWEDX', type = 'int', desc = '>>Windowed X dimension (columns)', min = 80},
        {id = 'GRAPHICS_WINDOWEDY', type = 'int', desc = '>>Windowed Y dimension (rows)', min = 25},
        {id = 'GRAPHICS_FONT', type = 'string', desc = '>>Font (windowed)', validate = font_exists},
        {id = 'GRAPHICS_FULLSCREENX', type = 'int', desc = '>>Fullscreen X dimension (columns)', min = 0},
        {id = 'GRAPHICS_FULLSCREENY', type = 'int', desc = '>>Fullscreen Y dimension (rows)', min = 0},
        {id = 'GRAPHICS_FULLFONT', type = 'string', desc = '>>Font (fullscreen)', validate = font_exists},

        {id = 'PRINT_MODE', type = 'select', desc = 'Print mode', choices = print_modes},
        {id = 'SINGLE_BUFFER', type = 'bool', desc = '>>Single-buffer'},
        {id = 'ARB_SYNC', type = 'bool', desc = '>>Enable ARB_sync (unstable)'},
        {id = 'VSYNC', type = 'bool', desc = '>>Enable vertical synchronization'},
        {id = 'TEXTURE_PARAM', type = 'select', desc = '>>Texture value behavior', choices = {
            {'NEAREST', 'Use nearest pixel'}, {'LINEAR', 'Average over adjacent pixels'}
        }},

        {id = 'TOPMOST', type = 'bool', desc = 'Make DF topmost window'},
        {id = 'FPS', type = 'bool', desc = 'Show FPS indicator',
            in_game = 'df.global.gps.display_frames',
            in_game_type = 'int',
        },
        {id = 'FPS_CAP', type = 'int', desc = 'Computational FPS cap', min = 1,
            in_game = 'df.global.enabler.fps', -- can't be set to 0
        },
        {id = 'G_FPS_CAP', type = 'int', desc = 'Graphical FPS cap', min = 1,
            in_game = 'df.global.enabler.gfps',
        },

        {id = 'PRIORITY', type = 'select', desc = 'Process priority',
            choices = dup_table({'REALTIME', 'HIGH', 'ABOVE_NORMAL', 'NORMAL', 'BELOW_NORMAL', 'IDLE'})
        },

        {id = 'ZOOM_SPEED', type = 'int', desc = 'Zoom speed', min = 1},
        {id = 'MOUSE', type = 'bool', desc = 'Enable mouse'},
        {id = 'MOUSE_PICTURE', type = 'bool', desc = '>>Use custom cursor'},

        {id = 'KEY_HOLD_MS', type = 'int', desc = 'Key repeat delay (ms)'},
        {id = 'KEY_REPEAT_ACCEL_LIMIT', type = 'int', desc = '>>Maximum key acceleration (multiple)', min = 1},
        {id = 'KEY_REPEAT_ACCEL_START', type = 'int', desc = '>>Key acceleration delay', min = 1},
        {id = 'MACRO_MS', type = 'int', desc = 'Macro instruction delay (ms)', min = 0},
        {id = 'RECENTER_INTERFACE_SHUTDOWN_MS', type = 'int', desc = 'Delay after recentering (ms)', min = 0},

        {id = 'COMPRESSED_SAVES', type = 'bool', desc = 'Enable compressed saves'},
    },
    d_init = {
        {id = 'AUTOSAVE', type = 'select', desc = 'Autosave', choices = {
            {'NONE', 'Disabled'}, {'SEASONAL', 'Seasonal'}, {'YEARLY', 'Yearly'}
        }},
        {id = 'AUTOBACKUP', type = 'bool', desc = 'Make backup copies of automatic saves'},
        {id = 'AUTOSAVE_PAUSE', type = 'bool', desc = 'Pause after autosaving'},
        {id = 'INITIAL_SAVE', type = 'bool', desc = 'Save after embarking'},
        {id = 'EMBARK_WARNING_ALWAYS', type = 'bool', desc = 'Always prompt before embark'},
        {id = 'SHOW_EMBARK_TUNNEL', type = 'select', desc = 'Local feature visibility', choices = {
            {'ALWAYS', 'Always'}, {'FINDER', 'Only in site finder'}, {'NO', 'Never'}
        }},

        {id = 'TEMPERATURE', type = 'bool', desc = 'Enable temperature'},
        {id = 'WEATHER', type = 'bool', desc = 'Enable weather'},
        {id = 'INVADERS', type = 'bool', desc = 'Enable invaders'},
        {id = 'CAVEINS', type = 'bool', desc = 'Enable cave-ins'},
        {id = 'ARTIFACTS', type = 'bool', desc = 'Enable artifacts'},
        {id = 'TESTING_ARENA', type = 'bool', desc = 'Enable object testing arena'},
        {id = 'WALKING_SPREADS_SPATTER_DWF', type = 'bool', desc = 'Walking spreads spatter (fort mode)'},
        {id = 'WALKING_SPREADS_SPATTER_ADV', type = 'bool', desc = 'Walking spreads spatter (adv mode)'},

        {id = 'LOG_MAP_REJECTS', type = 'bool', desc = 'Log map rejects'},
        {id = 'EMBARK_RECTANGLE', type = 'string', desc = 'Default embark size (x:y)', validate = function(s)
            local parts = s:split(':')
            if #parts == 2 then
                a, b = tonumber(parts[1]), tonumber(parts[2])
                if a~= nil and b ~= nil and a >= 2 and a <= 16 and b >= 2 and b <= 16 then
                    return true
                end
            else
                return false, 'Must be in format "x:y"'
            end
            return false, 'Dimensions must be integers\nbetween 2 and 16'
        end},
        {id = 'IDLERS', type = 'select', desc = 'Idlers indicator (fortress mode)', choices = {
            {'TOP', 'Top'}, {'BOTTOM', 'Bottom'}, {'OFF', 'Disabled'}
        }},
        {id = 'SET_LABOR_LISTS', type = 'select', desc = 'Automatically set labors', choices = {
            {'SKILLS', 'By skill'}, {'BY_UNIT_TYPE', 'By unit type'}, {'NO', 'Disabled'}
        }},
        {id = 'POPULATION_CAP', type = 'int', desc = 'Population cap', min = 0},
        {id = 'VARIED_GROUND_TILES', type = 'bool', desc = 'Varied ground tiles'},
        {id = 'ENGRAVINGS_START_OBSCURED', type = 'bool', desc = 'Obscure engravings by default'},
        {id = 'SHOW_IMP_QUALITY', type = 'bool', desc = 'Show item quality indicators'},
        {id = 'SHOW_FLOW_AMOUNTS', type = 'select', desc = 'Liquid display', choices = {
            {'NO', 'Symbols (' .. string.char(247) .. ')'}, {'YES', 'Numbers (1-7)'}
        }},
        {id = 'SHOW_ALL_HISTORY_IN_DWARF_MODE', type = 'bool', desc = 'Show all history (fortress mode)'},
        {id = 'DISPLAY_LENGTH', type = 'int', desc = 'Announcement display length (adv mode)', min = 1},
        {id = 'MORE', type = 'bool', desc = '>>"More" indicator'},
        {id = 'ADVENTURER_TRAPS', type = 'bool', desc = 'Enable traps in adventure mode'},
        {id = 'ADVENTURER_ALWAYS_CENTER', type = 'bool', desc = 'Center screen on adventurer'},
        {id = 'NICKNAME_DWARF', type = 'select', desc = 'Nickname behavior (fortress mode)', choices = nickname_choices},
        {id = 'NICKNAME_ADVENTURE', type = 'select', desc = 'Nickname behavior (adventure mode)', choices = nickname_choices},
        {id = 'NICKNAME_LEGENDS', type = 'select', desc = 'Nickname behavior (legends mode)', choices = nickname_choices},
    },
    announcements = {
        {id = 'REACHED_PEAK', type = 'annc', desc = 'REACHED_PEAK'},
        {id = 'ERA_CHANGE', type = 'annc', desc = 'ERA_CHANGE'},
        {id = 'ENDGAME_EVENT_1', type = 'annc', desc = 'ENDGAME_EVENT_1'},
        {id = 'ENDGAME_EVENT_2', type = 'annc', desc = 'ENDGAME_EVENT_2'},
        {id = 'FEATURE_DISCOVERY', type = 'annc', desc = 'FEATURE_DISCOVERY'},
        {id = 'STRUCK_DEEP_METAL', type = 'annc', desc = 'STRUCK_DEEP_METAL'},
        {id = 'STRUCK_MINERAL', type = 'annc', desc = 'STRUCK_MINERAL'},
        {id = 'STRUCK_ECONOMIC_MINERAL', type = 'annc', desc = 'STRUCK_ECONOMIC_MINERAL'},
        {id = 'COMBAT_TWIST_WEAPON', type = 'annc', desc = 'COMBAT_TWIST_WEAPON'},
        {id = 'COMBAT_LET_ITEM_DROP', type = 'annc', desc = 'COMBAT_LET_ITEM_DROP'},
        {id = 'COMBAT_START_CHARGE', type = 'annc', desc = 'COMBAT_START_CHARGE'},
        {id = 'COMBAT_SURPRISE_CHARGE', type = 'annc', desc = 'COMBAT_SURPRISE_CHARGE'},
        {id = 'COMBAT_JUMP_DODGE_PROJ', type = 'annc', desc = 'COMBAT_JUMP_DODGE_PROJ'},
        {id = 'COMBAT_JUMP_DODGE_STRIKE', type = 'annc', desc = 'COMBAT_JUMP_DODGE_STRIKE'},
        {id = 'COMBAT_DODGE', type = 'annc', desc = 'COMBAT_DODGE'},
        {id = 'COMBAT_COUNTERSTRIKE', type = 'annc', desc = 'COMBAT_COUNTERSTRIKE'},
        {id = 'COMBAT_BLOCK', type = 'annc', desc = 'COMBAT_BLOCK'},
        {id = 'COMBAT_PARRY', type = 'annc', desc = 'COMBAT_PARRY'},
        {id = 'COMBAT_CHARGE_COLLISION', type = 'annc', desc = 'COMBAT_CHARGE_COLLISION'},
        {id = 'COMBAT_CHARGE_DEFENDER_TUMBLES', type = 'annc', desc = 'COMBAT_CHARGE_DEFENDER_TUMBLES'},
        {id = 'COMBAT_CHARGE_DEFENDER_KNOCKED_OVER', type = 'annc', desc = 'COMBAT_CHARGE_DEFENDER_KNOCKED_OVER'},
        {id = 'COMBAT_CHARGE_ATTACKER_TUMBLES', type = 'annc', desc = 'COMBAT_CHARGE_ATTACKER_TUMBLES'},
        {id = 'COMBAT_CHARGE_ATTACKER_BOUNCE_BACK', type = 'annc', desc = 'COMBAT_CHARGE_ATTACKER_BOUNCE_BACK'},
        {id = 'COMBAT_CHARGE_TANGLE_TOGETHER', type = 'annc', desc = 'COMBAT_CHARGE_TANGLE_TOGETHER'},
        {id = 'COMBAT_CHARGE_TANGLE_TUMBLE', type = 'annc', desc = 'COMBAT_CHARGE_TANGLE_TUMBLE'},
        {id = 'COMBAT_CHARGE_RUSH_BY', type = 'annc', desc = 'COMBAT_CHARGE_RUSH_BY'},
        {id = 'COMBAT_CHARGE_MANAGE_STOP', type = 'annc', desc = 'COMBAT_CHARGE_MANAGE_STOP'},
        {id = 'COMBAT_CHARGE_OBSTACLE_SLAM', type = 'annc', desc = 'COMBAT_CHARGE_OBSTACLE_SLAM'},
        {id = 'COMBAT_WRESTLE_LOCK', type = 'annc', desc = 'COMBAT_WRESTLE_LOCK'},
        {id = 'COMBAT_WRESTLE_CHOKEHOLD', type = 'annc', desc = 'COMBAT_WRESTLE_CHOKEHOLD'},
        {id = 'COMBAT_WRESTLE_TAKEDOWN', type = 'annc', desc = 'COMBAT_WRESTLE_TAKEDOWN'},
        {id = 'COMBAT_WRESTLE_THROW', type = 'annc', desc = 'COMBAT_WRESTLE_THROW'},
        {id = 'COMBAT_WRESTLE_RELEASE_LOCK', type = 'annc', desc = 'COMBAT_WRESTLE_RELEASE_LOCK'},
        {id = 'COMBAT_WRESTLE_RELEASE_CHOKE', type = 'annc', desc = 'COMBAT_WRESTLE_RELEASE_CHOKE'},
        {id = 'COMBAT_WRESTLE_RELEASE_GRIP', type = 'annc', desc = 'COMBAT_WRESTLE_RELEASE_GRIP'},
        {id = 'COMBAT_WRESTLE_STRUGGLE', type = 'annc', desc = 'COMBAT_WRESTLE_STRUGGLE'},
        {id = 'COMBAT_WRESTLE_RELEASE_LATCH', type = 'annc', desc = 'COMBAT_WRESTLE_RELEASE_LATCH'},
        {id = 'COMBAT_WRESTLE_STRANGLE_KO', type = 'annc', desc = 'COMBAT_WRESTLE_STRANGLE_KO'},
        {id = 'COMBAT_WRESTLE_ADJUST_GRIP', type = 'annc', desc = 'COMBAT_WRESTLE_ADJUST_GRIP'},
        {id = 'COMBAT_GRAB_TEAR', type = 'annc', desc = 'COMBAT_GRAB_TEAR'},
        {id = 'COMBAT_STRIKE_DETAILS', type = 'annc', desc = 'COMBAT_STRIKE_DETAILS'},
        {id = 'COMBAT_STRIKE_DETAILS_2', type = 'annc', desc = 'COMBAT_STRIKE_DETAILS_2'},
        {id = 'COMBAT_EVENT_ENRAGED', type = 'annc', desc = 'COMBAT_EVENT_ENRAGED'},
        {id = 'COMBAT_EVENT_STUCKIN', type = 'annc', desc = 'COMBAT_EVENT_STUCKIN'},
        {id = 'COMBAT_EVENT_LATCH_BP', type = 'annc', desc = 'COMBAT_EVENT_LATCH_BP'},
        {id = 'COMBAT_EVENT_LATCH_GENERAL', type = 'annc', desc = 'COMBAT_EVENT_LATCH_GENERAL'},
        {id = 'COMBAT_EVENT_PROPELLED_AWAY', type = 'annc', desc = 'COMBAT_EVENT_PROPELLED_AWAY'},
        {id = 'COMBAT_EVENT_KNOCKED_OUT', type = 'annc', desc = 'COMBAT_EVENT_KNOCKED_OUT'},
        {id = 'COMBAT_EVENT_STUNNED', type = 'annc', desc = 'COMBAT_EVENT_STUNNED'},
        {id = 'COMBAT_EVENT_WINDED', type = 'annc', desc = 'COMBAT_EVENT_WINDED'},
        {id = 'COMBAT_EVENT_NAUSEATED', type = 'annc', desc = 'COMBAT_EVENT_NAUSEATED'},
        {id = 'MIGRANT_ARRIVAL_NAMED', type = 'annc', desc = 'MIGRANT_ARRIVAL_NAMED'},
        {id = 'MIGRANT_ARRIVAL', type = 'annc', desc = 'MIGRANT_ARRIVAL'},
        {id = 'DIG_CANCEL_WARM', type = 'annc', desc = 'DIG_CANCEL_WARM'},
        {id = 'DIG_CANCEL_DAMP', type = 'annc', desc = 'DIG_CANCEL_DAMP'},
        {id = 'AMBUSH_DEFENDER', type = 'annc', desc = 'AMBUSH_DEFENDER'},
        {id = 'AMBUSH_RESIDENT', type = 'annc', desc = 'AMBUSH_RESIDENT'},
        {id = 'AMBUSH_THIEF', type = 'annc', desc = 'AMBUSH_THIEF'},
        {id = 'AMBUSH_THIEF_SUPPORT_SKULKING', type = 'annc', desc = 'AMBUSH_THIEF_SUPPORT_SKULKING'},
        {id = 'AMBUSH_THIEF_SUPPORT_NATURE', type = 'annc', desc = 'AMBUSH_THIEF_SUPPORT_NATURE'},
        {id = 'AMBUSH_THIEF_SUPPORT', type = 'annc', desc = 'AMBUSH_THIEF_SUPPORT'},
        {id = 'AMBUSH_MISCHIEVOUS', type = 'annc', desc = 'AMBUSH_MISCHIEVOUS'},
        {id = 'AMBUSH_SNATCHER', type = 'annc', desc = 'AMBUSH_SNATCHER'},
        {id = 'AMBUSH_SNATCHER_SUPPORT', type = 'annc', desc = 'AMBUSH_SNATCHER_SUPPORT'},
        {id = 'AMBUSH_AMBUSHER_NATURE', type = 'annc', desc = 'AMBUSH_AMBUSHER_NATURE'},
        {id = 'AMBUSH_AMBUSHER', type = 'annc', desc = 'AMBUSH_AMBUSHER'},
        {id = 'AMBUSH_INJURED', type = 'annc', desc = 'AMBUSH_INJURED'},
        {id = 'AMBUSH_OTHER', type = 'annc', desc = 'AMBUSH_OTHER'},
        {id = 'AMBUSH_INCAPACITATED', type = 'annc', desc = 'AMBUSH_INCAPACITATED'},
        {id = 'CARAVAN_ARRIVAL', type = 'annc', desc = 'CARAVAN_ARRIVAL'},
        {id = 'NOBLE_ARRIVAL', type = 'annc', desc = 'NOBLE_ARRIVAL'},
        {id = 'D_MIGRANTS_ARRIVAL', type = 'annc', desc = 'D_MIGRANTS_ARRIVAL'},
        {id = 'D_MIGRANT_ARRIVAL', type = 'annc', desc = 'D_MIGRANT_ARRIVAL'},
        {id = 'D_MIGRANT_ARRIVAL_DISCOURAGED', type = 'annc', desc = 'D_MIGRANT_ARRIVAL_DISCOURAGED'},
        {id = 'D_NO_MIGRANT_ARRIVAL', type = 'annc', desc = 'D_NO_MIGRANT_ARRIVAL'},
        {id = 'ANIMAL_TRAP_CATCH', type = 'annc', desc = 'ANIMAL_TRAP_CATCH'},
        {id = 'ANIMAL_TRAP_ROBBED', type = 'annc', desc = 'ANIMAL_TRAP_ROBBED'},
        {id = 'MISCHIEF_LEVER', type = 'annc', desc = 'MISCHIEF_LEVER'},
        {id = 'MISCHIEF_PLATE', type = 'annc', desc = 'MISCHIEF_PLATE'},
        {id = 'MISCHIEF_CAGE', type = 'annc', desc = 'MISCHIEF_CAGE'},
        {id = 'MISCHIEF_CHAIN', type = 'annc', desc = 'MISCHIEF_CHAIN'},
        {id = 'DIPLOMAT_ARRIVAL', type = 'annc', desc = 'DIPLOMAT_ARRIVAL'},
        {id = 'LIAISON_ARRIVAL', type = 'annc', desc = 'LIAISON_ARRIVAL'},
        {id = 'TRADE_DIPLOMAT_ARRIVAL', type = 'annc', desc = 'TRADE_DIPLOMAT_ARRIVAL'},
        {id = 'CAVE_COLLAPSE', type = 'annc', desc = 'CAVE_COLLAPSE'},
        {id = 'BIRTH_CITIZEN', type = 'annc', desc = 'BIRTH_CITIZEN'},
        {id = 'BIRTH_ANIMAL', type = 'annc', desc = 'BIRTH_ANIMAL'},
        {id = 'BIRTH_WILD_ANIMAL', type = 'annc', desc = 'BIRTH_WILD_ANIMAL'},
        {id = 'STRANGE_MOOD', type = 'annc', desc = 'STRANGE_MOOD'},
        {id = 'MADE_ARTIFACT', type = 'annc', desc = 'MADE_ARTIFACT'},
        {id = 'NAMED_ARTIFACT', type = 'annc', desc = 'NAMED_ARTIFACT'},
        {id = 'ITEM_ATTACHMENT', type = 'annc', desc = 'ITEM_ATTACHMENT'},
        {id = 'VERMIN_CAGE_ESCAPE', type = 'annc', desc = 'VERMIN_CAGE_ESCAPE'},
        {id = 'TRIGGER_WEB', type = 'annc', desc = 'TRIGGER_WEB'},
        {id = 'MOOD_BUILDING_CLAIMED', type = 'annc', desc = 'MOOD_BUILDING_CLAIMED'},
        {id = 'ARTIFACT_BEGUN', type = 'annc', desc = 'ARTIFACT_BEGUN'},
        {id = 'MEGABEAST_ARRIVAL', type = 'annc', desc = 'MEGABEAST_ARRIVAL'},
        {id = 'BERSERK_CITIZEN', type = 'annc', desc = 'BERSERK_CITIZEN'},
        {id = 'MAGMA_DEFACES_ENGRAVING', type = 'annc', desc = 'MAGMA_DEFACES_ENGRAVING'},
        {id = 'ENGRAVING_MELTS', type = 'annc', desc = 'ENGRAVING_MELTS'},
        {id = 'MASTERPIECE_ARCHITECTURE', type = 'annc', desc = 'MASTERPIECE_ARCHITECTURE'},
        {id = 'MASTERPIECE_CONSTRUCTION', type = 'annc', desc = 'MASTERPIECE_CONSTRUCTION'},
        {id = 'MASTER_ARCHITECTURE_LOST', type = 'annc', desc = 'MASTER_ARCHITECTURE_LOST'},
        {id = 'MASTER_CONSTRUCTION_LOST', type = 'annc', desc = 'MASTER_CONSTRUCTION_LOST'},
        {id = 'ADV_AWAKEN', type = 'annc', desc = 'ADV_AWAKEN'},
        {id = 'ADV_SLEEP_INTERRUPTED', type = 'annc', desc = 'ADV_SLEEP_INTERRUPTED'},
        {id = 'ADV_REACTION_PRODUCTS', type = 'annc', desc = 'ADV_REACTION_PRODUCTS'},
        {id = 'CANCEL_JOB', type = 'annc', desc = 'CANCEL_JOB'},
        {id = 'ADV_CREATURE_DEATH', type = 'annc', desc = 'ADV_CREATURE_DEATH'},
        {id = 'CITIZEN_DEATH', type = 'annc', desc = 'CITIZEN_DEATH'},
        {id = 'PET_DEATH', type = 'annc', desc = 'PET_DEATH'},
        {id = 'FALL_OVER', type = 'annc', desc = 'FALL_OVER'},
        {id = 'CAUGHT_IN_FLAMES', type = 'annc', desc = 'CAUGHT_IN_FLAMES'},
        {id = 'CAUGHT_IN_WEB', type = 'annc', desc = 'CAUGHT_IN_WEB'},
        {id = 'UNIT_PROJECTILE_SLAM_BLOW_APART', type = 'annc', desc = 'UNIT_PROJECTILE_SLAM_BLOW_APART'},
        {id = 'UNIT_PROJECTILE_SLAM', type = 'annc', desc = 'UNIT_PROJECTILE_SLAM'},
        {id = 'UNIT_PROJECTILE_SLAM_INTO_UNIT', type = 'annc', desc = 'UNIT_PROJECTILE_SLAM_INTO_UNIT'},
        {id = 'VOMIT', type = 'annc', desc = 'VOMIT'},
        {id = 'LOSE_HOLD_OF_ITEM', type = 'annc', desc = 'LOSE_HOLD_OF_ITEM'},
        {id = 'REGAIN_CONSCIOUSNESS', type = 'annc', desc = 'REGAIN_CONSCIOUSNESS'},
        {id = 'FREE_FROM_WEB', type = 'annc', desc = 'FREE_FROM_WEB'},
        {id = 'PARALYZED', type = 'annc', desc = 'PARALYZED'},
        {id = 'OVERCOME_PARALYSIS', type = 'annc', desc = 'OVERCOME_PARALYSIS'},
        {id = 'NOT_STUNNED', type = 'annc', desc = 'NOT_STUNNED'},
        {id = 'EXHAUSTION', type = 'annc', desc = 'EXHAUSTION'},
        {id = 'PAIN_KO', type = 'annc', desc = 'PAIN_KO'},
        {id = 'BREAK_GRIP', type = 'annc', desc = 'BREAK_GRIP'},
        {id = 'NO_BREAK_GRIP', type = 'annc', desc = 'NO_BREAK_GRIP'},
        {id = 'BLOCK_FIRE', type = 'annc', desc = 'BLOCK_FIRE'},
        {id = 'BREATHE_FIRE', type = 'annc', desc = 'BREATHE_FIRE'},
        {id = 'SHOOT_WEB', type = 'annc', desc = 'SHOOT_WEB'},
        {id = 'PULL_OUT_DROP', type = 'annc', desc = 'PULL_OUT_DROP'},
        {id = 'STAND_UP', type = 'annc', desc = 'STAND_UP'},
        {id = 'MARTIAL_TRANCE', type = 'annc', desc = 'MARTIAL_TRANCE'},
        {id = 'MAT_BREATH', type = 'annc', desc = 'MAT_BREATH'},
        {id = 'NIGHT_ATTACK_STARTS', type = 'annc', desc = 'NIGHT_ATTACK_STARTS'},
        {id = 'NIGHT_ATTACK_ENDS', type = 'annc', desc = 'NIGHT_ATTACK_ENDS'},
        {id = 'NIGHT_ATTACK_TRAVEL', type = 'annc', desc = 'NIGHT_ATTACK_TRAVEL'},
        {id = 'GHOST_ATTACK', type = 'annc', desc = 'GHOST_ATTACK'},
        {id = 'TRAVEL_SITE_DISCOVERY', type = 'annc', desc = 'TRAVEL_SITE_DISCOVERY'},
        {id = 'TRAVEL_SITE_BUMP', type = 'annc', desc = 'TRAVEL_SITE_BUMP'},
        {id = 'ADVENTURE_INTRO', type = 'annc', desc = 'ADVENTURE_INTRO'},
        {id = 'CREATURE_SOUND', type = 'annc', desc = 'CREATURE_SOUND'},
        {id = 'MECHANISM_SOUND', type = 'annc', desc = 'MECHANISM_SOUND'},
        {id = 'CREATURE_STEALS_OBJECT', type = 'annc', desc = 'CREATURE_STEALS_OBJECT'},
        {id = 'FOUND_TRAP', type = 'annc', desc = 'FOUND_TRAP'},
        {id = 'BODY_TRANSFORMATION', type = 'annc', desc = 'BODY_TRANSFORMATION'},
        {id = 'INTERACTION_ACTOR', type = 'annc', desc = 'INTERACTION_ACTOR'},
        {id = 'INTERACTION_TARGET', type = 'annc', desc = 'INTERACTION_TARGET'},
        {id = 'UNDEAD_ATTACK', type = 'annc', desc = 'UNDEAD_ATTACK'},
        {id = 'CITIZEN_MISSING', type = 'annc', desc = 'CITIZEN_MISSING'},
        {id = 'PET_MISSING', type = 'annc', desc = 'PET_MISSING'},
        {id = 'STRANGE_RAIN_SNOW', type = 'annc', desc = 'STRANGE_RAIN_SNOW'},
        {id = 'STRANGE_CLOUD', type = 'annc', desc = 'STRANGE_CLOUD'},
        {id = 'SIMPLE_ANIMAL_ACTION', type = 'annc', desc = 'SIMPLE_ANIMAL_ACTION'},
        {id = 'FLOUNDER_IN_LIQUID', type = 'annc', desc = 'FLOUNDER_IN_LIQUID'},
        {id = 'TRAINING_DOWN_TO_SEMI_WILD', type = 'annc', desc = 'TRAINING_DOWN_TO_SEMI_WILD'},
        {id = 'TRAINING_FULL_REVERSION', type = 'annc', desc = 'TRAINING_FULL_REVERSION'},
        {id = 'ANIMAL_TRAINING_KNOWLEDGE', type = 'annc', desc = 'ANIMAL_TRAINING_KNOWLEDGE'},
        {id = 'SKIP_ON_LIQUID', type = 'annc', desc = 'SKIP_ON_LIQUID'},
        {id = 'DODGE_FLYING_OBJECT', type = 'annc', desc = 'DODGE_FLYING_OBJECT'},
        {id = 'REGULAR_CONVERSATION', type = 'annc', desc = 'REGULAR_CONVERSATION'},
        {id = 'CONFLICT_CONVERSATION', type = 'annc', desc = 'CONFLICT_CONVERSATION'},
        {id = 'FLAME_HIT', type = 'annc', desc = 'FLAME_HIT'},
        {id = 'EMBRACE', type = 'annc', desc = 'EMBRACE'},
        {id = 'BANDIT_EMPTY_CONTAINER', type = 'annc', desc = 'BANDIT_EMPTY_CONTAINER'},
        {id = 'BANDIT_GRAB_ITEM', type = 'annc', desc = 'BANDIT_GRAB_ITEM'},
        {id = 'COMBAT_EVENT_ATTACK_INTERRUPTED', type = 'annc', desc = 'COMBAT_EVENT_ATTACK_INTERRUPTED'},
        {id = 'COMBAT_WRESTLE_CATCH_ATTACK', type = 'annc', desc = 'COMBAT_WRESTLE_CATCH_ATTACK'},
        {id = 'FAIL_TO_GRAB_SURFACE', type = 'annc', desc = 'FAIL_TO_GRAB_SURFACE'},
        {id = 'LOSE_HOLD_OF_SURFACE', type = 'annc', desc = 'LOSE_HOLD_OF_SURFACE'},
        {id = 'TRAVEL_COMPLAINT', type = 'annc', desc = 'TRAVEL_COMPLAINT'},
        {id = 'LOSE_EMOTION', type = 'annc', desc = 'LOSE_EMOTION'},
        {id = 'REORGANIZE_POSSESSIONS', type = 'annc', desc = 'REORGANIZE_POSSESSIONS'},
        {id = 'PUSH_ITEM', type = 'annc', desc = 'PUSH_ITEM'},
        {id = 'DRAW_ITEM', type = 'annc', desc = 'DRAW_ITEM'},
        {id = 'STRAP_ITEM', type = 'annc', desc = 'STRAP_ITEM'},
        {id = 'GAIN_SITE_CONTROL', type = 'annc', desc = 'GAIN_SITE_CONTROL'},
        {id = 'FORT_POSITION_SUCCESSION', type = 'annc', desc = 'FORT_POSITION_SUCCESSION'},
    },
}

function file_exists(path)
    local f = io.open(path, "r")
    if f ~= nil then io.close(f) return true
    else return false
    end
end

function settings_load()
    for file, settings in pairs(SETTINGS) do
        local f = io.open('data/init/' .. file .. '.txt')
        local contents = f:read('*all')
        for i, s in pairs(settings) do
            local a, b = contents:find('[' .. s.id .. ':', 1, true)
            if a ~= nil then
                s.value = contents:sub(b + 1, contents:find(']', b, true) - 1)
            else
                return false, 'Could not find "' .. s.id .. '" in ' .. file .. '.txt'
            end
        end
        f:close()
    end
    return true
end

function settings_save()
    for file, settings in pairs(SETTINGS) do
        local path = 'data/init/' .. file .. '.txt'
        local f = io.open(path, 'r')
        local contents = f:read('*all')
        for i, s in pairs(settings) do
            local a, b = contents:find('[' .. s.id .. ':', 1, true)
            if a ~= nil then
                local e = contents:find(']', b, true)
                contents = contents:sub(1, b) .. s.value .. contents:sub(e)
            else
                return false, 'Could not find ' .. s.id .. ' in ' .. file .. '.txt'
            end
        end
        f:close()
        f = io.open(path, 'w')
        f:write(contents)
        f:close()
    end
    print('Saved settings')
end

function dialog.showValidationError(str)
    dialog.showMessage('Error', str, COLOR_LIGHTRED)
end

settings_manager = defclass(settings_manager, gui.FramedScreen)
settings_manager.focus_path = 'settings_manager'

function settings_manager:reset()
    self.frame_title = "Settings"
    self.file = nil
end

function settings_manager:init()
    self:reset()
    local file_list = widgets.List{
        choices = {"init.txt", "d_init.txt", "announcements.txt"},
        text_pen = {fg = ui_settings.color},
        cursor_pen = {fg = ui_settings.highlightcolor},
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
                frame = {l = 1, t = #file_list.choices + 4},
            },
            widgets.Label{
                text = 'settings-manager v' .. VERSION,
                frame = {l = 1, b = 0},
                text_pen = {fg = COLOR_GREY},
            },
        },
    }
    local settings_list = widgets.List{
        choices = {},
        text_pen = {fg = ui_settings.color},
        cursor_pen = {fg = ui_settings.highlightcolor},
        on_submit = self:callback("edit_setting"),
        frame = {l = 1, t = 1, b = 3},
        view_id = "settings_list",
    }
    local settings_page = widgets.Panel{
        subviews = {
            widgets.Label{
                text = "aaaaaaaa",
                frame = {t = 0, l = 42},
                view_id = "header",
            },
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
            settings_save()
            self.subviews.pages:setSelected(1)
            self:reset()
        else
            self:dismiss()
        end
    elseif keys.CURSOR_RIGHT or keys.CURSOR_LEFT or keys.CURSOR_RIGHT_FAST or keys.CURSOR_LEFT_FAST then
        local incr
        if keys.CURSOR_RIGHT then incr = 1
        elseif keys.CURSOR_RIGHT_FAST then incr = 10
        elseif keys.CURSOR_LEFT then incr = -1
        elseif keys.CURSOR_LEFT_FAST then incr = -10
        end
        local setting = self:get_selected_setting()
        val = setting.value
        if setting.type == 'int' then
            val = val + incr
            if setting.min ~= nil then val = math.max(setting.min, val) end
            if setting.max ~= nil then val = math.min(setting.max, val) end
            self:commit_edit(nil, val)
        elseif setting.type == 'bool' then
            val = (val == 'YES' and 0) or 1
            self:commit_edit(nil, val)
        end
    elseif keys._MOUSE_L then
        local mouse_y = df.global.gps.mouse_y
        local list = nil
        if page == 1 then
            list = self.subviews.file_list
        elseif page == 2 then
            list = self.subviews.settings_list
        end
        if list then
            local idx = mouse_y - list.frame.t
            if idx <= #list:getChoices() and idx >= 1 then
                list:setSelected(idx)
                list:submit()
            end
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
    self.subviews.header:setText('')
    if self.file == 'announcements' then
        self.subviews.header:setText(annc_header_text)
        print(self.subviews.header.text)
    end
    self.subviews.pages:setSelected(2)
    self:refresh_settings_list()
end

function settings_manager:refresh_settings_list()
    self.subviews.settings_list:setChoices(self:get_choice_strings(self.file))
end

function settings_manager:get_value_string(opt)
    local value_str = '<unknown>'
    if opt.value ~= nil then
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
        elseif opt.type == 'annc' then
            value_str = annc_to_string(opt.value)
        end
    end
    return value_str
end

function settings_manager:get_choice_strings(file)
    local settings = SETTINGS[file] or error('Invalid settings file: ' .. file)
    local choices = {}
    for i, opt in pairs(settings) do
        table.insert(choices, ('%-40s %s'):format(opt.desc:gsub('>>', string.char(192) .. ' '), self:get_value_string(opt)))
    end
    return choices
end

function settings_manager:get_selected_setting()
    return SETTINGS[self.file][self.subviews.settings_list:getSelected()]
end

function settings_manager:edit_setting(index, choice)
    local setting = SETTINGS[self.file][index]
    local desc = setting.desc:gsub('>>', '')
    if setting.type == 'bool' then
        dialog.showListPrompt(
            desc,
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
            desc,
            text,
            COLOR_WHITE,
            '',
            self:callback('commit_edit', index)
        )
    elseif setting.type == 'string' then
        dialog.showInputPrompt(
            desc,
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
            desc,
            nil,
            COLOR_WHITE,
            choices,
            self:callback('commit_edit', index)
        )
    end
end

local bool_value_map = {
    YES = {bool = true, int = 1},
    NO = {bool = false, int = 0},
}
function settings_manager:commit_edit(index, value)
    local setting = self:get_selected_setting()
    if setting.type == 'bool' then
        if value == 1 then
            value = 'YES'
        else
            value = 'NO'
        end
        if setting.in_game ~= nil then
            set_variable(setting.in_game, bool_value_map[value][setting.in_game_type or 'bool'])
        end
    elseif setting.type == 'int' then
        if value == '' then return false end
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
        if setting.in_game ~= nil then
            set_variable(setting.in_game, value)
        end
    elseif setting.type == 'string' then
        if setting.validate then
            res, err = setting.validate(value)
            if not res then
                dialog.showValidationError(err)
                return false
            end
        end
    elseif setting.type == 'select' then
        value = setting.choices[value][1]
    end
    self:save_setting(value)
end

function settings_manager:save_setting(value)
    self:get_selected_setting().value = value
    self:refresh_settings_list()
end

if dfhack.gui.getCurFocus() == 'dfhack/lua/settings_manager' then
    dfhack.screen.dismiss(dfhack.gui.getCurViewscreen())
end
settings_manager():show()
