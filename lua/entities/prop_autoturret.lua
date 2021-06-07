-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

function IsChairEntity()
return false
end

AddCSLuaFile()
DEFINE_BASECLASS("prop_trash")
ENT.Spawnable = true 
ENT.PrintName = "AutoTurret"
ENT.Category = "Special Trash"
ENT.RenderGroup = RENDERGROUP_BOTH
function ENT:Initialize()
    if(SERVER)then
    self:SetModel("models/airboatgun.mdl")
    local box = Vector(50,10,10)
    self:PhysicsInitBox(-box/2,box/2) --this model doesn't have a collision model so you should probably let it slide this time.
    self:GetPhysicsObject():SetMaterial("weapon")
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetAmmo(0)
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool",0,"Taped")
self:NetworkVar("Int",0,"Ammo")
end

function ENT:GetMaxAmmo()
    return 800
end

function ENT:AddAmmo(amount)
    self:SetAmmo(math.Clamp(self:GetAmmo() + amount,0,self:GetMaxAmmo()))
end

function ENT:HasAmmo()
    return self:GetAmmo() > 0
end
function ENT:IsUnTaped()
    return !self:IsTaped()

end
function ENT:IsTaped()
    return self:GetTaped()

end

function ENT:CanShoot()
    if(!self:HasAmmo())then return false end
    if(self:IsUnTaped())then return false end
    return true
end

function ENT:GetTrace()
local tr = {}
tr.start = self:GetPos()
tr.endpos = tr.start + self:GetForward()*1000
tr.filter = self
local trace = util.TraceLine(tr)
return trace
end

local laser_material
local beam_material

if (CLIENT) then
    beam_material = CreateMaterial("autoturret_beam", "UnlitGeneric", {
        ["$basetexture"] = "sprites/light_glow02",
        ["$model"] = 1,
        ["$additive"] = 1,
        ["$translucent"] = 1,
        ["$color2"] = Vector(4, 4, 4),
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1
    })

    laser_material = CreateMaterial("autoturret_shine", "UnlitGeneric", {
        ["$basetexture"] = "sprites/physgun_glow",
        ["$model"] = 1,
        ["$additive"] = 1,
        ["$translucent"] = 1,
        ["$color2"] = Vector(4, 4, 4),
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1
    })
end


function ENT:Draw()
    self:DrawModel()



end

function ENT:DrawTranslucent()

    local trace = self:GetTrace()
    render.SetMaterial(beam_material)
    --render.DrawBeam(trace.StartPos, trace.HitPos, 4, 0.5, Lerp(trace.Fraction,0.5,0.5), Color(255,0,0,255))
    --render.DrawBeam(trace.StartPos, trace.HitPos, 2, 0.5, Lerp(trace.Fraction,0.5,0.5), Color(255,255,255,255))
    if(trace.Hit)then
        local viewnormal = (EyePos()-trace.HitPos ):GetNormalized()
        render.SetMaterial(laser_material)
        render.DrawQuadEasy(trace.HitPos + viewnormal*16, viewnormal, 16, 16, Color(255,0,0,255), math.Rand(0, 360))
        render.DrawQuadEasy(trace.HitPos + viewnormal*8, viewnormal, 8, 8, Color(255,255,255,255), math.Rand(0, 360))
        render.DrawQuadEasy(trace.HitPos + trace.HitNormal*0.1, trace.HitNormal, 16, 16, Color(255,0,0,255), math.Rand(0, 360))
        render.DrawQuadEasy(trace.HitPos + trace.HitNormal*0.1, trace.HitNormal, 8, 8, Color(255,255,255,255), math.Rand(0, 360))
        
    end
end

function ENT:Think()
    if(SERVER)then
        self:SetTaped(!self:GetPhysicsObject():IsMotionEnabled())
    local trace = self:GetTrace()
    if(trace.Hit and trace.Entity:Health() > 0)then

    if(self:HasAmmo())then

        self:AddAmmo(-1)
        local bullet = {}
        bullet.Attacker = self
        bullet.Inflictor = self
        bullet.Damage = 35
        bullet.Force = 100
        bullet.Dir = trace.Normal
        bullet.Src = trace.StartPos
        bullet.TracerName = "Tracer"
        self:FireBullets( bullet )
        self:EmitSound("Weapon_AR2.Single")
        self:MuzzleFlash()
    else
        self:EmitSound("Weapon_AR2.Empty")
    end

    self:NextThink(CurTime() + 0.2)
    return true


    end
    self:NextThink(CurTime() + 0.1)

    return true
end
if(CLIENT)then
    local mins,maxs = self:GetPos(), self:GetPos()
   
    local refpos = self:GetTrace().HitPos

    mins.x = math.min(mins.x,refpos.x)
    mins.y = math.min(mins.y,refpos.y)
    mins.z = math.min(mins.z,refpos.z)
    maxs.x = math.max(maxs.x,refpos.x)
    maxs.y = math.max(maxs.y,refpos.y)
    maxs.z = math.max(maxs.z,refpos.z)

    mins = mins - Vector(1,1,1)*16
    maxs = maxs + Vector(1,1,1)*16

    self:SetRenderBoundsWS(mins,maxs)

end
end

function ENT:Touch(ent)
    if(ent:GetClass() == "autoturret_ammo" and self:GetAmmo() <= self:GetMaxAmmo() - 50)then
        self:EmitSound("Weapon_AR2.Reload_Rotate")
        self:AddAmmo(50)
        ent:Remove()
    end
end

if(CLIENT)then
    language.Add("prop_autoturret","Auto Turret")
end

