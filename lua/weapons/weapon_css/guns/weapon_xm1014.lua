-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
Base = "weapon_css",
PrintName = "#Cstrike_WPNHUD_xm1014",
WeaponType = "Shotgun",
WorldModel = "models/weapons/w_shot_xm1014.mdl",
ViewModel = "models/weapons/v_shot_xm1014.mdl",
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
    single_shot = "Weapon_XM1014.Single",
},
Primary = {
    Ammo = "BULLET_PLAYER_BUCKSHOT",
    Automatic = true,
    Bullets = 6,
    Penetration = 1,
    ClipSize = 7,
    CycleTime = 0.25,
    Accuracy = {
        RecoveryTimeCrouch = 0.3289,
        InaccuracyFire = 0.0364,
        InaccuracyStand = 0.01,
        InaccuracyMove = 0.0354,
        InaccuracyLadder = 0.0772,
        Spread = 0.04,
        InaccuracyJump = 0.4117,
        RecoveryTimeStand = 0.4605,
        InaccuracyLand = 0.0823,
        InaccuracyCrouch = 0.0075,
    },
    Damage = 22,
    DefaultClip = 7,
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
    "]",
},
IconOverride = "VGUI/gfx/VGUI/weapon_xm1014",
})