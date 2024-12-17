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
        self:SetModel("models/tsbb/fishes/thresher_shark.mdl")
        local mins,maxs = Vector(-32,-9,2),Vector(32,9,14)
        self:SetModel("models/tsbb/fishes/cod.mdl")
        local mins,maxs = Vector(-32,-4,-2),Vector(32,4,4)


        self:PhysicsInit(SOLID_VPHYSICS)
        local thick = 4
        


        self:PhysicsInitBox( mins,maxs, "metal" )
        debugoverlay.BoxAngles(self:GetPos(),mins,maxs,self:GetAngles(),5,Color(0,255,0,128))
        self:SetUseType(SIMPLE_USE)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(4)
            phys:SetDamping(0.5,4)
            phys:SetBuoyancyRatio(0.1)
            
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


    local swim = self:InWater(true)
    phys:EnableGravity(!swim or self:GetInput().z <= 0)


    if self:InWater() then 

            phys:Wake()
            local inp = self:GetInput()
        local tar = self:GetInput():Angle()
        local vel = self:GetForward()*Vector(1,1,3)*10000*inp:Length()
        self.LerpAngle = self.LerpAngle or phys:GetAngles()

        self.LerpAngle = LerpAngle(0.5,self.LerpAngle,tar)
        debugoverlay.Line(self:GetPos(),self:GetPos() + self:GetInput():GetNormalized()*32,0,Color(0,0,255),true)

        debugoverlay.Cross(self:GetPos() + self:GetInput():GetNormalized()*32,4,0,Color(0,0,255),true)

        
        phys:ApplyForceCenter(vel*delta)
        local _,lc = WorldToLocal(Vector(),self.LerpAngle,Vector(),phys:GetAngles())
        phys:AddAngleVelocity(Vector(lc.roll*25,lc.pitch*45,lc.yaw*25))
        phys:AddAngleVelocity(-phys:GetAngleVelocity()*0.7)

        


        return vel,self.LerpAngle,SIM_GLOBAL_ACCELERATION
    end
end


function ENT:InWater(g)
    local min, max = self:WorldSpaceAABB()
    local pos = self:WorldSpaceCenter()
    pos.z = Lerp(0.9,pos.z,g and max.z + 8 or min.z)

    return bit.band( util.PointContents( pos  ), CONTENTS_WATER ) == CONTENTS_WATER
end

function ENT:TestWater(at)
    local min, max = self:WorldSpaceAABB()
    local pos = at or self:WorldSpaceCenter()

    local watermin = min.z
    local watermax = max.z

    local tr = {}
    tr.start = pos
    tr.endpos = tr.start + Vector(0,0,16000)
    tr.filter = {self}
    local begtrace = util.TraceLine(tr) --trace up to ceiling
    --debugoverlay.Line(tr.start,begtrace.HitPos,0,Color(255,255,0),true)
    --debugoverlay.Cross(begtrace.HitPos,32,0,Color(255,255,0),true)
    debugoverlay.Cross(begtrace.HitPos,8,0,Color(0,255,255),true)


    local wtr = {}
    wtr.start = begtrace.Hit and begtrace.HitPos or tr.endpos
    wtr.endpos = wtr.start + Vector(0,0,-16000)
    wtr.filter = {self}
    wtr.mask = bit.bor( CONTENTS_SOLID , CONTENTS_GRATE , CONTENTS_WATER)
    local wtrace = util.TraceLine(wtr) --trace down again

    debugoverlay.Line(wtr.start,wtrace.HitPos,0,Color(0,255,255),true)
    debugoverlay.Cross(wtrace.HitPos,8,0,Color(0,255,255),true)


    if wtrace.Hit then 
        watermax = wtrace.HitPos.z
        if bit.band( wtrace.Contents, CONTENTS_WATER ) == CONTENTS_WATER then
            local tr = {}
            tr.start = wtrace.HitPos
            tr.endpos = tr.start + Vector(0,0,-1000)
            tr.filter = {self}
            tr.mask = bit.bor( CONTENTS_SOLID , CONTENTS_GRATE)
            local gtrace = util.TraceLine(tr) --trace from water surface down
            
            if gtrace.Hit then 
                watermin = math.min(watermax,gtrace.HitPos.z)
            end
            local b = pos*1
            b.z = 0
            debugoverlay.Box(b,Vector(-16,-16,watermin),Vector(16,16,watermax),0,Color(0,0,255,32))
            b.z = Lerp(0.5,watermin,watermax)
            debugoverlay.Cross(b,16,0,Color(255,128,0,32),true)
            b.z = watermin
            debugoverlay.Cross(b,32,0,Color(0,255,255),true)


            return watermin,watermax
        else
            return nil
        end
    end

    //print("water",watermin,watermax)
    return
end



function ENT:GetShadowCastDirection(type)
    return Vector(0,0,-1)
end

function ENT:SetupDataTables()
    self:NetworkVar("Vector",0,"Input")
    self:NetworkVar("Entity",0,"Target")
    self:NetworkVar("Bool",0,"Caught")
end

function ENT:Think()
    if SERVER then 
        self:SetCaught(false)
        local watermin,watermax = self:TestWater()
        local watermid = watermin and Lerp(0.5,watermin,watermax)

        local mp = self:GetPos()
        mp.z = watermid or mp.z
        debugoverlay.Cross(mp,4,0,Color(255,0,255),true)

        local phys = self:GetPhysicsObject()
        phys:Wake()
        local inwater = self:InWater()

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

        local cdepth = math.abs(watermin or 0 ,watermax or 0)

        local function dt()


            for i=0,50 do
                local nx = (VectorRand()*Vector(1,1,0)):GetNormalized()
                local tr = {}
                tr.start = self:GetPos() 
                tr.endpos = self:GetPos() + nx*300
                tr.filter = self

                local trace = util.TraceLine(tr)
                local samp = trace.HitPos 
                if  bit.band( util.PointContents( samp  ), CONTENTS_WATER ) == CONTENTS_WATER then 
                    local watermin,watermax = self:TestWater(samp)
                    local depth = math.abs(watermin,watermax)
                    local ok = depth >= cdepth*0.8 or i==50

                    debugoverlay.Line(tr.start,tr.endpos,1,ok and Color(0,255,0) or Color(255,0,0),true)


                    if ok then
                        return nx
                    end

                end
            end

        end




        if self.BiteLure then
            
            local lure = self.BiteLure
            
            self.PanicVector = (math.random(1,100) == 1 and  dt()) or self.PanicVector or Vector()

            

            if watermid and self:GetPos().z > watermid then 
                self.PanicVector.z = -0.44
            end    

        
            local newvec = self.PanicVector
            local awdir = (-lure:GetPole():GetPullVector()*Vector(1,1,0)):GetNormalized()

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


            if IsValid(target) and watermax then
                local tpos = target:WorldSpaceCenter()
                local pos = self:GetPos()
                local gopos = tpos*1
                

                local ratio = math.Clamp(math.Remap(tpos:Distance(pos),1000,100,0,1),0,1)
                local ratio2 = math.Clamp(math.Remap(tpos:Distance(pos),100,0,0,1),0,1)

                local a = watermid or gopos.z --halfway to max water depth
                local b = math.min(watermax - 32,tpos.z) -- just under the surface
                local c = tpos.z --target height

                local height = Lerp(ratio,a,b)
                height = Lerp(ratio2,b,c)

                gopos.z = height

                local new = gopos - pos



                self:SetInput(new:GetNormalized()*0.1)
            else

                local dir = (self:GetForward()*Vector(1,1,0)):GetNormalized()
                local wdist = 300
                local tpos = self:GetPos() + dir*wdist


                local dr = self:GetForward()
                dr = dr + VectorRand()*math.Rand(0,0.1)
                dr:Normalize()

                local tr = {}
                tr.start = self:GetPos()
                tr.endpos = tr.start + dr*wdist
                tr.filter = {self}
                local trace = util.TraceLine(tr) --trace up to ceiling
                debugoverlay.Line(tr.start,trace.HitPos,0.25,Color(255,128,0),true)    
            
                if trace.Hit then 
                    local gn = (trace.HitNormal*Vector(1,1,0)):GetNormalized()
                    tpos = trace.HitPos + gn*wdist*(1-trace.Fraction) 
                    debugoverlay.Line(trace.HitPos,tpos,0.25,Color(255,128,0),true)   
                end

                tpos.z = watermid or tpos.z 
                debugoverlay.Cross(tpos,16,0.25,Color(255,128,0),true)    
            


                
                local pos = self:GetPos()

                local new = tpos - pos



                self:SetInput(new:GetNormalized()*0.1)

            end
        end

        self:NextThink(CurTime())
        return true
    end
end

function ENT:GetHook()
    local last = self.LastHookTouched
    if last and IsValid(last) then
        if last:GetFish() == self then return last end
    end
end

function ENT:PhysicsCollide( data, phys )
    if self:GetCaught() then return end
    if data.HitEntity == self:GetTarget()then
        local ent = data.HitEntity
        if !IsValid(self:GetHook()) and !IsValid(ent:GetFish()) then
            ent:Hook(self,self:LookupBone("Jaw"))
            self.BiteLure = ent
        end
    end
end

function ENT:Draw(flags)
    self:DrawModel(flags)
end

function ENT:Use()


end

