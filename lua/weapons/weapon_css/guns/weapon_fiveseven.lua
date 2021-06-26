-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
Base = "weapon_css",
PrintName = "#Cstrike_WPNHUD_FiveSeven",
WeaponType = "Pistol",
WorldModel = "models/weapons/w_pist_fiveseven.mdl",
ViewModel = "models/weapons/v_pist_fiveseven.mdl",
ViewModelFlip = true,
HoldType = "pistol",
Slot = 1,
Spawnable = true,
Category = "Counter-Strike:Source",
CSMuzzleFlashes = true,
CSMuzzleX = false,
MuzzleFlashScale = 1,
Sounds = {
    single_shot = "Weapon_FiveSeven.Single",
},
Primary = {
    Ammo = "BULLET_PLAYER_57MM",
    Automatic = false,
    Bullets = 1,
    Penetration = 1,
    ClipSize = 20,
    CycleTime = 0.15,
    Accuracy = {
        RecoveryTimeCrouch = 0.1862,
        InaccuracyFire = 0.0588,
        InaccuracyStand = 0.01,
        InaccuracyMove = 0.0153,
        InaccuracyLadder = 0.017,
        Spread = 0.004,
        InaccuracyJump = 0.2563,
        RecoveryTimeStand = 0.2235,
        InaccuracyLand = 0.0512,
        InaccuracyCrouch = 0.006,
    },
    Damage = 25,
    DefaultClip = 20,
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
    "U",
},
IconOverride = "VGUI/gfx/VGUI/weapon_fiveseven",
})