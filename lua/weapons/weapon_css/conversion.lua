
if(true)then return end
local ConversionNumbers = function(NSWEP, key, value)
    NSWEP[key] = math.Round(tonumber(value), 5)
end

local ConversionStrings = function(NSWEP, key, value)
    NSWEP[key] = tostring(value)
end 

local Conversion = {}

Conversion["BuiltRightHanded"] = function(NSWEP, value)
    NSWEP.ViewModelFlip = not tobool(value)
end

Conversion["WeaponType"] = function(NSWEP, value)
    local holdtypes = {
        Rifle = "ar2",
        SubMachinegun = "smg",
        Pistol = "pistol",
        Shogun = "shotgun",
        SniperRifle = "ar2",
        Machinegun = "ar2",
        Grenade = "grenade",
        C4 = "slam"
    }
 
    local slots = {
        Pistol = 1,
        Rifle = 2,
        SubMachinegun = 2,
        Machinegun = 2,
        Shotgun = 3,
        SniperRifle = 3,
        Grenade = 3,
    }

    if (value == "SniperRifle") then
        NSWEP.CanScope = true
    end

    NSWEP.HoldType = holdtypes[value] or "pistol"
    NSWEP.Slot = slots[value] or 4
    NSWEP.WeaponType = value
end

Conversion["FullAuto"] = function(NSWEP, value)
    NSWEP.Primary.Automatic = tobool(value)
end

Conversion["primary_ammo"] = function(NSWEP, value)
    NSWEP.Primary.Ammo = value
end

Conversion["secondary_ammo"] = function(NSWEP, value)
    NSWEP.Secondary.Ammo = value
end

Conversion["clip_size"] = function(NSWEP, value)
    NSWEP.Primary.ClipSize = tonumber(value)
    NSWEP.Primary.DefaultClip = tonumber(value)
end

Conversion["SoundData"] = function(NSWEP, value)
    for k, v in pairs(value) do
        NSWEP.Sounds[k] = Sound(v)
    end
end

Conversion["TextureData"] = function(NSWEP, value)
    NSWEP.WepSelData = {value.weapon.font, value.weapon.character}

    if (CLIENT) then end --killicon.AddFont(NSWEP.ClassName, value.weapon.font, value.weapon.character, Color(255, 80, 0, 255))
    NSWEP.CrosshairInfo = value.crosshair
end

Conversion["viewmodel"] = "ViewModel"
Conversion["playermodel"] = "WorldModel"


REG_GUNS = REG_GUNS or {}

local function lprepstring(string)
    return "\"" .. string .. "\""
end

local function lprepbool(bool)
    return bool == true and "true" or "false"
end

local function lprep(v)
    return isstring(v) and lprepstring(v) or isbool(v) and lprepbool(v) or v
end

function RecurseL(value, nest)
    nest = (nest or 0)
    local vline = ""
    local valstring = lprep(value)

    if (istable(valstring)) then
        local nestpr = ""

        if (nest > 0) then
            for i = 1, nest do
                nestpr = nestpr .. "    "
            end
        end

        vline = "{\n"

        for k, v in pairs(valstring) do
            local defstring = tonumber(k) and "" or (k .. " = ")
            vline = vline .. "    " .. nestpr .. defstring .. RecurseL(v, nest + 1) .. ",\n"
        end

        vline = vline .. nestpr .. "}"
    else
        vline = vline .. valstring
    end

    return vline
end

local preferredorder = {"<header>", "Base", "PrintName", "WeaponType", "WorldModel", "ViewModel", "ViewModelFlip", "HoldType", "Slot", "Spawnable", "Category", "CSMuzzleFlashes", "CSMuzzleX", "MuzzleFlashScale", "Sounds", "Primary", "Secondary", "CrosshairInfo", "WepSelData", "IconOverride"}

local KeySend = {
    ["Penetration"] = "Primary",
    ["Damage"] = "Primary",
    ["Range"] = "Primary",
    ["Bullets"] = "Primary",
    ["CycleTime"] = "Primary",
}

local Skip = {
    ModelBounds = true,
    Team = true,
    PlayerAnimationExtension = true,
    RangeModifier = true,
    printname = true,
    IconOverride = true,
    shieldviewmodel = true,
    bucket = true,
    CrosshairMinDistance = true,
    HoldType = true,
    CrosshairDeltaDistance = true,
    WeaponArmorRatio = true,
    item_flags = true,
    CanEquipWithShield = true,
    MaxPlayerSpeed = true,
    bucket_position = true,
    anim_prefix = true,
    WeaponPrice = true,
    weight = true,
}

local function sprior(key)
    return table.KeyFromValue(preferredorder, key) or 99
end

function SWEPTABLEToLUA(tab)
    local lines = {} 
    local header = [[-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
]]
 
    table.insert(lines, 1, {"<header>", header})

    local newline = ""

    for k, v in pairs(tab) do
        if (k == "Folder" or k == "ClassName") then continue end
        local valstring = lprep(v)
        newline = k .. " = " .. RecurseL(v) .. ",\n"

        table.insert(lines, {k, newline})
    end

    table.sort(lines, function(a, b) return sprior(a[1]) < sprior(b[1]) end)
    local fcont = ""

    for k, v in pairs(lines) do
        fcont = fcont .. v[2]
    end
    fcont = fcont .. "})"
    return fcont
end

local swept = SWEP

for k, fl in pairs(file.Find("weapons/weapon_css/guns_raw/*", "LUA")) do
    if (not REG_GUNS[fl]) then
        AddCSLuaFile("weapons/weapon_css/guns_raw/" .. fl)
        REG_GUNS[fl] = true
    end

    local fc = file.Read("weapons/weapon_css/guns_raw/" .. fl, "LUA")
    local class = string.Explode(".", fl)[1]
    local tab = util.KeyValuesToTable(fc, false, true)

    _G.SWEP = {
        Base = "weapon_css",
        Folder = "weapons/" .. class,
        Primary = {},
        Secondary = {
            Ammo = "none",
            ClipSize = -1
        },
        Sounds = {},
        Spawnable = true,
        Category = "Counter-Strike:Source"
    } 

    local nswep = _G.SWEP

    if (tab.WeaponType == "Grenade" or tab.WeaponType == "C4") then
        nswep.Base = "weapon_css_grenade"
        nswep.Category = "Counter-Strike:Source Grenades"
    end

    nswep.ClassName = class
    nswep.ViewModelFlip = true
    nswep.PrintName = tab.printname
    nswep.IconOverride = "VGUI/gfx/VGUI/" .. string.Trim(class, "weapon_")
    nswep.CSMuzzleFlashes = true
    nswep.CSMuzzleX = tab.WeaponType == "Rifle"

    for key, value in pairs(tab) do
        local t = nswep
        if (Skip[key]) then continue end

        if (Conversion[key]) then
            if (isfunction(Conversion[key])) then
                Conversion[key](nswep, value)
                continue
            end

            if (isstring(Conversion[key])) then
                key = Conversion[key]
            end
        end
 
        local ks = KeySend[key]
        local accuracytags = {
            Spread=true,
            SpreadAlt=true,
            MaxInaccuracy= true,
            RecoveryTimeStand=true,
            RecoveryTimeCrouch=true,
        }


        if (string.StartWith(key, "Accuracy") or string.StartWith(key, "Inaccuracy") or accuracytags[key]) then
            t.Primary = t.Primary or {}
            t = t.Primary
            t.Accuracy = t.Accuracy or {}
            t = t.Accuracy
            key = string.StartWith(key, "Accuracy") and string.Trim(key, "Accuracy") or key
        end



        if (ks) then
            --set up subtable
            t[ks] = t[ks] or {}
            t = t[ks]
        end

        if (type(value) == "table") then
            Error("tried to assign " .. key .. " to table value")
        end

        if (tonumber(value)) then
            ConversionNumbers(t, key, value)
            continue
        end

        if (tostring(value)) then
            ConversionStrings(t, key, value)
            continue
        end
    end

    print("created weapon " .. class)
    local fcont = SWEPTABLEToLUA(_G.SWEP)
    file.CreateDir("csw")
    file.Write("csw/" .. class .. ".txt", fcont)
    --weapons.Register(nswep, class) 
    --weapons.GetStored(class).Base = _G.SWEP.Base
    _G.SWEP = swept
end
