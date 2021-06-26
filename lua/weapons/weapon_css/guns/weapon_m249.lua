-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
Base = "weapon_css",
PrintName = "#Cstrike_WPNHUD_M249",
WeaponType = "Machinegun",
WorldModel = "models/weapons/w_mach_m249para.mdl",
ViewModel = "models/weapons/v_mach_m249para.mdl",
ViewModelFlip = false,
HoldType = "ar2",
Slot = 2,
Spawnable = true,
Category = "Counter-Strike:Source",
CSMuzzleFlashes = true,
CSMuzzleX = false,
MuzzleFlashScale = 1.5,
Sounds = {
    special3 = "Default.Zoom",
    single_shot = "Weapon_M249.Single",
},
Primary = {
    Ammo = "BULLET_PLAYER_556MM_BOX",
    Automatic = true,
    Damage = 35,
    Penetration = 2,
    ClipSize = 100,
    CycleTime = 0.08,
    Accuracy = {
        AccuracyDivisor = 175,
        RecoveryTimeCrouch = 0.5592,
        InaccuracyFire = 0.0042,
        InaccuracyLand = 0.1416,
        AccuracyOffset = 0.4,
        InaccuracyStand = 0.0101,
        InaccuracyLadder = 0.1328,
        Spread = 0.002,
        InaccuracyMove = 0.1061,
        RecoveryTimeStand = 0.7828,
        InaccuracyJump = 0.7083,
        InaccuracyCrouch = 0.0076,
    },
    Bullets = 1,
    DefaultClip = 100,
    Range = 8192,
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
    "Z",
},
IconOverride = "VGUI/gfx/VGUI/weapon_m249",
MaxInaccuracy = 0.9,
IdleInterval = 20,
MuzzleFlashStyle = "CS_MUZZLEFLASH_X",
TimeToIdle = 1.6,
})