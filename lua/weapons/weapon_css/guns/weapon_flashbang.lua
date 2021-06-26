-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
Base = "weapon_css_grenade",
PrintName = "#Cstrike_WPNHUD_Flashbang",
WeaponType = "Grenade",
WorldModel = "models/weapons/w_eq_flashbang.mdl",
ViewModel = "models/weapons/v_eq_flashbang.mdl",
ViewModelFlip = true,
HoldType = "grenade",
Slot = 3,
Spawnable = true,
Category = "Counter-Strike:Source Grenades",
CSMuzzleFlashes = true,
CSMuzzleX = false,
MuzzleFlashScale = 0,
Sounds = {
},
Primary = {
    Penetration = 1,
    Ammo = "AMMO_TYPE_FLASHBANG",
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
    "G",
},
IconOverride = "VGUI/gfx/VGUI/weapon_flashbang",
AddonModel = "models/weapons/w_eq_flashbang_thrown.mdl",
MuzzleFlashStyle = "CS_MUZZLEFLASH_NONE",
ITEM_FLAG_EXHAUSTIBLE = 1,
default_clip = 1,
})