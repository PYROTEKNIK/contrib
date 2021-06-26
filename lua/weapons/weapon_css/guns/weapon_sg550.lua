-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
Base = "weapon_css",
PrintName = "#Cstrike_WPNHUD_SG550",
WeaponType = "SniperRifle",
WorldModel = "models/weapons/w_snip_sg550.mdl",
ViewModel = "models/weapons/v_snip_sg550.mdl",
ViewModelFlip = true,
HoldType = "ar2",
Slot = 3,
Spawnable = true,
Category = "Counter-Strike:Source",
CSMuzzleFlashes = true,
CSMuzzleX = false,
MuzzleFlashScale = 1.6,
Sounds = {
    special3 = "Default.Zoom",
    single_shot = "Weapon_SG550.Single",
},
Primary = {
    Ammo = "BULLET_PLAYER_556MM",
    Automatic = true,
    Damage = 70,
    Penetration = 2,
    ClipSize = 30,
    CycleTime = 0.25,
    Accuracy = {
        InaccuracyJumpAlt = 0.4372,
        RecoveryTimeCrouch = 0.2097,
        InaccuracyCrouchAlt = 0.0015,
        InaccuracyStand = 0.0257,
        InaccuracyJump = 0.4372,
        MaxInaccuracy = 0,
        InaccuracyLandAlt = 0.0437,
        InaccuracyFire = 0.0382,
        InaccuracyLadderAlt = 0.1093,
        InaccuracyMoveAlt = 0.2186,
        InaccuracyLand = 0.0437,
        AccuracyOffset = 0,
        AccuracyDivisor = -1,
        SpreadAlt = 0.0003,
        InaccuracyMove = 0.2186,
        InaccuracyLadder = 0.1093,
        Spread = 0.0003,
        InaccuracyStandAlt = 0.002,
        RecoveryTimeStand = 0.2935,
        InaccuracyFireAlt = 0.0382,
        InaccuracyCrouch = 0.0192,
    },
    Bullets = 1,
    DefaultClip = 30,
    Range = 8192,
},
Secondary = {
    Ammo = "None",
    ClipSize = -1,
},
WepSelData = {
    "CSweaponsSmall",
    "O",
},
IconOverride = "VGUI/gfx/VGUI/weapon_sg550",
IdleInterval = 60,
CanScope = true,
MuzzleFlashStyle = "CS_MUZZLEFLASH_X",
TimeToIdle = 1.8,
})