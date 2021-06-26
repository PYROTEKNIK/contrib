-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
Base = "weapon_css",
PrintName = "#Cstrike_WPNHUD_G3SG1",
WeaponType = "SniperRifle",
WorldModel = "models/weapons/w_snip_g3sg1.mdl",
ViewModel = "models/weapons/v_snip_g3sg1.mdl",
ViewModelFlip = true,
HoldType = "ar2",
Slot = 3,
Spawnable = true,
Category = "Counter-Strike:Source",
CSMuzzleFlashes = true,
CSMuzzleX = false,
MuzzleFlashScale = 1.5,
Sounds = {
    special3 = "Default.Zoom",
    single_shot = "Weapon_G3SG1.Single",
},
Primary = {
    Ammo = "BULLET_PLAYER_762MM",
    Automatic = true,
    Damage = 80,
    Penetration = 3,
    ClipSize = 20,
    CycleTime = 0.25,
    Accuracy = {
        InaccuracyJumpAlt = 0.4655,
        RecoveryTimeCrouch = 0.2224,
        InaccuracyCrouchAlt = 0.0015,
        InaccuracyStand = 0.0258,
        InaccuracyJump = 0.4655,
        MaxInaccuracy = 0,
        InaccuracyLandAlt = 0.0465,
        InaccuracyFire = 0.0498,
        InaccuracyLadderAlt = 0.1163,
        InaccuracyMoveAlt = 0.2327,
        InaccuracyLand = 0.0465,
        AccuracyOffset = 0,
        AccuracyDivisor = -1,
        SpreadAlt = 0.0003,
        InaccuracyMove = 0.2327,
        InaccuracyLadder = 0.1163,
        Spread = 0.0003,
        InaccuracyStandAlt = 0.002,
        RecoveryTimeStand = 0.3114,
        InaccuracyFireAlt = 0.0498,
        InaccuracyCrouch = 0.0193,
    },
    Bullets = 1,
    DefaultClip = 20,
    Range = 8192,
},
Secondary = {
    Ammo = "None",
    ClipSize = -1,
},
WepSelData = {
    "CSweaponsSmall",
    "I",
},
IconOverride = "VGUI/gfx/VGUI/weapon_g3sg1",
IdleInterval = 60,
CanScope = true,
MuzzleFlashStyle = "CS_MUZZLEFLASH_X",
TimeToIdle = 1.8,
})