AddCSLuaFile()

SWEP.Spawnable = false
 
SWEP.Category = "Counter-Strike:Source"
SWEP.Sounds = {}

SWEP.Projectile = "npc_grenade_frag"

function SWEP:CanPrimaryAttack()
    return self:Ammo1() > 0
end

function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
end


function SWEP:SetupDataTables() 
    self:NetworkVar("Float",0,"ThrowReady")
    self:NetworkVar("Float",1,"ThrowTime")

end

function SWEP:Throw()
    if(SERVER)then
        local proj = ents.Create(self.Projectile)
            proj:SetPos(self:GetOwner():GetShootPos())
            proj:SetOwner(self:GetOwner())
            proj:Spawn()
            proj:Fire("SetTimer",4)
            proj:GetPhysicsObject():SetVelocity(self:GetOwner():GetAimVector()*1500)
        end
    self:TakePrimaryAmmo(1)
end

function SWEP:PrimaryAttack()
    -- Make sure we can shoot first
    if (not self:CanPrimaryAttack()) then return end


    if(self:GetThrowReady() == 0)then
        self:SendWeaponAnim(ACT_VM_PULLPIN)
        self:SetThrowReady(CurTime() + 1)
        self:SetNextPrimaryFire(CurTime() + 2)
        return 
    end 
end

function SWEP:Equip(ply)
ply:GiveAmmo(1,self.Primary.Ammo)
end
function SWEP:EquipAmmo(ply)
    ply:GiveAmmo(1,self.Primary.Ammo)
end

function SWEP:Think()
    if(self:GetThrowReady() > 0)then

        local press = self:GetOwner():KeyDown(IN_ATTACK)
        if(!press and CurTime() >= self:GetThrowReady())then
            
            self:SetThrowReady(0)
            self:SendWeaponAnim(ACT_VM_THROW)
            self:SetNextPrimaryFire(CurTime() + 2)
            self:SetThrowTime(CurTime() + 2) 
        end
    end
    if(self:GetThrowTime() > 0 and self:GetThrowTime() >= CurTime())then
        self:Throw()
        self:SetThrowTime(0) 
        self.EmptyHand = true
    end
    if(self.EmptyHand and CurTime() >= self:GetNextPrimaryFire() - 0.5)then
        self:SendWeaponAnim(ACT_VM_DRAW)
        self.EmptyHand = false
    end
    
end

function SWEP:SecondaryAttack()

end

function SWEP:TranslateFOV(fov)

end

function SWEP:DrawHUDBackground()

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
