-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
Base = "weapon_css",
PrintName = "#Cstrike_WPNHUD_Knife",
WeaponType = "Knife",
WorldModel = "models/weapons/w_knife_t.mdl",
ViewModel = "models/weapons/v_knife_t.mdl",
ViewModelFlip = false,
HoldType = "pistol",
Slot = 4,
Spawnable = true,
Category = "Counter-Strike:Source",
CSMuzzleFlashes = true,
CSMuzzleX = false,
MuzzleFlashScale = 0,
Sounds = {
    single_shot = "Weapon_DEagle.Single",
    reload = "Default.Reload",
    empty = "Default.ClipEmpty_Rifle",
},
Primary = {
    Penetration = 1,
    Ammo = "None",
    Bullets = 1,
    ClipSize = -1,
    Damage = 50,
    DefaultClip = -1,
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
    "J",
},
IconOverride = "VGUI/gfx/VGUI/weapon_knife",
default_clip = 1,
MuzzleFlashStyle = "CS_MUZZLEFLASH_NONE",
})