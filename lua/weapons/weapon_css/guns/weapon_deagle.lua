-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
Base = "weapon_css",
PrintName = "#Cstrike_WPNHUD_DesertEagle",
WeaponType = "Pistol",
WorldModel = "models/weapons/w_pist_deagle.mdl",
ViewModel = "models/weapons/v_pist_deagle.mdl",
ViewModelFlip = true,
HoldType = "pistol",
Slot = 1,
Spawnable = true,
Category = "Counter-Strike:Source",
CSMuzzleFlashes = true,
CSMuzzleX = false,
MuzzleFlashScale = 1.2,
Sounds = {
    single_shot = "Weapon_DEagle.Single",
},
Primary = {
    Ammo = "BULLET_PLAYER_50AE",
    Automatic = false,
    Bullets = 1,
    Penetration = 2,
    ClipSize = 7,
    CycleTime = 0.225,
    Accuracy = {
        RecoveryTimeCrouch = 0.3223,
        InaccuracyFire = 0.055,
        InaccuracyStand = 0.013,
        InaccuracyMove = 0.0207,
        InaccuracyLadder = 0.023,
        Spread = 0.004,
        InaccuracyJump = 0.345,
        RecoveryTimeStand = 0.3868,
        InaccuracyLand = 0.069,
        InaccuracyCrouch = 0.0097,
    },
    Damage = 54,
    DefaultClip = 7,
    Range = 4096,
},
Secondary = {
    Ammo = "None",
    ClipSize = -1,
},
CrosshairInfo = {
    x = 0,
    file = "sprites/crosshairs",
    y = 48,
    height = 24,
    width = 24,
},
WepSelData = {
    "CSweaponsSmall",
    "F",
},
IconOverride = "VGUI/gfx/VGUI/weapon_deagle",
})