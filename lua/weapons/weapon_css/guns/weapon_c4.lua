-- This file is subject to copyright - contact swampservers@gmail.com for more information.
    -- INSTALL: CINEMA
    AddCSLuaFile()
    ParseCSScript([[
        WeaponData
{
	"MaxPlayerSpeed"		"250"
	"WeaponType"			"C4"
	"WeaponPrice"			"0"
	"WeaponArmorRatio"		"1.0"
	"CrosshairMinDistance"		"6"
	"CrosshairDeltaDistance"	"3"
	"Team"				"TERRORIST"
	"BuiltRightHanded" 		"0"
	"PlayerAnimationExtension"	"c4"
	"MuzzleFlashScale"		"1"
	
	"CanEquipWithShield"		"1"
	"AllowFlipping" 		"0"
	
	// Weapon characteristics:
	"Penetration"			"1"
	"Damage"			"50"
	"Range"				"4096"
	"RangeModifier"			"0.99"
	"Bullets"			"1"
		
	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_C4"
	"viewmodel"			"models/weapons/v_c4.mdl"
	"playermodel"			"models/weapons/w_c4.mdl"
	"shieldviewmodel"		"models/weapons/v_c4.mdl"
	"anim_prefix"			"anim"
	"bucket"			"4"
	"bucket_position"		"0"

	"clip_size"			"30"
	
	"primary_ammo"			"None"
	"secondary_ammo"		"None"

	"weight"			"0"
	"item_flags"			"0"

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
				"character"	"\"
		}
		"weapon_s"
		{	
				"font"		"CSweapons"
				"character"	"\"
		}
		"ammo"
		{
				"file"		"sprites/640hud1"
				"x"		"182"
				"y"		"24"
				"width"		"26"
				"height"		"24"
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
			Mins	"-4 -8 -17"
			Maxs	"20 13 1"
		}
		World
		{
			Mins	"-3 0 -4"
			Maxs	"7 12 4"
		}
	}
}    ]])

SWEP.Primary.Ammo = "CS_C4"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.ClipSize = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.Projectile = "cs_c4"   

function SWEP:Equip(ply)
    if(ply:GetAmmoCount(self.Primary.Ammo) < 1)then
    ply:GiveAmmo(1,self.Primary.Ammo)
    end
end

function SWEP:EquipAmmo(ply)
    ply:GiveAmmo(1,self.Primary.Ammo)
end

function SWEP:SetupDataTables()
    self:NetworkVar("Float",0,"ThrowReady")
    self:NetworkVar("Float",1,"ThrowTime")
    self:NetworkVar("Int",0,"TimerSetting")
end

SWEP.Timers = {10,30,60,120,600}

function SWEP:GetTimer()
    return self.Timers[self:GetTimerSetting() or 1 ] or 69
end

function SWEP:Throw()
    local ply = self:GetOwner()
    if(SERVER)then
        local proj = ents.Create(self.Projectile)
            local trace = ply:GetEyeTrace()
            if(trace.HitPos:Distance(ply:GetShootPos()) > 64)then 
                local tr = util.GetPlayerTrace( ply, Vector(0,0,-1) )
                trace = util.TraceLine(tr)
            end
            proj:SetPos(trace.HitPos)
            

            local ang = trace.HitNormal:AngleEx(ply:EyeAngles():Up())
            ang:RotateAroundAxis(ang:Right(),-90)
            ang:RotateAroundAxis(ang:Up(),180)


            proj:SetAngles(ang)
            proj:SetOwner(self:GetOwner())
            proj:Spawn()

            if(trace.Entity != game.GetWorld() and IsValid(trace.Entity))then
                local ent = trace.Entity
                local phys = ent:GetPhysicsObjectNum(trace.PhysicsBone)
                proj:GetPhysicsObject():Wake()
                if(IsValid(phys))then
                    constraint.Weld( proj, ent, 0, trace.PhysicsBone, 0, true )
                else
                    local bone = ent:TranslatePhysBoneToBone(trace.PhysicsBone)
                    proj:SetParent(ent,bone)
                    proj:SetMoveType(MOVETYPE_NONE)
                end
                
            else
                proj:GetPhysicsObject():EnableMotion(false)
            end


            proj:SetTimer(self:GetTimer())
            
            proj:EmitSound("c4.plant")
        end
    self:TakePrimaryAmmo(1)
end

function SWEP:PrimaryAttack()
    -- Make sure we can shoot first
    if (not self:CanPrimaryAttack()) then return end
    
    if(self:GetThrowReady() != 0)then return end
    
    if(self:GetThrowReady() == 0)then
        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        self:SetThrowReady(CurTime() + 2.5)
        self:SetNextSecondaryFire(CurTime() + 999)

        self.WasSecondary = false
        return 
    end 
   
end

function SWEP:Holster()
    self:SetThrowReady(0)
    self.EmptyHands = nil
    return true
end

function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
    self:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:SecondaryAttack()
    local ply = self:GetOwner()
    local vm = ply:GetViewModel()
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:SetTimerSetting(self:GetTimerSetting() < #self.Timers and self:GetTimerSetting() + 1 or 1)
    vm:SetCycle(0.8)
    vm:SetPlaybackRate(2)
    self:TimerSimple(0.5,function()
        self:SendWeaponAnim(ACT_VM_IDLE)
    end)

    self.WasSecondary = true
    self:SetNextPrimaryFire(CurTime() + 1)
    
    self:SetNextSecondaryFire(CurTime() + 1)

end
if(CLIENT)then
    local size =55
surface.CreateFont( "BombFont", {
	font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = size,
	weight = 500,
	blursize = 1,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "BombFont2", {
	font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = size,
	weight = 500,
	blursize = 8,
	scanlines = 4,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

end

function SWEP:PostDrawViewModel( vm,wep,ply )
    for i=0,vm:GetBoneCount()-1 do
        --print(vm:GetBoneName(i))
    end
    local pos,ang = vm:GetBonePosition(vm:LookupBone("v_weapon.c4") or 0)
    ang:RotateAroundAxis(ang:Forward(),-90)
    ang:RotateAroundAxis(ang:Up(),180)
    
    pos = pos + ang:Up() * 3.7
    pos = pos + ang:Right() * -0.5
    pos = pos + ang:Forward() * 4.4

    local label = self.LABEL or ""
    cam.Start3D2D(pos,ang,1/50)
    
    draw.SimpleText(label,"BombFont",0,0,Color(255,44,0,150),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.SimpleText(label,"BombFont2",0,0,Color(255,105,72,50),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    
    cam.End3D2D()
end

function SWEP:DrawWorldModel()
    self:DrawModel()
    PrintTable(self:GetAttachments())
    local pos,ang = self:GetBonePosition(self:LookupBone("v_weapon.c4") or 0)
    ang:RotateAroundAxis(ang:Forward(),0)
    ang:RotateAroundAxis(ang:Up(),0)
    
    pos = pos + ang:Up() * 3.7
    pos = pos + ang:Right() * -0.5
    pos = pos + ang:Forward() * 4.4

    local label = self.LABEL or ""
    cam.Start3D2D(pos,ang,1)
    
    draw.SimpleText(label,"BombFont",0,0,Color(255,44,0,150),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.SimpleText(label,"BombFont2",0,0,Color(255,105,72,50),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    
    cam.End3D2D()

end


local lol = "chungus"
function SWEP:FireAnimationEvent( pos, ang, event, options )
    if(event == 7001 and self.WasSecondary)then
        if(options == "")then return end
        if(options == "7")then
            self.LABEL = ""
            return
        end

        self:ResetLabel()
        return
    end

    if(event == 7001)then
        if(options == "")then
            self.LABEL = ""
            return
        end
        self.LABEL = self.LABEL .. lol[string.len(self.LABEL) + 1]
    end
end

function SWEP:ResetLabel()
    local times = string.FormattedTime(self:GetTimer() , "%02i:%02i" )
    self.LABEL = times
end

function SWEP:Think()
    if(self.PuttingAway)then return end

    if(self:GetThrowReady() > 0)then
        local hold = self:GetOwner():KeyDown(IN_ATTACK)
        if(CurTime() >= self:GetThrowReady() and hold)then
            
            self:SetThrowReady(0)
            self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
            self:SetNextPrimaryFire(CurTime() + 2.4)
            self:SetNextSecondaryFire(CurTime() + 2.4)
            self:SetThrowTime(CurTime() + 0.2) 
            self:ResetLabel()
            return 
        end
        if(!hold)then
            self:ResetLabel()
            self:SetThrowReady(0)
            self:SendWeaponAnim(ACT_VM_IDLE)
            self:SetNextPrimaryFire(CurTime() + 0.4)
            self:SetNextSecondaryFire(CurTime() + 0.4)
            return
        end

    end
    if(self:GetThrowTime() > 0 and self:GetThrowTime() >= CurTime())then
        self:Throw()
        self:SetThrowTime(0) 
        if(SERVER and self:Ammo1() <= 0)then
            self:Remove()
            return
        end
        self.EmptyHands = true
    end 

    if(self.EmptyHands and self:GetNextPrimaryFire()-0.2 <= CurTime())then
        self:SendWeaponAnim(ACT_VM_DRAW)
        self.EmptyHands = false
    end
end