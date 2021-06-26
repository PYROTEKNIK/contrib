-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
Base = "weapon_css",
PrintName = "#Cstrike_WPNHUD_Elites",
WeaponType = "Pistol",
WorldModel = "models/weapons/w_pist_elite.mdl",
ViewModel = "models/weapons/v_pist_elite.mdl",
ViewModelFlip = true,
HoldType = "pistol",
Slot = 1,
Spawnable = true,
Category = "Counter-Strike:Source",
CSMuzzleFlashes = true,
CSMuzzleX = false,
MuzzleFlashScale = 1,
Sounds = {
    single_shot = "Weapon_Elite.Single",
},
Primary = {
    Ammo = "BULLET_PLAYER_9MM",
    Automatic = false,
    Bullets = 1,
    Penetration = 1,
    ClipSize = 30,
    CycleTime = 0.12,
    Accuracy = {
        RecoveryTimeCrouch = 0.2475,
        InaccuracyFire = 0.0316,
        InaccuracyLand = 0.0592,
        InaccuracyMove = 0.0177,
        InaccuracyLadder = 0.0197,
        Spread = 0.004,
        InaccuracyStand = 0.008,
        RecoveryTimeStand = 0.297,
        InaccuracyJump = 0.2962,
        InaccuracyCrouch = 0.006,
    },
    Damage = 45,
    DefaultClip = 30,
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
    "S",
},
IconOverride = "VGUI/gfx/VGUI/weapon_elite",
DroppedModel = "models/weapons/w_pist_elite_dropped.mdl",
AddonModel = "models/weapons/w_pist_elite_single.mdl",
})