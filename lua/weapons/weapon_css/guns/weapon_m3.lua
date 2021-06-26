-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
Base = "weapon_css",
PrintName = "#Cstrike_WPNHUD_m3",
WeaponType = "Shotgun",
WorldModel = "models/weapons/w_shot_m3super90.mdl",
ViewModel = "models/weapons/v_shot_m3super90.mdl",
ViewModelFlip = true,
HoldType = "pistol",
Slot = 3,
Spawnable = true,
Category = "Counter-Strike:Source",
CSMuzzleFlashes = true,
CSMuzzleX = false,
MuzzleFlashScale = 1.3,
Sounds = {
    special3 = "Default.Zoom",
    single_shot = "Weapon_M3.Single",
},
Primary = {
    Ammo = "BULLET_PLAYER_BUCKSHOT",
    Automatic = true,
    Bullets = 9,
    Penetration = 1,
    ClipSize = 8,
    CycleTime = 0.88,
    Accuracy = {
        RecoveryTimeCrouch = 0.296,
        InaccuracyFire = 0.0416,
        InaccuracyStand = 0.01,
        InaccuracyMove = 0.0432,
        InaccuracyLadder = 0.0787,
        Spread = 0.04,
        InaccuracyJump = 0.42,
        RecoveryTimeStand = 0.4144,
        InaccuracyLand = 0.084,
        InaccuracyCrouch = 0.0075,
    },
    Damage = 26,
    DefaultClip = 8,
    Range = 3000,
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
    "K",
},
IconOverride = "VGUI/gfx/VGUI/weapon_m3",
})