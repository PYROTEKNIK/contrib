-- This file is subject to copyright - contact swampservers@gmail.com for more information.
    -- INSTALL: CINEMA
    AddCSLuaFile()
    ParseCSScript([[
        WeaponData
{
	"MaxPlayerSpeed" 		"220"
	"WeaponType"			"Shotgun"
	"FullAuto"				1
	"WeaponPrice"			"1700"
	"WeaponArmorRatio"		"1.0"
	"CrosshairMinDistance"		"8"
	"CrosshairDeltaDistance"	"6"
	"Team"				"ANY"
	"BuiltRightHanded"		"0"
	"PlayerAnimationExtension" 	"m3s90"
	"MuzzleFlashScale"		"1.3"
	
	"CanEquipWithShield"		"0"
	
	
	// Weapon characteristics:
	"Penetration"			"1"
	"Damage"			"26"
	"Range"				"3000"
	"RangeModifier"			"0.70"
	"Bullets"			"9"
	"CycleTime"			"0.88"
	
	// New accuracy model parameters
	"Spread"					0.04000
	"InaccuracyCrouch"			0.00750
	"InaccuracyStand"			0.01000
	"InaccuracyJump"			0.42000
	"InaccuracyLand"			0.08400
	"InaccuracyLadder"			0.07875
	"InaccuracyFire"			0.04164
	"InaccuracyMove"			0.04320
								 
	"RecoveryTimeCrouch"		0.29605
	"RecoveryTimeStand"			0.41447
	
	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_m3"
	"viewmodel"			"models/weapons/v_shot_m3super90.mdl"
	"playermodel"			"models/weapons/w_shot_m3super90.mdl"
	
	"anim_prefix"			"anim"
	"bucket"			"0"
	"bucket_position"		"0"

	"clip_size"			"8"
	
	"primary_ammo"			"BULLET_PLAYER_BUCKSHOT"
	"secondary_ammo"		"None"

	"weight"			"20"
	"item_flags"			"0"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
		//"reload"			"Default.Reload"
		//"empty"				"Default.ClipEmpty_Rifle"
		"single_shot"		"Weapon_M3.Single"
		special3			Default.Zoom
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"K"
		}
		"weapon_s"
		{	
				"font"		"CSweapons"
				"character"	"K"
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"J"
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
			Mins	"-13 -3 -13"
			Maxs	"26 10 -3"
		}
		World
		{
			Mins	"-9 -8 -5"
			Maxs	"28 9 9"
		}
	}
}    ]])
    

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "Aiming")
    self:NetworkVar("Bool", 0, "ShotgunLoad")
end

function SWEP:Reload()
	if(self:GetNextPrimaryFire() > CurTime() )then return end
	if(self:Ammo1() < 1)then return end

	if(self:Clip1() >= self.Primary.ClipSize)then return end

	
	if(!self:GetShotgunLoad())then
		self:SetNextPrimaryFire(CurTime() + 0.5)
		self:SendWeaponAnim(ACT_VM_RELOAD)
		self:SetShotgunLoad(true)
		self.Owner:RemoveAmmo( 1, self.Weapon:GetPrimaryAmmoType() )
		self:SetClip1(self:Clip1() + 1)
		self:TimerCreate("LoadShells",0.5,1,function()
			self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
			
			
			if(self:Clip1() < self.Primary.ClipSize and !self:GetOwner():KeyDown(IN_ATTACK))then
				self:TimerSimple(0,function()
				self:SetShotgunLoad(false)
				self:Reload()
				end)
			else
				self:SetShotgunLoad(false)
				self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
				self:SetNextPrimaryFire(CurTime() + 1)
			end
		end)
	end
end

function SWEP:PrimaryAttack()
	if(self:GetShotgunLoad())then
		return
	end
	self.BaseClass.PrimaryAttack(self)
end
function SWEP:Holster() 
	self:SetShotgunLoad(false)
	self:TimerRemove("LoadShells")
    self:SetAiming(0)
    return true
end