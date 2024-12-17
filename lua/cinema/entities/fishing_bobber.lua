AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = true
ENT.Category = "PYROTEKNIK"
ENT.PrintName = "Fishing Bobber"
ENT.HullMin = Vector(-4, -4, 0)
ENT.HullMax = Vector(4, 4, 4)
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup  = RENDERGROUP_BOTH
local vector_one = Vector(1, 1, 1)

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/pyroteknik/fishing_bobber.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)

        //self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(6)
            phys:SetMaterial("ice")
            phys:SetBuoyancyRatio(1)
           
        end


    end
    self:DrawShadow(false)
    self.LastWaterState = false
end

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Pole")
    self:NetworkVar("Vector",0,"Pull")
    self:NetworkVar("Entity",1,"Fish")
    
end

function ENT:InWater()

    return bit.band( util.PointContents( self:GetPos() + Vector(0,0,-2) ), CONTENTS_WATER ) == CONTENTS_WATER
end

function ENT:Think()
    local inwater = self:InWater()


    if self.LastWaterState != inwater then

        if math.abs((self.LastSplash or 0) - CurTime()) > 0.5 then 
            local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )
            util.Effect( "watersplash", effectdata )
            self.LastSplash = CurTime()
        end
        self.LastWaterState = inwater
        
    end

    if SERVER then 
        local phys = self:GetPhysicsObject()
        phys:SetDamping(inwater and 6 or 2,0.5)
        self:SimulateRope(0.1)
        self:NextThink(CurTime())
        return true
    end

    if CLIENT then 
        local nvel = self:GetVelocity()

        local pos = self:GetPos()
        self.LagValue = self.LagValue or pos
        local dist = self.LagValue:Distance(pos)
        dist = math.max(0,dist-100)

        self.LagValue = self.LagValue + (pos - self.LagValue):GetNormalized()*dist
        self.LagValue = LerpVector(0.005,self.LagValue,pos)
        self.LagVector = self.LagValue-pos

        --debugoverlay.Cross(self.LagValue,16,0,Color(0,0,255),true)

        self.SmoothVel = LerpVector(0.05,self.SmoothVel or nvel,nvel)

        self:SimulateRope(FrameTime())
        local av = self:GetPos()*1
        local bv = self:GetPos()*1


        local min,max = Vector(),Vector()
        local grow = 16
        local pole = self:GetPole()

        if IsValid(pole) then 
        bv = self:GetPole():GetPoleTip()
        end


        min.x = math.min(av.x,bv.x)
        min.y = math.min(av.y,bv.y)
        min.z = math.min(av.z,bv.z)
        max.x = math.max(av.x,bv.x)
        max.y = math.max(av.y,bv.y)
        max.z = math.max(av.z,bv.z)
        
    
        min = min - Vector(1,1,1)*grow
        max = max + Vector(1,1,1)*grow

        --debugoverlay.Box(Vector(),min,max,0,Color(255,0,0,0))


        self:SetRenderBoundsWS(min,max)
        self:SetNextClientThink(CurTime())
        return true
    end


end

function ENT:Draw(flags)

    if !IsValid(self:GetPole()) then return end



    self:DrawModel(flags)
end
hook.Add("PostDrawOpaqueRenderables","FishingBobberDrawStrings",function(dep,sky,sky3)
    for k,v in pairs(ents.FindByClass("fishing_bobber"))do
        v:DrawString()
    end
end)

function ENT:GetHookedEntity()
    local fsh = self:GetFish()
    if IsValid(fsh) then
        if !IsValid(self.HookConstraint) then
            return nil
        end
    end    
    return fsh
end


function ENT:Hook(ent,bone)
    
    local physobj 

    local physbone = ent:TranslateBoneToPhysBone(bone) or 0

    physbone = util.IsValidPhysicsObject( ent, physbone ) and physbone or 0


    if physbone then
        physobj = ent:GetPhysicsObjectNum(physbone)
    else
        bone = 0
        physobj = ent:GetPhysicsObject()
    end
    print(ent,bone,physobj)

    if IsValid(self.HookConstraint) then
        if IsValid(self:GetFish()) then
            print("Fishing bobber tried to hook entity while already hooked!")
            return 
        else
            self.HookConstraint:Remove()
            self.HookConstraint = nil
            self:SetFish(nil)
        end 
    end

    if IsValid(ent) then
        if IsValid( self.HookConstraint) then self.HookConstraint:Remove() end
        if IsValid( ent.HookConstraint) then ent.HookConstraint:Remove() end

        timer.Simple(0,function()
            if ent:GetCaught() then return end
            self:EmitSound( Sound( "Flashbang.Bounce" ) )
            self:SetPos(ent:GetBonePosition(bone))
            self:SetAngles(ent:GetAngles())
            self.HookConstraint = constraint.Weld( self, ent, 0, physbone or 0 , 100000000, true )
            ent.HookConstraint = self.HookConstraint
            ent.LastHookTouched = self
            self:SetFish(ent)
        end)
    end
end

function ENT:Unhook()
    if IsValid(self:GetFish())then
        local fish = self:GetFish()

        constraint.RemoveAll(self)
        if IsValid(fish.HookConstraint) then fish.HookConstraint:Remove() fish.HookConstraint = nil end
        if IsValid(self.HookConstraint) then self.HookConstraint:Remove() self.HookConstraint = nil end
        fish.LastHookTouched = nil
        self:SetFish(NULL)
    end
end


function ENT:CornerLineSegment(a,b)

    local tr = {}
    tr.start = a
    tr.endpos = b
    tr.filter = self
    tr.mask = msk
    local trace = util.TraceLine(tr)

    local tr2 = {}
    tr2.start = b
    tr2.endpos = a
    tr2.filter = self
    tr2.mask = msk
    local trace2 = util.TraceLine(tr2)
    
    local plan = Vector(0,4,3)

    function pon(rp,rd,pp,pn,color)
        local p = util.IntersectRayWithPlane( rp,rd, pp, pn )

        local cc = p and color or Color(100,100,100,color.a)
        return p 
    end

    if trace.Hit and trace2.Hit and !trace.StartSolid and !trace2.StartSolid then  
        local na = trace.HitNormal 
        local nb = trace2.HitNormal 
        --pos = trace.HitPos
        if (na + nb):Length() > 0.01 then
            local hp1 = trace.HitPos
            local hn1 = trace.HitNormal
            local hd1 = trace.Normal
            
            local hp2 = trace2.HitPos
            local hn2 = trace2.HitNormal
            local hd2 = trace2.Normal

            local ntp = pon( hp1 ,hd1 * 10000, hp2, hn2,Color(128,0,255,4) )
            if ntp then
                
                 --debugoverlay.Cross(ntp,4,0,Color(0,255,128),true)
                local ntp2 = pon(  ntp, hn1*10000, hp1, hn1 ,Color(255,128,0,4) )
                if ntp2 then
                    --debugoverlay.Box(ntp2,-Vector(1,1,1)*4,Vector(1,1,1)*4,0,Color(255,255,255,4))
                    local bn = (hn1+hn2):GetNormalized()
                    return ntp2 + bn, bn 
                end
            end
        end
        return trace.HitPos + trace.HitNormal
    end

end

function ENT:GetPullVector()
    local pole =  self:GetPole()
    local ply = pole:GetOwner()
    local tp = IsValid(pole) and pole:GetPoleTip()
    local sp = self:GetPos()

    tp = self.StringSim and self.StringSim[1] or tp
  


    return (tp - sp):GetNormalized()
end

function ENT:SimulateRope(delta)
    delta = delta or 0
    local pole =  self:GetPole()
    local ply = pole:GetOwner()
    
    local vb = pole:GetPoleTip() 
    --va = ply:WorldSpaceCenter()
    local va = self:GetPos()
    local vd = math.abs(va.z - vb.z) --z distance between both ends, used for sag offset
    local tns = pole:GetTension()
    local tnsp = math.max(tns*-1,0) --sag ratio



    local dist = va:Distance(vb)

    local slack = math.max(0,pole:GetReelLength() - dist)

    local width = 0.25

    local dang = 0
    local dheight
    local lastpos = va
    local linec = Color(255,255,255,230)
    local fancy = true
    


    local msk =  CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WATER
    local re = pole:GetReelLength()

    local splines = {}
    local function samp(along)

        return LerpVector(along,va,vb)
    end


    


    local solved = false
    local div = math.Clamp(math.floor(dist/20),3,SERVER and 4 or 5)
    local simpos = va*1
    
    
    self.StringSim = self.StringSim or {}
    for i=1,div do //subdivide
        local a = self.StringSim[i] or va
        local b = self.StringSim[i-1] or va
        local c = self.StringSim[i+1] or vb
        local ca = self:CornerLineSegment(b,c)
        local ofs = Vector()
        if ca then 
            self.StringSim[i] = ca
        else
            self.StringSim[i] = self.StringSim[i] or vb
            ofs = LerpVector(0.5,b,c) - self.StringSim[i]
        end
        
        ofs = ofs + Vector(0,0,-0.025)*tnsp

        local tr2 = {}
        tr2.start = self.StringSim[i]
        tr2.endpos = self.StringSim[i] + ofs
        tr2.filter = self
        tr2.mask = MASK_SOLID
        local trace = util.TraceLine(tr2)
        if trace.Hit then
            self.StringSim[i] = trace.HitPos
        else
            self.StringSim[i] = self.StringSim[i] + ofs
        end

    end


    self.StringSim[div+1] = vb


    if self.StringSim[div+1] then table.remove(self.StringSim,div+1) end



    for k,a in pairs(self.StringSim)do
        a = a or va
        local b = self.StringSim[k+1] or vb
        debugoverlay.Line(a,b,0,Color(0,255,64),false)
        debugoverlay.Line(a,b,0,Color(0,0,255),true)
        debugoverlay.Box(a,Vector(1,1,1)*-0.25,Vector(1,1,1)*0.25,delta,Color(255,255,64,0),true)
    end

    
end


function ENT:DrawString()

    local pole =  self:GetPole()
    local ply = pole:GetOwner()
    
    local vb = pole:GetPoleTip() 
    --va = ply:WorldSpaceCenter()
    local va = self:GetPos()
    local vd = math.abs(va.z - vb.z) --z distance between both ends, used for sag offset
    local tns = pole:GetTension()
    local tnsp = math.max(tns*-1,0) --sag ratio


    local dist = va:Distance(vb)

    local slack = math.max(0,pole:GetReelLength() - dist)

    local width = 0.25


    render.SetColorMaterial()

    local dang = 0
    local dheight
    local lastpos = va
    local linec = Color(255,255,255,230)
    local fancy = true
    


    local msk =  CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WATER
    local re = pole:GetReelLength()


    local subdv = 2
    local strg = self.StringSim
    local segm = table.Count(strg)
    render.StartBeam( segm+2 )

    render.AddBeam( va  , width, 0, linec )

    for si,b in pairs(strg)do

            render.AddBeam( b  , width, 0, linec )
    end
    render.AddBeam( vb  , width, 0, linec )

    render.EndBeam()

end