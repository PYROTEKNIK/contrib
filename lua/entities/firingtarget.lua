-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = true
ENT.PrintName = "Firing Range Target"
DEFINE_BASECLASS("base_gmodentity")
ENT.Model = Model("models/pyroteknik/firingtarget.mdl")
ENT.DefaultHealth = 15
local forwardangle = Angle(0, 0, 0)
local rail1 = Vector(-1904, 89, -320)
--{rail id, localspace start offset from middle rail, function}
local NOMOVE = Vector(0, 0, 69)

local cmds = {
    GO = function(ent,arg)
        ent:SetMoveTarget(arg)
    end,
    WAIT = function(ent,arg)
        ent:SetPauseEnd(CurTime() + arg)

        return true
    end,
    SPEED = function(ent,arg)
        ent:SetMoveSpeed(arg)

        return true
    end,
    DIE = function(ent)
        ent:Expire() 

        return true
    end,
    RESET = function(ent)
        ent:Reset()

        return true
    end,
    RESTART = function(ent)
        ent.BehaviorQueue = table.Copy(ent.NextBehaviorQueue or {})
    end
}
 
if (SERVER) then
    local testseq = {} 

    for i = 1, 5 do
        testseq[i] = {
            i, Vector(-200, 0, 0), function(target)
                target.BehaviorQueue = {"SPEED", 300, "WAIT", i,"RESET", 1, "GO", Vector(200, 0, 0), "WAIT", 0.2,"DIE",0, "WAIT", 2,"RESET", 1, "GO", Vector(-200, 0, 0),"WAIT", 0.2,"DIE",0, "WAIT", 5-i, "RESTART"}
                target.NextBehaviorQueue = table.Copy(target.BehaviorQueue)
            end
        }
    end
 
    local testseq2 = {} 
    for x=-4,4 do
    for i = 1, 5 do
        table.insert(testseq2,{
            i, Vector(x*32, 0, 0), function(target)
                target.BehaviorQueue = {"RESET",1,"WAIT",5,"RESTART"}
                target.NextBehaviorQueue = table.Copy(target.BehaviorQueue)
            end
        })
    end
end


    function TargetSequence(sequence)
        for k, v in pairs(ents.FindByClass("firingtarget")) do
            if (v.SpawnedByRange) then
                v:Remove()
            end
        end

        for ind, target in pairs(sequence) do
            local railid = target[1]
            local railpos = rail1 + Vector(0, 160, 0) * (railid - 1)
            local localoffset = target[2]
            local func = target[3]
            local ent = ents.Create("firingtarget")
            ent:SetMoveTarget(NOMOVE)
            local pos, ang = LocalToWorld(localoffset, Angle(0, -90, 0), railpos, forwardangle)
            ent:SetPos(pos)
            ent:SetAngles(ang)
            func(ent)
            ent:Spawn()
            ent:SetHomePosition(railpos)
            ent.SpawnedByRange = true
        end
    end

    TargetSequence(testseq)
end

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:DrawShadow(false)
    if SERVER then
    self:Reset()
    self:SetHealth(self.DefaultHealth)
    self:SetHitboxSet("default")
    self:SetLagCompensated(true)
  
        self:PrecacheGibs()
        self:SetUseType(SIMPLE_USE)
    end

    local tr = {}
    tr.start = self:GetPos() + Vector(0, 0, 64)
    tr.endpos = tr.start + Vector(0, 0, -128)

    tr.filter = {self}

    local trace = util.TraceLine(tr)
    self:SetPos(trace.HitPos)
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:EnableMotion(false)
    end
end

function ENT:MoveTowardsTarget(timestep)
    local targetpos = LocalToWorld(self:GetMoveTarget(), Angle(), self:GetHomePosition(), forwardangle)
    local ofs = (targetpos - self:GetPos())
    local speed = self:GetMoveSpeed()
    local len = math.Clamp(ofs:Length()/(speed*timestep),0,1)

    local dir = (ofs):GetNormalized() * len

    if (len < 1) then
        self:SetPos(targetpos)
        self:OnReachTarget(targetpos)
        self:SetMoveTarget(NOMOVE)
    end

    self:SetPos(self:GetPos() + dir * self:GetMoveSpeed() * timestep)
end

function ENT:OnReachTarget(pos)
    if (SERVER) then
        --self:EmitSound("smallbell.ogg", 140, 100, 1, CHAN_AUTO)
    end
end

function ENT:HasQueue()
    return self.BehaviorQueue and self.BehaviorQueue[1] ~= nil
end
 
function ENT:ConsumeQueueNext()
    if (self.BehaviorQueue and self.BehaviorQueue[1]) then
        local value = table.remove(self.BehaviorQueue, 1)
        return value
    end
end

function ENT:Busy() 
    --if moving
    if (self:GetMoveTarget() ~= NOMOVE and self:GetPauseEnd() <= CurTime()) then return true end
    --if waiting
    if (self:GetPauseEnd() > CurTime()) then return true end

    return false
end

function ENT:ProcessQueue()
    if (not self:HasQueue()) then  return end
    local cmd = self:ConsumeQueueNext()

    if (cmds[cmd]) then
        local arg = self:ConsumeQueueNext()
        cmds[cmd](self,arg) 
    end
end

function ENT:Think()
    local timestep = FrameTime()

    if (SERVER) then
        if (not self:Busy() and self:HasQueue()) then
            self:ProcessQueue()
        end
    end
    if (CurTime() > self:GetPauseEnd() and self:GetMoveTarget() ~= NOMOVE) then
        self:MoveTowardsTarget(timestep)
    end

    self:NextThink(CurTime()+timestep)

    if (CLIENT) then
        self:SetNextClientThink(CurTime()+timestep)
    end

    return true
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Standing")
    self:NetworkVar("Int", 0, "MoveSpeed")
    self:NetworkVar("Vector", 0, "MoveTarget")
    self:NetworkVar("Vector", 1, "HomePosition")
    self:NetworkVar("Float", 0, "PauseEnd")

    if (SERVER) then
        self:NetworkVarNotify("Standing", self.OnVarChanged)
    end
end

function ENT:OnVarChanged(name, old, new)
    if (name == "Standing") then
        self:SetSolid(new == true and SOLID_VPHYSICS or SOLID_NONE)
    end
end

function ENT:Reset()
    if (CLIENT) then return end
    self:SetHealth(self.DefaultHealth)
    self:SetStanding(true)
    self:RemoveAllDecals()
end

function ENT:Expire()
    if (CLIENT) then return end
    self:SetStanding(false)
    self:NextThink(CurTime() + 2)
end

function ENT:KnockDown()
    if (CLIENT) then return end
    self:SetStanding(false)
    self:EmitSound("smallbell.ogg", 140, 100, 1, CHAN_AUTO)
end

function ENT:Draw()
    self.LastHealth = self.LastHealth or self:Health()

    if (self:Health() ~= self.LastHealth) then
        self.UpLerp = self.UpLerp + math.Rand(0.04, 0.1)
        self.LastHealth = self:Health()
    end

    self.UpLerp = math.Approach(self.UpLerp or 0, self:GetStanding() and 0 or 1, FrameTime() * 8)
    self:ManipulateBoneAngles(0, Angle(-88 * self.UpLerp, 0, 0))
    self:DrawModel()
end

function ENT:Use(act, cal)
    self:Reset()
end

function ENT:OnRemove()
    if (CLIENT) then
        self:GibBreakClient(Vector())
    end
end

function ENT:HitgroupFromDamage(dmg)
    local raystart, raydelta = dmg:GetDamagePosition(), dmg:GetDamageForce()
    local box
    local boxfrac = 1

    for i = 0, self:GetHitBoxCount(0) - 1 do
        local pos, ang = self:GetBonePosition(0)
        local mins, maxs = self:GetHitBoxBounds(i, 0)
        local hit, normal, frac = util.IntersectRayWithOBB(raystart, raystart + dmg:GetDamageForce(), pos, ang, mins, maxs)

        if (hit and frac < boxfrac) then
            box = i
            boxfrac = frac
        end
    end

    if (box) then
        local pos, ang = self:GetBonePosition(0)
        local mins, maxs = self:GetHitBoxBounds(box, 0)
        debugoverlay.BoxAngles(pos, mins, maxs, ang, 2, Color(0, 0, 255, 32))

        return self:GetHitBoxHitGroup(box, 0)
    end
end

function ENT:OnTakeDamage(dmg)
    local hitgroup = self:HitgroupFromDamage(dmg)

    if (hitgroup == HITGROUP_HEAD) then
        dmg:ScaleDamage(2)
    end

    if (hitgroup == HITGROUP_CHEST) then
        dmg:ScaleDamage(1.4)
    end
    self:EmitSound("smallbell.ogg", 140, 100, 1, CHAN_AUTO)
    self:SetHealth(self:Health() - dmg:GetDamage())

    if (self:Health() <= 0) then
        self:KnockDown()
    end
end