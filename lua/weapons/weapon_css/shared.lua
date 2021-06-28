AddCSLuaFile()

include("cosmetic.lua")
AddCSLuaFile("cosmetic.lua")



include("load.lua")
AddCSLuaFile("load.lua")



SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false
SWEP.Primary.DefaultClip = 5
SWEP.Primary.CycleTime = 0.2
SWEP.Primary.ClipSize = 5
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1  
SWEP.Secondary.DefaultClip = -1
SWEP.Spawnable = false
SWEP.Category = "Counter-Strike:Source"
SWEP.Sounds = {}

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)

end

function SWEP:FireAnimationEvent( pos, ang, event, options )
	
	-- Disables animation based muzzle event
	if ( event == 21 ) then return true end	

	-- Disable thirdperson muzzle flash
	if ( event == 5003 ) then return true end

end

function SWEP:IsMoving()
    local ply = self:GetOwner()
 
    return ply:GetVelocity():Length() > 45
end
 
function SWEP:Deploy()
    local ply = self:GetOwner()
    if(self.DualWield)then 
    ply:GetViewModel( 2 ):SetWeaponModel( self.ViewModel, ply:GetActiveWeapon() )
    end
    self:SetHoldType(self.HoldType)
    self:PlaySequence(ACT_VM_DRAW)

end

SWEP.SendWeaponAnim_orgin = FindMetaTable("Weapon").SendWeaponAnim

function SWEP:PlaySequence(act,fire)
    if(!self.DualWield)then self:SendWeaponAnim(act) return end
    self.DuelAlternate = !self.DuelAlternate
    local ply = self:GetOwner()
    if(self.DuelAlternate or !fire)then
        if(fire)then ply:GetViewModel( 2 ):SendViewModelMatchingSequence(ply:GetViewModel( 2 ):SelectWeightedSequence(ACT_VM_IDLE))  end
        self:SendWeaponAnim(act)
        
    end
    if(!self.DuelAlternate or !fire)then
        if(fire)then self:SendWeaponAnim(ACT_VM_IDLE) end
        ply:GetViewModel( 2 ):SendViewModelMatchingSequence(ply:GetViewModel( 2 ):SelectWeightedSequence(act))
    end
    
end


function SWEP:GetViewModelPosition(pos, ang)
    if(!self.DualWield)then return pos,ang end
	local vm = self:GetOwner():GetViewModel() 

    pos = pos + ang:Forward()*-1
    pos = pos + ang:Right()*1
    pos = pos + ang:Up()*-1
    local reload = vm:GetSequenceActivity(vm:GetSequence()) == ACT_VM_RELOAD and vm:GetCycle() <= 0.8
    self.RelDropLerp = math.Approach(self.RelDropLerp or 0 , reload and 1 or 0,FrameTime()*0.3)
    ang:RotateAroundAxis(ang:Right(),-40*self.RelDropLerp)
	
	return pos, ang
end

 

function SWEP:GetInaccuracy()
    local str = "Inaccuracy"
    local ply = self:GetOwner()
    local tp = "Stand"

    

    if (ply:GetMoveType() == MOVETYPE_LADDER) then
        tp = "Ladder"
    end

    if (self:IsMoving()) then
        tp = "Move"
    end

    if (ply:Crouching()) then
        tp = "Crouch"
    end

    if (not ply:OnGround()) then
        tp = "Jump"
    end

    str = str .. tp

    if (self.AimScoped[self:GetAiming()] and self.Primary.Accuracy[str.."Alt"]) then
        str = str .. "Alt"
    end
    return self.Primary.Accuracy[str] * (self.DualWield and 4 or 1) or 0
end

function SWEP:GetRecoveryTime()
    local ply = self:GetOwner()

    if (ply:OnGround()) then
        if (ply:Crouching()) then return (self.Primary.Accuracy.RecoveryTimeCrouch) or 0 end

        return (self.Primary.Accuracy.RecoveryTimeStand) or 0
    end

    return 0
end

function SWEP:AddSpread()
    self.TrackedSpread = self.TrackedSpread or 0
    local addspread = (self.Primary.Accuracy.InaccuracyFire or 0) *  (self.DualWield and 4 or 1)
    

    self.TrackedSpread = math.Clamp(self.TrackedSpread + addspread, 0, self:GetMaxSpread())
end

function SWEP:GetMaxSpread()
    return self.Primary.Accuracy.InaccuracyMove or 0
end

function SWEP:Think()
    local rate = (self:GetMaxSpread() / self:GetRecoveryTime())

    if (self:GetNextPrimaryFire() > CurTime()) then
        rate = rate / 10
    end

    local delta = FrameTime() * rate
    self.TrackedSpread = math.Clamp((self.TrackedSpread or 0) - (delta), 0, self:GetMaxSpread())
end

function SWEP:GetSpread()
    return math.max((self.Primary.Accuracy.Spread or 0) + self:GetInaccuracy() + (self.TrackedSpread or 0), 0)
end

function SWEP:GetKick()
    return self.Primary.Accuracy.InaccuracyFire
end

function SWEP:GetAimVector()
    local aimv = self.Owner:GetAimVector():Angle(self.Owner:EyeAngles():Up())
    aimv = aimv + self.Owner:GetViewPunchAngles()
    aimv = aimv:Forward()

    return aimv
end

function SWEP:Reload()
    if(self:Ammo1() > 0 and self:Clip1() < self.Primary.ClipSize)then
    self:DefaultReload(ACT_VM_RELOAD)
    self:PlaySequence(ACT_VM_RELOAD)
    end
end

function SWEP:ShootBullet(damage, num_bullets, aimcone, ammo_type, force, tracer)
    local bullet = {}
    bullet.Num = num_bullets
    bullet.Src = self.Owner:GetShootPos() -- Source
    bullet.Dir = self:GetAimVector() -- Dir of bullet
    bullet.Spread = Vector(aimcone, aimcone, 0) -- Aim Cone
    bullet.Tracer = tracer or 5 -- Show a tracer on every x bullets
    bullet.Force = force or 1 -- Amount of force to give to phys objects
    bullet.Damage = damage
    bullet.Attacker = self.Owner
    bullet.AmmoType = ammo_type or self.Primary.Ammo
    self:FireBullets(bullet)
    self:MuzzleFlash()
    self:PlaySequence(ACT_VM_PRIMARYATTACK,true)
end

function SWEP:CanPrimaryAttack()

    return self:Clip1() > 0

end

function SWEP:PrimaryAttack()
    -- Make sure we can shoot first
    if (not self:CanPrimaryAttack()) then return end

    -- Play shoot sound
    if (self.Sounds.single_shot) then
        self:EmitSound(self.Sounds.single_shot)
    end
 
    local kick = Vector(0, -1, self:GetKick()):Angle().pitch
    kick = math.NormalizeAngle(kick)

    if (not self.Owner:IsNPC()) then
        self.Owner:ViewPunch(Angle(kick, math.Rand(-kick / 2, kick / 2), 0))
    end 

    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:ShootBullet(self.Damage, self.Primary.Bullets, self:GetSpread(), self.Primary.Ammo)
    self:AddSpread()
    self:TakePrimaryAmmo(1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.CycleTime)
end

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "Aiming")
end
  
function SWEP:SecondaryAttack()
   if(!self.CanScope)then return end
    self:SetAiming(self.AimFOV[self:GetAiming() + 1] and self:GetAiming() + 1 or 0)

    if (self.Sounds.special3) then
        self:EmitSound(self.Sounds.special3)
    end

    self:SetNextSecondaryFire(CurTime() + 0.1)
end

SWEP.AimFOV = {30,15}
SWEP.AimSens = {0.2,0.1}
SWEP.AimScoped =  {true,true}

function SWEP:TranslateFOV(fov)
    return self.AimFOV[self:GetAiming()]
end 
function SWEP:AdjustMouseSensitivity()
    return self.AimSens[self:GetAiming()]
end
function SWEP:Holster() 
    local ply = self:GetOwner()
    if(self.DualWield)then 
        ply:GetViewModel( 2 ):SetWeaponModel( self.ViewModel, nil )
    end
    self:SetAiming(0)
    return true
end




function SWEP:DrawHUDBackground()
    if (! self.AimScoped[self:GetAiming()]) then return end
    local x, y = ScrW() / 2, ScrH() / 2
    local scopemat = Material("sprites/scope_arc")
    local heightgap = 32
    local size = (ScrH()) / 2 - heightgap
    surface.SetMaterial(scopemat)
    surface.SetDrawColor(Color(0, 0, 0, 255))
    surface.DrawRect(0, 0, ScrW(), heightgap)
    surface.DrawRect(0, ScrH() - heightgap, ScrW(), heightgap)
    surface.DrawRect(0, heightgap, ScrW() / 2 - size, ScrH() - heightgap)
    surface.DrawRect(ScrW() / 2 + size, heightgap, ScrW() / 2 - size, ScrH() - heightgap)



    surface.DrawTexturedRectUV(x, y, size, size, 0, 0, 1, 1)
    surface.DrawTexturedRectUV(x - size, y, size, size, 1, 0, 0, 1)
    surface.DrawTexturedRectUV(x, y - size, size, size, 0, 1, 1, 0)
    surface.DrawTexturedRectUV(x - size, y - size, size, size, 1, 1, 0, 0)
    surface.SetDrawColor(Color(0, 0, 0, 255))
    surface.DrawRect(ScrW() / 2 - 1, 0, 1, ScrH())
    surface.DrawRect(0, ScrH() / 2 - 1, ScrW(), 1)

end

SWEP.CrosshairInfo = {
    file = "sprites/crosshairs",
    x = 0,
    y = 48,
    width = 24,
    height = 24
}

function SWEP:DoDrawCrosshair(x, y)
    local clr = NamedColor("FGColor")
    local ply = self:GetOwner()
    local dir = self:GetAimVector() + ply:EyeAngles():Right() * self:GetSpread()
    
    local data2D1 = (EyePos() + self:GetAimVector()):ToScreen() -- Gets the position of the entity on your screen
    if (data2D1.visible) then
    x,y = data2D1.x,data2D1.y
    end

    local data2D = (EyePos() + (dir * 5)):ToScreen() -- Gets the position of the entity on your screen
    local r

    surface.SetDrawColor(clr)
    if (data2D.visible) then
        r = Vector(x, y, 0):Distance(Vector(data2D.x, data2D.y, 0))
        self.LerpCrosshair = Lerp(0.1,self.LerpCrosshair or r,r)
        r = self.LerpCrosshair
        local inner = r 
        local outer = 5
        surface.DrawRect(x  - inner - outer, y - 1,outer,2)
        surface.DrawRect(x  + inner , y - 1,outer,2)

        surface.DrawRect(x -1 , y- inner - outer,2,outer)
        surface.DrawRect(x -1 , y + inner,2,outer)

    end

    if (self:GetAiming()) then return true end
    if (not self.CrosshairInfo) then return true end
    local info = self.CrosshairInfo
    local w, h = info.width, info.height

    if (r) then
        w, h = r, r
    end

    local mat = Material(info.file)
    local tw, th = mat:Width(), mat:Height()
    local uvx, uvy = info.x / tw, info.y / th
    local uvw, uvh = info.width / tw, info.height / th
    local w, h = info.width, info.height
    x = x - w / 2
    y = y - w / 2
    surface.SetMaterial(mat)
    surface.SetDrawColor(clr)
    surface.DrawTexturedRectUV(x, y, w, h, uvx, uvy, uvw, uvh)

    return true
end


----------------------------------------- 



//don't do anything after this or it'll probably break