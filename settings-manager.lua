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
local utils = require "utils"

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
function annc_flags:init(str)
    -- Convert long names to short names
    for _, flag in pairs(ANNC_FLAGS) do
        str = str:gsub(flag.in_game, flag.id)
    end
    self.raw = str
end

function annc_flags:display_string()
    local flags = utils.invert(utils.split_string(self.raw, ':'))
    local disp = ''
    for _, flag in pairs(ANNC_FLAGS) do
        disp = disp .. (flags[flag.id] and string.char(219) or ' '):rep(#flag.short) .. ' '
    end
    return disp:sub(1, #disp - 1)
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
    local parts = utils.split_string(name, '%.')
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
-- "macros"
function setting_annc(id, desc)
    return {type = 'annc', id = id, desc = desc}
end
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
            local parts = utils.split_string(s, ':')
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
        setting_annc('REACHED_PEAK', 'REACHED_PEAK'),
        setting_annc('ERA_CHANGE', 'ERA_CHANGE'),
        setting_annc('ENDGAME_EVENT_1', 'ENDGAME_EVENT_1'),
        setting_annc('ENDGAME_EVENT_2', 'ENDGAME_EVENT_2'),
        setting_annc('FEATURE_DISCOVERY', 'FEATURE_DISCOVERY'),
        setting_annc('STRUCK_DEEP_METAL', 'STRUCK_DEEP_METAL'),
        setting_annc('STRUCK_MINERAL', 'STRUCK_MINERAL'),
        setting_annc('STRUCK_ECONOMIC_MINERAL', 'STRUCK_ECONOMIC_MINERAL'),
        setting_annc('COMBAT_TWIST_WEAPON', 'COMBAT_TWIST_WEAPON'),
        setting_annc('COMBAT_LET_ITEM_DROP', 'COMBAT_LET_ITEM_DROP'),
        setting_annc('COMBAT_START_CHARGE', 'COMBAT_START_CHARGE'),
        setting_annc('COMBAT_SURPRISE_CHARGE', 'COMBAT_SURPRISE_CHARGE'),
        setting_annc('COMBAT_JUMP_DODGE_PROJ', 'COMBAT_JUMP_DODGE_PROJ'),
        setting_annc('COMBAT_JUMP_DODGE_STRIKE', 'COMBAT_JUMP_DODGE_STRIKE'),
        setting_annc('COMBAT_DODGE', 'COMBAT_DODGE'),
        setting_annc('COMBAT_COUNTERSTRIKE', 'COMBAT_COUNTERSTRIKE'),
        setting_annc('COMBAT_BLOCK', 'COMBAT_BLOCK'),
        setting_annc('COMBAT_PARRY', 'COMBAT_PARRY'),
        setting_annc('COMBAT_CHARGE_COLLISION', 'COMBAT_CHARGE_COLLISION'),
        setting_annc('COMBAT_CHARGE_DEFENDER_TUMBLES', 'COMBAT_CHARGE_DEFENDER_TUMBLES'),
        setting_annc('COMBAT_CHARGE_DEFENDER_KNOCKED_OVER', 'COMBAT_CHARGE_DEFENDER_KNOCKED_OVER'),
        setting_annc('COMBAT_CHARGE_ATTACKER_TUMBLES', 'COMBAT_CHARGE_ATTACKER_TUMBLES'),
        setting_annc('COMBAT_CHARGE_ATTACKER_BOUNCE_BACK', 'COMBAT_CHARGE_ATTACKER_BOUNCE_BACK'),
        setting_annc('COMBAT_CHARGE_TANGLE_TOGETHER', 'COMBAT_CHARGE_TANGLE_TOGETHER'),
        setting_annc('COMBAT_CHARGE_TANGLE_TUMBLE', 'COMBAT_CHARGE_TANGLE_TUMBLE'),
        setting_annc('COMBAT_CHARGE_RUSH_BY', 'COMBAT_CHARGE_RUSH_BY'),
        setting_annc('COMBAT_CHARGE_MANAGE_STOP', 'COMBAT_CHARGE_MANAGE_STOP'),
        setting_annc('COMBAT_CHARGE_OBSTACLE_SLAM', 'COMBAT_CHARGE_OBSTACLE_SLAM'),
        setting_annc('COMBAT_WRESTLE_LOCK', 'COMBAT_WRESTLE_LOCK'),
        setting_annc('COMBAT_WRESTLE_CHOKEHOLD', 'COMBAT_WRESTLE_CHOKEHOLD'),
        setting_annc('COMBAT_WRESTLE_TAKEDOWN', 'COMBAT_WRESTLE_TAKEDOWN'),
        setting_annc('COMBAT_WRESTLE_THROW', 'COMBAT_WRESTLE_THROW'),
        setting_annc('COMBAT_WRESTLE_RELEASE_LOCK', 'COMBAT_WRESTLE_RELEASE_LOCK'),
        setting_annc('COMBAT_WRESTLE_RELEASE_CHOKE', 'COMBAT_WRESTLE_RELEASE_CHOKE'),
        setting_annc('COMBAT_WRESTLE_RELEASE_GRIP', 'COMBAT_WRESTLE_RELEASE_GRIP'),
        setting_annc('COMBAT_WRESTLE_STRUGGLE', 'COMBAT_WRESTLE_STRUGGLE'),
        setting_annc('COMBAT_WRESTLE_RELEASE_LATCH', 'COMBAT_WRESTLE_RELEASE_LATCH'),
        setting_annc('COMBAT_WRESTLE_STRANGLE_KO', 'COMBAT_WRESTLE_STRANGLE_KO'),
        setting_annc('COMBAT_WRESTLE_ADJUST_GRIP', 'COMBAT_WRESTLE_ADJUST_GRIP'),
        setting_annc('COMBAT_GRAB_TEAR', 'COMBAT_GRAB_TEAR'),
        setting_annc('COMBAT_STRIKE_DETAILS', 'COMBAT_STRIKE_DETAILS'),
        setting_annc('COMBAT_STRIKE_DETAILS_2', 'COMBAT_STRIKE_DETAILS_2'),
        setting_annc('COMBAT_EVENT_ENRAGED', 'COMBAT_EVENT_ENRAGED'),
        setting_annc('COMBAT_EVENT_STUCKIN', 'COMBAT_EVENT_STUCKIN'),
        setting_annc('COMBAT_EVENT_LATCH_BP', 'COMBAT_EVENT_LATCH_BP'),
        setting_annc('COMBAT_EVENT_LATCH_GENERAL', 'COMBAT_EVENT_LATCH_GENERAL'),
        setting_annc('COMBAT_EVENT_PROPELLED_AWAY', 'COMBAT_EVENT_PROPELLED_AWAY'),
        setting_annc('COMBAT_EVENT_KNOCKED_OUT', 'COMBAT_EVENT_KNOCKED_OUT'),
        setting_annc('COMBAT_EVENT_STUNNED', 'COMBAT_EVENT_STUNNED'),
        setting_annc('COMBAT_EVENT_WINDED', 'COMBAT_EVENT_WINDED'),
        setting_annc('COMBAT_EVENT_NAUSEATED', 'COMBAT_EVENT_NAUSEATED'),
        setting_annc('MIGRANT_ARRIVAL_NAMED', 'MIGRANT_ARRIVAL_NAMED'),
        setting_annc('MIGRANT_ARRIVAL', 'MIGRANT_ARRIVAL'),
        setting_annc('DIG_CANCEL_WARM', 'DIG_CANCEL_WARM'),
        setting_annc('DIG_CANCEL_DAMP', 'DIG_CANCEL_DAMP'),
        setting_annc('AMBUSH_DEFENDER', 'AMBUSH_DEFENDER'),
        setting_annc('AMBUSH_RESIDENT', 'AMBUSH_RESIDENT'),
        setting_annc('AMBUSH_THIEF', 'AMBUSH_THIEF'),
        setting_annc('AMBUSH_THIEF_SUPPORT_SKULKING', 'AMBUSH_THIEF_SUPPORT_SKULKING'),
        setting_annc('AMBUSH_THIEF_SUPPORT_NATURE', 'AMBUSH_THIEF_SUPPORT_NATURE'),
        setting_annc('AMBUSH_THIEF_SUPPORT', 'AMBUSH_THIEF_SUPPORT'),
        setting_annc('AMBUSH_MISCHIEVOUS', 'AMBUSH_MISCHIEVOUS'),
        setting_annc('AMBUSH_SNATCHER', 'AMBUSH_SNATCHER'),
        setting_annc('AMBUSH_SNATCHER_SUPPORT', 'AMBUSH_SNATCHER_SUPPORT'),
        setting_annc('AMBUSH_AMBUSHER_NATURE', 'AMBUSH_AMBUSHER_NATURE'),
        setting_annc('AMBUSH_AMBUSHER', 'AMBUSH_AMBUSHER'),
        setting_annc('AMBUSH_INJURED', 'AMBUSH_INJURED'),
        setting_annc('AMBUSH_OTHER', 'AMBUSH_OTHER'),
        setting_annc('AMBUSH_INCAPACITATED', 'AMBUSH_INCAPACITATED'),
        setting_annc('CARAVAN_ARRIVAL', 'CARAVAN_ARRIVAL'),
        setting_annc('NOBLE_ARRIVAL', 'NOBLE_ARRIVAL'),
        setting_annc('D_MIGRANTS_ARRIVAL', 'D_MIGRANTS_ARRIVAL'),
        setting_annc('D_MIGRANT_ARRIVAL', 'D_MIGRANT_ARRIVAL'),
        setting_annc('D_MIGRANT_ARRIVAL_DISCOURAGED', 'D_MIGRANT_ARRIVAL_DISCOURAGED'),
        setting_annc('D_NO_MIGRANT_ARRIVAL', 'D_NO_MIGRANT_ARRIVAL'),
        setting_annc('ANIMAL_TRAP_CATCH', 'ANIMAL_TRAP_CATCH'),
        setting_annc('ANIMAL_TRAP_ROBBED', 'ANIMAL_TRAP_ROBBED'),
        setting_annc('MISCHIEF_LEVER', 'MISCHIEF_LEVER'),
        setting_annc('MISCHIEF_PLATE', 'MISCHIEF_PLATE'),
        setting_annc('MISCHIEF_CAGE', 'MISCHIEF_CAGE'),
        setting_annc('MISCHIEF_CHAIN', 'MISCHIEF_CHAIN'),
        setting_annc('DIPLOMAT_ARRIVAL', 'DIPLOMAT_ARRIVAL'),
        setting_annc('LIAISON_ARRIVAL', 'LIAISON_ARRIVAL'),
        setting_annc('TRADE_DIPLOMAT_ARRIVAL', 'TRADE_DIPLOMAT_ARRIVAL'),
        setting_annc('CAVE_COLLAPSE', 'CAVE_COLLAPSE'),
        setting_annc('BIRTH_CITIZEN', 'BIRTH_CITIZEN'),
        setting_annc('BIRTH_ANIMAL', 'BIRTH_ANIMAL'),
        setting_annc('BIRTH_WILD_ANIMAL', 'BIRTH_WILD_ANIMAL'),
        setting_annc('STRANGE_MOOD', 'STRANGE_MOOD'),
        setting_annc('MADE_ARTIFACT', 'MADE_ARTIFACT'),
        setting_annc('NAMED_ARTIFACT', 'NAMED_ARTIFACT'),
        setting_annc('ITEM_ATTACHMENT', 'ITEM_ATTACHMENT'),
        setting_annc('VERMIN_CAGE_ESCAPE', 'VERMIN_CAGE_ESCAPE'),
        setting_annc('TRIGGER_WEB', 'TRIGGER_WEB'),
        setting_annc('MOOD_BUILDING_CLAIMED', 'MOOD_BUILDING_CLAIMED'),
        setting_annc('ARTIFACT_BEGUN', 'ARTIFACT_BEGUN'),
        setting_annc('MEGABEAST_ARRIVAL', 'MEGABEAST_ARRIVAL'),
        setting_annc('BERSERK_CITIZEN', 'BERSERK_CITIZEN'),
        setting_annc('MAGMA_DEFACES_ENGRAVING', 'MAGMA_DEFACES_ENGRAVING'),
        setting_annc('ENGRAVING_MELTS', 'ENGRAVING_MELTS'),
        setting_annc('MASTERPIECE_ARCHITECTURE', 'MASTERPIECE_ARCHITECTURE'),
        setting_annc('MASTERPIECE_CONSTRUCTION', 'MASTERPIECE_CONSTRUCTION'),
        setting_annc('MASTER_ARCHITECTURE_LOST', 'MASTER_ARCHITECTURE_LOST'),
        setting_annc('MASTER_CONSTRUCTION_LOST', 'MASTER_CONSTRUCTION_LOST'),
        setting_annc('ADV_AWAKEN', 'ADV_AWAKEN'),
        setting_annc('ADV_SLEEP_INTERRUPTED', 'ADV_SLEEP_INTERRUPTED'),
        setting_annc('ADV_REACTION_PRODUCTS', 'ADV_REACTION_PRODUCTS'),
        setting_annc('CANCEL_JOB', 'CANCEL_JOB'),
        setting_annc('ADV_CREATURE_DEATH', 'ADV_CREATURE_DEATH'),
        setting_annc('CITIZEN_DEATH', 'CITIZEN_DEATH'),
        setting_annc('PET_DEATH', 'PET_DEATH'),
        setting_annc('FALL_OVER', 'FALL_OVER'),
        setting_annc('CAUGHT_IN_FLAMES', 'CAUGHT_IN_FLAMES'),
        setting_annc('CAUGHT_IN_WEB', 'CAUGHT_IN_WEB'),
        setting_annc('UNIT_PROJECTILE_SLAM_BLOW_APART', 'UNIT_PROJECTILE_SLAM_BLOW_APART'),
        setting_annc('UNIT_PROJECTILE_SLAM', 'UNIT_PROJECTILE_SLAM'),
        setting_annc('UNIT_PROJECTILE_SLAM_INTO_UNIT', 'UNIT_PROJECTILE_SLAM_INTO_UNIT'),
        setting_annc('VOMIT', 'VOMIT'),
        setting_annc('LOSE_HOLD_OF_ITEM', 'LOSE_HOLD_OF_ITEM'),
        setting_annc('REGAIN_CONSCIOUSNESS', 'REGAIN_CONSCIOUSNESS'),
        setting_annc('FREE_FROM_WEB', 'FREE_FROM_WEB'),
        setting_annc('PARALYZED', 'PARALYZED'),
        setting_annc('OVERCOME_PARALYSIS', 'OVERCOME_PARALYSIS'),
        setting_annc('NOT_STUNNED', 'NOT_STUNNED'),
        setting_annc('EXHAUSTION', 'EXHAUSTION'),
        setting_annc('PAIN_KO', 'PAIN_KO'),
        setting_annc('BREAK_GRIP', 'BREAK_GRIP'),
        setting_annc('NO_BREAK_GRIP', 'NO_BREAK_GRIP'),
        setting_annc('BLOCK_FIRE', 'BLOCK_FIRE'),
        setting_annc('BREATHE_FIRE', 'BREATHE_FIRE'),
        setting_annc('SHOOT_WEB', 'SHOOT_WEB'),
        setting_annc('PULL_OUT_DROP', 'PULL_OUT_DROP'),
        setting_annc('STAND_UP', 'STAND_UP'),
        setting_annc('MARTIAL_TRANCE', 'MARTIAL_TRANCE'),
        setting_annc('MAT_BREATH', 'MAT_BREATH'),
        setting_annc('NIGHT_ATTACK_STARTS', 'NIGHT_ATTACK_STARTS'),
        setting_annc('NIGHT_ATTACK_ENDS', 'NIGHT_ATTACK_ENDS'),
        setting_annc('NIGHT_ATTACK_TRAVEL', 'NIGHT_ATTACK_TRAVEL'),
        setting_annc('GHOST_ATTACK', 'GHOST_ATTACK'),
        setting_annc('TRAVEL_SITE_DISCOVERY', 'TRAVEL_SITE_DISCOVERY'),
        setting_annc('TRAVEL_SITE_BUMP', 'TRAVEL_SITE_BUMP'),
        setting_annc('ADVENTURE_INTRO', 'ADVENTURE_INTRO'),
        setting_annc('CREATURE_SOUND', 'CREATURE_SOUND'),
        setting_annc('MECHANISM_SOUND', 'MECHANISM_SOUND'),
        setting_annc('CREATURE_STEALS_OBJECT', 'CREATURE_STEALS_OBJECT'),
        setting_annc('FOUND_TRAP', 'FOUND_TRAP'),
        setting_annc('BODY_TRANSFORMATION', 'BODY_TRANSFORMATION'),
        setting_annc('INTERACTION_ACTOR', 'INTERACTION_ACTOR'),
        setting_annc('INTERACTION_TARGET', 'INTERACTION_TARGET'),
        setting_annc('UNDEAD_ATTACK', 'UNDEAD_ATTACK'),
        setting_annc('CITIZEN_MISSING', 'CITIZEN_MISSING'),
        setting_annc('PET_MISSING', 'PET_MISSING'),
        setting_annc('STRANGE_RAIN_SNOW', 'STRANGE_RAIN_SNOW'),
        setting_annc('STRANGE_CLOUD', 'STRANGE_CLOUD'),
        setting_annc('SIMPLE_ANIMAL_ACTION', 'SIMPLE_ANIMAL_ACTION'),
        setting_annc('FLOUNDER_IN_LIQUID', 'FLOUNDER_IN_LIQUID'),
        setting_annc('TRAINING_DOWN_TO_SEMI_WILD', 'TRAINING_DOWN_TO_SEMI_WILD'),
        setting_annc('TRAINING_FULL_REVERSION', 'TRAINING_FULL_REVERSION'),
        setting_annc('ANIMAL_TRAINING_KNOWLEDGE', 'ANIMAL_TRAINING_KNOWLEDGE'),
        setting_annc('SKIP_ON_LIQUID', 'SKIP_ON_LIQUID'),
        setting_annc('DODGE_FLYING_OBJECT', 'DODGE_FLYING_OBJECT'),
        setting_annc('REGULAR_CONVERSATION', 'REGULAR_CONVERSATION'),
        setting_annc('CONFLICT_CONVERSATION', 'CONFLICT_CONVERSATION'),
        setting_annc('FLAME_HIT', 'FLAME_HIT'),
        setting_annc('EMBRACE', 'EMBRACE'),
        setting_annc('BANDIT_EMPTY_CONTAINER', 'BANDIT_EMPTY_CONTAINER'),
        setting_annc('BANDIT_GRAB_ITEM', 'BANDIT_GRAB_ITEM'),
        setting_annc('COMBAT_EVENT_ATTACK_INTERRUPTED', 'COMBAT_EVENT_ATTACK_INTERRUPTED'),
        setting_annc('COMBAT_WRESTLE_CATCH_ATTACK', 'COMBAT_WRESTLE_CATCH_ATTACK'),
        setting_annc('FAIL_TO_GRAB_SURFACE', 'FAIL_TO_GRAB_SURFACE'),
        setting_annc('LOSE_HOLD_OF_SURFACE', 'LOSE_HOLD_OF_SURFACE'),
        setting_annc('TRAVEL_COMPLAINT', 'TRAVEL_COMPLAINT'),
        setting_annc('LOSE_EMOTION', 'LOSE_EMOTION'),
        setting_annc('REORGANIZE_POSSESSIONS', 'REORGANIZE_POSSESSIONS'),
        setting_annc('PUSH_ITEM', 'PUSH_ITEM'),
        setting_annc('DRAW_ITEM', 'DRAW_ITEM'),
        setting_annc('STRAP_ITEM', 'STRAP_ITEM'),
        setting_annc('GAIN_SITE_CONTROL', 'GAIN_SITE_CONTROL'),
        setting_annc('FORT_POSITION_SUCCESSION', 'FORT_POSITION_SUCCESSION'),
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
            if file == 'announcements' then
                s.flags = annc_flags(s.value)
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
            value_str = opt.flags:display_string()
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
