AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = true
ENT.Category = "PYROTEKNIK"
ENT.PrintName = "Fishable"
ENT.HullMin = Vector(-4, -4, 0)
ENT.HullMax = Vector(4, 4, 4)
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup  = RENDERGROUP_BOTH
local vector_one = Vector(1, 1, 1)

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/tsbb/fishes/cod.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        local mins,maxs = Vector(-32,-4,-4),Vector(32,4,4)

        self:PhysicsInitBox( mins,maxs, "metal" )
        debugoverlay.BoxAngles(self:GetPos(),mins,maxs,self:GetAngles(),5,Color(0,255,0,128))

        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(20)
            phys:SetDamping(0.1,32)
        end

        self:StartMotionController()

    end
    for i=0,self:GetBoneCount()-1 do
        print(self:GetBoneName(i))
    end
    self:DrawShadow(false) 
    
    self.LastWaterState = false
end

function ENT:PhysicsSimulate(phys,delta)
    if self:InWater() then 

            phys:Wake()
            local inp = self:GetInput()
        local tar = self:GetInput():Angle()
        local vel = self:GetForward()*15000*inp:Length()
        self.LerpAngle = self.LerpAngle or phys:GetAngles()

        self.LerpAngle = LerpAngle(0.5,self.LerpAngle,tar)
        debugoverlay.Line(self:GetPos(),self:GetPos() + self:GetInput():GetNormalized()*32,0,Color(0,0,255),true)

        debugoverlay.Cross(self:GetPos() + self:GetInput():GetNormalized()*32,4,0,Color(0,0,255),true)


        phys:ApplyForceCenter(vel*delta)
        local _,lc = WorldToLocal(Vector(),self.LerpAngle,Vector(),phys:GetAngles())
        phys:AddAngleVelocity(Vector(lc.roll*5,lc.pitch*25,lc.yaw*25))
        phys:AddAngleVelocity(-phys:GetAngleVelocity()*0.2)
        
        return vel,self.LerpAngle,SIM_GLOBAL_ACCELERATION
    end
end


function ENT:InWater()
    local min, max = self:WorldSpaceAABB()
    local pos = self:WorldSpaceCenter()
    pos.z = Lerp(0.9,pos.z,min.z)

    return bit.band( util.PointContents( pos  ), CONTENTS_WATER ) == CONTENTS_WATER
end

function ENT:GetShadowCastDirection(type)
    return Vector(0,0,-1)
end

function ENT:SetupDataTables()
    self:NetworkVar("Vector",0,"Input")
    self:NetworkVar("Entity",0,"Target")
end

function ENT:Think()
    if SERVER then 
        local phys = self:GetPhysicsObject()
        phys:Wake()
        local inwater = self:InWater()
        phys:EnableGravity(true)
        

        if self.LastWaterState != inwater then

            if math.abs((self.LastSplash or 0) - CurTime()) > 0.25 then 
                local effectdata = EffectData()
                effectdata:SetOrigin( self:GetPos() )
                util.Effect( "watersplash", effectdata )
                self.LastSplash = CurTime()
            end
            self.LastWaterState = inwater
            
        end


        local t = NULL
        for k,v in pairs(ents.FindByClass("fishing_bobber"))do
            if IsValid(v) then
                t = v
                break
            end            
        end

        if self:GetTarget() != t then
            self:SetTarget(t)
        end


        local target = self:GetTarget()
        local speed = 25
        if !IsValid(self.BiteLure) then self.BiteLure = nil end


        if self.BiteLure then
            
            local lure = self.BiteLure
            
            self.PanicVector = self.PanicVector or (VectorRand()*Vector(1,1,0)):GetNormalized()
            if math.random(1,100) == 1 then
                self.PanicVector = (VectorRand()*Vector(1,1,0)):GetNormalized()
            end
            
            local newvec = self.PanicVector
            local awdir = (-lure:GetPole():GetPullVector()*Vector(1,1,0)):GetNormalized()
                newvec = newvec + awdir*0.1
                newvec.z = -0.2

            speed = 125
            self:SetInput(newvec)
            if self:InWater() then
                local pos = self:GetPos()
                local vec = newvec
                local effectdata = EffectData()
                effectdata:SetOrigin( pos )
                effectdata:SetNormal(-vec*0.1)
                effectdata:SetScale(0.5)
                effectdata:SetMagnitude(5)
                util.Effect( "StriderBlood", effectdata )
            end


        else
            if IsValid(target) then
                local new = target:WorldSpaceCenter() - self:GetPos()
                self:SetInput(new:GetNormalized())
            end
        end

        self:NextThink(CurTime())
        return true
    end
end

function ENT:PhysicsCollide( data, phys )
	if ( data.Speed > 50 ) then self:EmitSound( Sound( "Flashbang.Bounce" ) ) end

    if IsValid(self.BiteConstraint) then
        return 
    end

    if data.HitEntity == self:GetTarget() then
        local target = self:GetTarget()
        
        timer.Simple(0,function()
            target:SetPos(self:GetBonePosition(self:LookupBone("Jaw")))
            target:SetAngles(self:GetAngles())
            self.BiteConstraint = constraint.Weld( self, target, 0, 0, 1000000, true )
            self.BiteLure = target
        end)
    end

end

function ENT:Draw(flags)
    self:DrawModel(flags)
end


