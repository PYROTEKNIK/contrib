-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Boost Pad"
ENT.Spawnable = true


ENT.ForceSettings = {
[1] = {800,Color(8,255,8)},
[2] = {1200,Color(255,180,8)},
[3] = {1600,Color(255,6,0)},

}

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel("models/pyroteknik/booster.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    phys:Wake() 
    self.IgnoreEnts = {}
    self.ForceSetting = 0
    self:ChangePower()
end

function ENT:ChangePower()

    self.ForceSetting = (self.ForceSetting or 1) + 1
    if(self.ForceSetting > #self.ForceSettings)then
        self.ForceSetting = 1
    end
    if(self.ForceSettings[self.ForceSetting])then
        local tab = self.ForceSettings[self.ForceSetting]
        self:SetColor(tab[2])
    end

end

function ENT:Think()
    if(SERVER)then
        local frozen = !self:GetPhysicsObject():IsMotionEnabled()
        local tab = self.ForceSettings[self.ForceSetting]
        local clr = tab[2]
        self:SetColor(frozen and clr or Color(8,8,8))
    end
end

function ENT:GetPower()
    local tab = self.ForceSettings[self.ForceSetting]
    return tab[1]
end


function ENT:Use(activator, caller)
    local frozen = !self:GetPhysicsObject():IsMotionEnabled()
    if(frozen)then
        self:ChangePower()
    end
    self:EmitSound("physics/metal/metal_solid_impact_soft"..math.random(1,3)..".wav", 60,50)
end

function ENT:PhysicsCollide(data, phys)
end

function ENT:Touch(ent)
    local frozen = !self:GetPhysicsObject():IsMotionEnabled()
    if(!frozen)then return end
    --if(!ent:IsPlayer())then return end

    local pos = WorldToLocal(ent:GetPos(),Angle(),self:GetPos(),self:GetAngles())
    local pos2 = WorldToLocal(ent:WorldSpaceCenter() ,Angle(),self:GetPos(),self:GetAngles())
    
    if((pos2*Vector(1,1,0)):Length() > 40)then return end
    if(pos.z < 1)then return end

    self.IgnoreEnts = self.IgnoreEnts or {}
    local ignored = self.IgnoreEnts[ent] and self.IgnoreEnts[ent] > CurTime()
    
    if(!ignored)then
        local dir = (self:GetUp()*1 + self:GetForward()):GetNormalized()
        local shootvel = dir*self:GetPower()
        if(ent:OnGround())then 
            ent:SetPos(ent:GetPos() + Vector(0,0,8))
            shootvel.z = math.max(shootvel.z,200)
         end
         if(ent:IsPlayer())then shootvel = shootvel - ent:GetVelocity() end
        if(!ent:IsPlayer() and IsValid(ent:GetPhysicsObject()))then ent = ent:GetPhysicsObject() end
        
        ent:SetVelocity(shootvel)
        
        self:EmitSound("physics/metal/metal_solid_impact_soft"..math.random(1,3)..".wav", 60,50)
    end

    self.IgnoreEnts[ent] = CurTime() + 0.3

end 