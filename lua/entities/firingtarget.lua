-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = true
ENT.PrintName = "Firing Range Target"
DEFINE_BASECLASS("base_gmodentity")
ENT.Model = Model("models/pyroteknik/firingtarget.mdl")
ENT.DefaultHealth = 30
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
        ent:SetTargetHealth(0) 

        return true
    end,
    RESET = function(ent)
        ent:SetTargetHealth(ent.DefaultHealth)

        return true
    end,
    RESTART = function(ent)
        ent.BehaviorQueue = table.Copy(ent.NextBehaviorQueue or {})
    end
}
  
if (SERVER) then
    local testseq = {} 
    local testseq2 = {} 
    local testseq3 = {} 

    for i = 1, 5 do
        testseq[i] = {
            i, Vector(-200, 0, 0), function(target)
                target.BehaviorQueue = {"SPEED", 200, "WAIT", i,"RESET", 1, "GO", Vector(200, 0, 0), "WAIT", 0.2,"DIE",0, "WAIT", 2,"RESET", 1, "GO", Vector(-200, 0, 0),"WAIT", 0.2,"DIE",0, "WAIT", 5-i, "RESTART"}
                target.NextBehaviorQueue = table.Copy(target.BehaviorQueue)
            end
        }
    end
 
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
            
            local pos, ang = LocalToWorld(localoffset, Angle(0, -90, 0), railpos, forwardangle)
            ent:SetPos(pos)
            ent:SetAngles(ang)
            func(ent)
            ent:Spawn()
            ent:SetMoveTarget(NOMOVE) 
            ent:SetHomePosition(railpos)
            ent.SpawnedByRange = true 
        end
    end 
    concommand.Add("firing_setsequence",function(ply,cmd,args)
    
        local num = tonumber(args[1])
    
        TargetSequence((num == 1 and testseq) or (num == 2 and testseq2) or (num == 3 and testseq3))
    end)
end



function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:DrawShadow(false)
    if(CLIENT)then
        self:SetRenderBounds( Vector(-32,-32,0), Vector(32,32,90), Vector())
    end
    if SERVER then
    self:SetTargetHealth(self.DefaultHealth) 
    self:SetHitboxSet("default")
    self:SetLagCompensated(true)
   
        self:PrecacheGibs()
        self:SetUseType(SIMPLE_USE)
    end

    local tr = {}
    tr.start = self:GetPos() + Vector(0, 0, 64)
    tr.endpos = tr.start + Vector(0, 0, -128)

    tr.filter = ents.FindByClass("firingtarget")

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

    self:NetworkVar("Int", 0, "MoveSpeed")
    self:NetworkVar("Vector", 0, "MoveTarget")
    self:NetworkVar("Vector", 1, "HomePosition")
    self:NetworkVar("Float", 0, "PauseEnd")
    self:NetworkVar("Int",1,"TargetHealth")
    if (SERVER) then
        self:NetworkVarNotify("TargetHealth", self.OnVarChanged)
    end
end

function ENT:OnVarChanged(name, old, new)
    if(name == "TargetHealth")then
        local solid = new > 0
        self:SetSolid(solid and SOLID_VPHYSICS or SOLID_NONE)
    end
end


function ENT:Expire()
    self:SetTargetHealth(0)
end

function ENT:KnockDown()
end

function ENT:GetStanding()
    return self:GetTargetHealth() > 0
end

function ENT:Draw()
    self.UpLerp = math.Approach(self.UpLerp or 0, self:GetStanding() and 0 or 1, FrameTime() * 8)
    self:ManipulateBoneAngles(0, Angle(-88 * self.UpLerp, 0, 0))
    self:DrawModel()
end

function ENT:OnRemove()
    if (CLIENT) then
        --self:GibBreakClient(Vector())
    end
end

function ENT:HitBullet(dmg,tr)
    local hitgroup = tr.HitGroup 
    local hitbox = tr.HitBox
    if (hitbox) then
        local pos, ang = self:GetBonePosition(0)
        local mins, maxs = self:GetHitBoxBounds(hitbox, 0)
        debugoverlay.BoxAngles(pos, mins, maxs, ang, 0.5, SERVER and Color(0, 0, 255, 32) or CLIENT and Color(255,235,64,16))
    end
    local score = 10
    
    if (hitgroup == HITGROUP_HEAD) then
        dmg:ScaleDamage(2)
        score = 50
    end

    if (hitgroup == HITGROUP_CHEST) then
        dmg:ScaleDamage(1.4)
        score = 100
    end
    if(CLIENT)then 
        self:EmitSound("smallbell.ogg", 140, 100, 1, CHAN_AUTO) 
    end
    local ply = dmg:GetAttacker()
    ply.FRangeScore = (ply.FRangeScore or 0) + score
    print(ply.FRangeScore,"(+"..score..")")

    self:SetTargetHealth(self:GetTargetHealth() - dmg:GetDamage())
    local solid = self:GetTargetHealth() > 0
    self:SetSolid(solid and SOLID_VPHYSICS or SOLID_NONE)
    
end

local ftarget_handlecallback = function(attacker,tr,dmg)
    if(ftarget_origcallback)then ftarget_origcallback(attacker,tr,dmg) end
       local ent = tr.Entity
        if(IsValid(ent) and ent:GetClass() == "firingtarget")then
            ent:HitBullet(dmg,tr)
        end 
end
hook.Add("EntityFireBullets","FiringRange",function(ent,data)
    ftarget_origcallback = data.Callback
    if(IsFirstTimePredicted() or SERVER)then
    data.Callback = ftarget_handlecallback
    end
    ftarget_origcallback = nil
    return true
end)
