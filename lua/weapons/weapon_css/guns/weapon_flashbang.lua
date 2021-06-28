-- This file is subject to copyright - contact swampservers@gmail.com for more information.
    -- INSTALL: CINEMA
    AddCSLuaFile()
    ParseCSScript([[
        WeaponData
{
	"MaxPlayerSpeed" 		"250"
	"WeaponType" 			"Grenade"
	"WeaponPrice" 			"200"
	"WeaponArmorRatio"		"1"
	"CrosshairMinDistance"		"7"
	"CrosshairDeltaDistance"	"3"
	"Team" 				"ANY"
	"BuiltRightHanded" 		"0"
	"PlayerAnimationExtension"	"gren"
	"MuzzleFlashScale"		"0"
	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_NONE"
	"CanEquipWithShield" 		"1"
	"AddonModel"			"models/weapons/w_eq_flashbang_thrown.mdl"
	
	// Weapon characteristics:
	"Penetration"			"1"
	"Damage"			"50"
	"Range"				"4096"
	"RangeModifier"			"0.99"
	"Bullets"			"1"
	
	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_Flashbang"
	"viewmodel"			"models/weapons/v_eq_flashbang.mdl"
	"playermodel"			"models/weapons/w_eq_flashbang.mdl"
	
	"anim_prefix"			"anim"
	"bucket"			"3"
	"bucket_position"		"2"

	"clip_size"			"-1"
	"default_clip"			"1"
	"primary_ammo"			"AMMO_TYPE_FLASHBANG"
	"secondary_ammo"		"None"

	"weight"			"1"
	"ITEM_FLAG_EXHAUSTIBLE"		"1"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"G"
		}
		"weapon_s"
		{	
				"font"		"CSweapons"
				"character"	"G"
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"P"
		}
		"crosshair"
		{
				"file"		"sprites/crosshairs"
				"x"			"0"
				"y"			"48"
				"width"		"24"
				"height"	"24"
		}
		"autoaim"
		{
				"file"		"sprites/crosshairs"
				"x"			"0"
				"y"			"48"
				"width"		"24"
				"height"	"24"
		}
	}
	ModelBounds
	{
		Viewmodel
		{
			Mins	"-6 -9 -15"
			Maxs	"15 11 0"
		}
		World
		{
			Mins	"-4 -1 -3"
			Maxs	"3 6 1"
		}
		Addon
		{
			Mins	"-3 -2 -3"
			Maxs	"2 2 4"
		}
	}
}    ]])
    