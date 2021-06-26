-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- This file was generated from the counter-strike source keyvalues file for this weapon. Please excuse the shitty formatting
AddCSLuaFile()
table.Merge(SWEP,{
Base = "weapon_css_grenade",
PrintName = "#Cstrike_WPNHUD_C4",
WeaponType = "C4",
WorldModel = "models/weapons/w_c4.mdl",
ViewModel = "models/weapons/v_c4.mdl",
ViewModelFlip = true,
HoldType = "slam",
Slot = 4,
Spawnable = true,
Category = "Counter-Strike:Source Grenades",
CSMuzzleFlashes = true,
CSMuzzleX = false,
MuzzleFlashScale = 1,
Sounds = {
},
Primary = {
    Penetration = 1,
    Ammo = "None",
    Damage = 50,
    ClipSize = 30,
    Bullets = 1,
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
    "\\",
},
IconOverride = "VGUI/gfx/VGUI/weapon_c4",
AllowFlipping = 0,
})