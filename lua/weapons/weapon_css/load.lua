
local ConversionNumbers = function(NSWEP, key, value)
    NSWEP[key] = math.Round(tonumber(value), 5)
end

local ConversionStrings = function(NSWEP, key, value)
    NSWEP[key] = tostring(value)
end 

local Conversion = {}

Conversion["BuiltRightHanded"] = function(NSWEP, value)
    NSWEP.ViewModelFlip = !tobool(value)

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

Conversion["viewmodel"] = function(NSWEP, value)
    NSWEP.ViewModel = string.Replace( value, "weapons/v_", "weapons/cstrike/c_" )
end

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

local KeySend = {
    ["Penetration"] = "Primary",
    ["Damage"] = "Primary",
    ["Range"] = "Primary",
    ["Bullets"] = "Primary",
    ["CycleTime"] = "Primary",
}


if (CLIENT) then
    surface.CreateFont("CSweaponsSmall", {
        font = "csd", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
        extended = true,
        size = 13,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    language.Add("Cstrike_WPNHUD_HE_Grenade", "High-Explosive Grenade")
    language.Add("Cstrike_WPNHUD_Flashbang", "FLASHBANG")
    language.Add("Cstrike_WPNHUD_Smoke_Grenade", "SMOKE GRENADE")
    language.Add("Cstrike_WPNHUD_AK47", "AK-47")
    language.Add("Cstrike_WPNHUD_Aug", "BULLPUP")
    language.Add("Cstrike_WPNHUD_AWP", "MAGNUM SNIPER RIFLE")
    language.Add("Cstrike_WPNHUD_DesertEagle", ".50 DESERT EAGLE")
    language.Add("Cstrike_WPNHUD_Elites", ".40 DUAL ELITES")
    language.Add("Cstrike_WPNHUD_Famas", "CLARION 5.56")
    language.Add("Cstrike_WPNHUD_FiveSeven", "ES FIVE-SEVEN")
    language.Add("Cstrike_WPNHUD_G3SG1", "D3/AU-1")
    language.Add("Cstrike_WPNHUD_Galil", "IDF DEFENDER")
    language.Add("Cstrike_WPNHUD_Glock18", "9X19MM SIDEARM")
    language.Add("Cstrike_WPNHUD_Knife", "KNIFE")
    language.Add("Cstrike_WPNHUD_M249", "M249")
    language.Add("Cstrike_WPNHUD_m3", "LEONE 12 GAUGE SUPER")
    language.Add("Cstrike_WPNHUD_M4A1", "MAVERICK M4A1 CARBINE")
    language.Add("Cstrike_WPNHUD_MAC10", "INGRAM MAC-10")
    language.Add("Cstrike_WPNHUD_MP5", "K&M SUB-MACHINE GUN")
    language.Add("Cstrike_WPNHUD_P228", "228 COMPACT")
    language.Add("Cstrike_WPNHUD_P90", "ES C90")
    language.Add("Cstrike_WPNHUD_Scout", "SCHMIDT SCOUT") 
    language.Add("Cstrike_WPNHUD_SG550", "KRIEG 550 COMMANDO")
    language.Add("Cstrike_WPNHUD_SG552", "KRIEG 552")
    language.Add("Cstrike_WPNHUD_Tmp", "SCHMIDT MACHINE PISTOL")
    language.Add("Cstrike_WPNHUD_UMP45", "K&M UMP45")
    language.Add("Cstrike_WPNHUD_USP45", "K&M .45 TACTICAL")
    language.Add("Cstrike_WPNHUD_xm1014", "LEONE YG1265 AUTO SHOTGUN")
    language.Add("Cstrike_WPNHUD_C4", "C4 EXPLOSIVE")
    language.Add("AMMO_TYPE_FLASHBANG_ammo", "Flashbang Grenades")
    language.Add("AMMO_TYPE_HEGRENADE_ammo", "High-Explosive Grenades")
    language.Add("AMMO_TYPE_SMOKEGRENADE_ammo", "Smoke Grenades")
    language.Add("BULLET_PLAYER_338MAG_ammo", ".338 Lapua Magnum")
    language.Add("BULLET_PLAYER_357SIG_ammo", ".357 SIG")
    language.Add("BULLET_PLAYER_45ACP_ammo", ".45 ACP")
    language.Add("BULLET_PLAYER_50AE_ammo", ".50 Action Express")
    language.Add("BULLET_PLAYER_556MM_ammo", ".556x45mm NATO")
    language.Add("BULLET_PLAYER_556MM_BOX_ammo", ".556x45mm NATO")
    language.Add("BULLET_PLAYER_57MM_ammo", "")
    language.Add("BULLET_PLAYER_762MM_ammo", ".762 MM")
    language.Add("BULLET_PLAYER_9MM_ammo", "9mm ")
    language.Add("BULLET_PLAYER_BUCKSHOT_ammo", "Buckshot")
end


--i didnt think you'd want a shit ton of extra files going in the weapons folder
local function MakeAmmo(ammo)
    if(ammo == "none")then return end
    CSS_AMMO = CSS_AMMO or {}
    if (CSS_AMMO[ammo]) then return end
    CSS_AMMO[ammo] = {}

    game.AddAmmoType({
        name = ammo,
        dmgtype = DMG_BULLET,
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 2000,
        minsplash = 10,
        maxsplash = 5
    })
end
 

function ParseCSScript(script)
    local tab = util.KeyValuesToTable(script, false, true)
    local class = _G.SWEP.ClassName


    local nswep = _G.SWEP
    nswep.Category = "Counter-Strike:Source ".. tab.WeaponType.."s"

    if (tab.WeaponType == "Grenade" or tab.WeaponType == "C4" or tab.WeaponType == "Knife") then
        nswep.Base = "weapon_css_grenade"
        nswep.Category = "Counter-Strike:Source Misc"
    end

    nswep.ClassName = class
    nswep.PrintName = tab.printname
    nswep.IconOverride = "VGUI/gfx/VGUI/" .. string.Trim(class, "weapon_")
    nswep.CSMuzzleFlashes = true    
    nswep.CSMuzzleX = tab.WeaponType == "Rifle"
    nswep.UseHands = true    
    nswep.ViewModelFlip = false
    nswep.Spawnable = true
    
    for key, value in pairs(tab) do
        local t = nswep

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


        if (tonumber(value)) then
            ConversionNumbers(t, key, value)
            continue
        end

        if (tostring(value)) then
            ConversionStrings(t, key, value)
            continue
        end
    end
    nswep.ViewModelFlip = false
end




local function LoadGuns()
for k, fl in pairs(file.Find("weapons/weapon_css/guns/*", "LUA")) do
    local filetype = string.Explode(".", fl)[1]

    local class = string.Explode(".", fl)[1]

    _G.SWEP = {Base = "weapon_css",Primary={Ammo="none",ClipSize=-1,DefaultClip=-1},Secondary={Ammo="none",ClipSize=-1,DefaultClip=-1},Sounds={},ClassName = class}
    local script = "weapons/weapon_css/guns/"..fl
    AddCSLuaFile(script)
    include(script)
 
    weapons.Register(_G.SWEP,class)

    if(_G.SWEP.Primary.Ammo)then
        print(class,_G.SWEP.Primary.Ammo)
        MakeAmmo(_G.SWEP.Primary.Ammo)
    end 
end
end
hook.Add("Initialize","LoadCSSweps",function() LoadGuns() end)
hook.Add("OnReloaded","LoadCSSweps",function() LoadGuns() end)
timer.Simple(0,function() LoadGuns() end)