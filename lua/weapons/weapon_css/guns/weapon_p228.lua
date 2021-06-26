-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
Base = "weapon_css",
PrintName = "#Cstrike_WPNHUD_P228",
WeaponType = "Pistol",
WorldModel = "models/weapons/w_pist_p228.mdl",
ViewModel = "models/weapons/v_pist_p228.mdl",
ViewModelFlip = true,
HoldType = "pistol",
Slot = 1,
Spawnable = true,
Category = "Counter-Strike:Source",
CSMuzzleFlashes = true,
CSMuzzleX = false,
MuzzleFlashScale = 1,
Sounds = {
    single_shot = "Weapon_P228.Single",
},
Primary = {
    Ammo = "BULLET_PLAYER_357SIG",
    Automatic = false,
    Bullets = 1,
    Penetration = 1,
    ClipSize = 13,
    CycleTime = 0.15,
    Accuracy = {
        RecoveryTimeCrouch = 0.2302,
        InaccuracyFire = 0.0331,
        InaccuracyStand = 0.011,
        InaccuracyMove = 0.0171,
        InaccuracyLadder = 0.019,
        Spread = 0.004,
        InaccuracyJump = 0.285,
        RecoveryTimeStand = 0.2763,
        InaccuracyLand = 0.057,
        InaccuracyCrouch = 0.0082,
    },
    Damage = 40,
    DefaultClip = 13,
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
    "Y",
},
IconOverride = "VGUI/gfx/VGUI/weapon_p228",
})