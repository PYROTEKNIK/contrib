﻿AddCSLuaFile()
DEFINE_BASECLASS("gun")
SWEP.GunType = "autoshotgun"
CSParseWeaponInfo(SWEP, [[WeaponData
{
	"MaxPlayerSpeed" 		"240"
	"WeaponType" 			"Shotgun"
	"FullAuto"				1
	"WeaponPrice"			"3000"
	"WeaponArmorRatio"		"1.0"
	"CrosshairMinDistance"		"9"
	"CrosshairDeltaDistance"	"4"
	"Team"				"ANY"
	"BuiltRightHanded"		"0"
	"PlayerAnimationExtension"	"xm1014"
	"MuzzleFlashScale"		"1.3"

	"CanEquipWithShield"		"0"

	// Weapon characteristics:
	"Penetration"			"1"
	"Damage"			"22"
	"Range"				"3000"
	"RangeModifier"			"0.70"
	"Bullets"			"6"
	"CycleTime"			"0.25"

	// New accuracy model parameters

	"Spread"					0.04000
	"InaccuracyCrouch"			0.00750
	"InaccuracyStand"			0.01000
	"InaccuracyJump"			0.41176
	"InaccuracyLand"			0.08235
	"InaccuracyLadder"			0.07721
	"InaccuracyFire"			0.03644
	"InaccuracyMove"			0.03544

	"RecoveryTimeCrouch"		0.32894
	"RecoveryTimeStand"			0.46052

	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_xm1014"
	"viewmodel"			"models/weapons/v_shot_xm1014.mdl"
	"playermodel"			"models/weapons/w_shot_xm1014.mdl"

	"anim_prefix"			"anim"
	"bucket"			"0"
	"bucket_position"		"0"

	"clip_size"			"7"

	"primary_ammo"			"BULLET_PLAYER_BUCKSHOT"
	"secondary_ammo"		"None"

	"weight"			"20"
	"item_flags"			"0"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
		//"reload"			"Default.Reload"
		//"empty"				"Default.ClipEmpty_Rifle"
		"single_shot"			"Weapon_XM1014.Single"
		special3			Default.Zoom
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"]"
		}
		"weapon_s"
		{
				"font"		"CSweapons"
				"character"	"]"
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
			Mins	"-13 -3 -11"
			Maxs	"29 10 0"
		}
		World
		{
			Mins	"-4 -8 -4"
			Maxs	"30 8 6"
		}
	}
}]])
SWEP.Spawnable = true
SWEP.Slot = 0
SWEP.SlotPos = 0

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)
    self:NetworkVar("Int", 0, "SpecialReload")
end

function SWEP:Initialize()
    BaseClass.Initialize(self)
    self:SetHoldType("shotgun")
    self:SetWeaponID(CS_WEAPON_XM1014)
    self:SetSpecialReload(0)
end

function SWEP:PrimaryAttack()
    local pPlayer = self.Owner
    if not IsValid(pPlayer) then return end

    if pPlayer:WaterLevel() == 3 then
        self:PlayEmptySound()
        self:SetNextPrimaryFire(CurTime() + 0.15)

        return
    end

    if self:GetNextPrimaryAttack() > CurTime() then return end
    self:GunFire(self:BuildSpread())
    self:SetSpecialReload(0)
end

function SWEP:GunFire(spread)
    if not self:BaseGunFire(spread, self:GetWeaponInfo().CycleTime, true) then return end

    if self:GetOwner():GetAbsVelocity():Length2D() > 5 then
        self:KickBack(0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7)
    elseif not self:GetOwner():OnGround() then
        self:KickBack(0.9, 0.45, 0.35, 0.04, 5.25, 3.5, 4)
    elseif self:GetOwner():Crouching() then
        self:KickBack(0.275, 0.2, 0.125, 0.02, 3, 1, 9)
    else
        self:KickBack(0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8)
    end
end

function SWEP:Reload()
    local pPlayer = self.Owner
    if not IsValid(pPlayer) then return end
    if pPlayer:GetAmmoCount(self.Primary.Ammo) <= 0 or self:Clip1() >= self.Primary.ClipSize then return end
    if self:GetNextPrimaryAttack() > CurTime() then return end

    if self:GetSpecialReload() == 0 then
        pPlayer:SetAnimation(PLAYER_RELOAD)
        self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
        self:SetSpecialReload(1)
        self:SetNextPrimaryAttack(CurTime() + 0.5)
        self:SetNextIdle(CurTime() + 0.5)
        -- DoAnimationEvent( PLAYERANIMEVENT_RELOAD_START ) - Missing event

        return true
    elseif self:GetSpecialReload() == 1 then
        if self:GetNextIdle() > CurTime() then return true end
        self:SetSpecialReload(2)
        self:SendWeaponAnim(ACT_VM_RELOAD)
        self:SetNextIdle(CurTime() + 0.5)

        if self:Clip1() >= 6 then
            pPlayer:DoAnimationEvent(PLAYERANIMEVENT_RELOAD_END)
        else
            pPlayer:DoAnimationEvent(PLAYERANIMEVENT_RELOAD_LOOP)
        end
    else
        self:SetClip1(self:Clip1() + 1)
        pPlayer:DoAnimationEvent(PLAYERANIMEVENT_RELOAD)
        pPlayer:RemoveAmmo(1, self.Primary.Ammo)
        self:SetSpecialReload(1)
    end

    return true
end

function SWEP:Think()
    local pPlayer = self.Owner
    if not IsValid(pPlayer) then return end

    if self:GetNextIdle() < CurTime() then
        if self:Clip1() == 0 and self:GetSpecialReload() == 0 and pPlayer:GetAmmoCount(self.Primary.Ammo) ~= 0 then
            self:Reload()
        elseif self:GetSpecialReload() ~= 0 then
            if self:Clip1() ~= 7 and pPlayer:GetAmmoCount(self.Primary.Ammo) ~= 0 then
                self:Reload()
            else
                self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
                self:SetSpecialReload(0)
                self:SetNextIdle(CurTime() + 1)
            end
        else
            self:SendWeaponAnim(ACT_VM_IDLE)
        end
    end
end

SWEP.AdminOnly = false
