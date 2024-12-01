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
        self:SetModel("models/props_junk/Shoe001a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)

        //self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            //phys:SetMass(6)
            phys:SetMaterial("flesh")
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


function ENT:DrawString()

    local pole =  self:GetPole()
    local ply = pole:GetOwner()
    
    local va = pole:GetPoleTip(ply:ShouldDrawLocalPlayer()) 
    local vb = self:GetPos()
    local vd = math.abs(va.z - vb.z) --z distance between both ends, used for sag offset
    local tns = pole:GetTension()
    local tnsp = math.max(tns*-1,0) --sag ratio

    self.PlayerLag = LerpVector(0.01,self.PlayerLag or Vector(), ply:GetVelocity())

    local sa = self.PlayerLag*-0.1 --bend rod end away from player movement

    local sv = self:InWater() and pole:GetPullVector() or (-self.LagVector) --bend line behind bobber movement, towards rod if in water
    local sb = -(sv:GetNormalized()*math.min(100,sv:Length())) --clamp vector to 100 length
    local dist = va:Distance(vb)



    local units = math.Clamp(math.ceil(dist/8),8,30)
    local width = 0.25
    if tns >= 0 then 
        units = 1
    end

    render.SetColorMaterial()
    render.StartBeam( units+1 )
    local dang = 0
    local dheight
    local lastpos = va
    local ul = dist / units
    local linec = Color(255,255,255,230)
    local fancy = true
    for i=0,units do
        local tm = i/units
        
        local sec = LerpVector(tm,va,vb)
        local arc = math.cos( (tm-0.5)*math.pi )
        local amul = math.pow(1-tm,4)*1--(tm)
        local mid = 1-math.pow(math.abs(tm-0.5)*2,2)
        local sag = vd*mid*0.5*tnsp
        --cc.g = mid*255
        --cc.r = arc*255
       
        

        local vsec = LerpVector(tm,sa,sb) * arc * tnsp
        vsec = vsec + Vector(0,0,-sag)



        local pos =  sec + vsec

        if fancy then 
            local tr = {}
            tr.start = pos*1
            tr.start.z = math.max(pos.z,lastpos.z + 16)
            tr.endpos = pos*1
            tr.endpos.z = math.min(pos.z,lastpos.z)
            tr.filter = {self,pole}
            tr.mask = CONTENTS_SOLID + CONTENTS_WATER
            local trace = util.TraceLine(tr)
            --debugoverlay.Line(tr.start,tr.endpos,0,Color(0,255,0),true)
            if trace.Hit then
                pos = trace.HitPos + trace.HitNormal*width*0.5
                dheight = pos.z
                dang = 1
                --debugoverlay.Box(pos,Vector(-1,-1,-1),Vector(1,1,1),0,Color(0,255,0,16),true)
            else
                if dheight and dang and dang > 0 then
                    pos.z = Lerp(math.pow(dang,2),pos.z,dheight)
                    dang = dang - (ul / 100)
                    
                    if dang <= 0 then dang = nil dheight = nil end
                end
            end
        end

        lastpos= pos*1
       

        local col = Color(linec.r,linec.g,linec.b,linec.a)
        local w = width*1 / math.max(1,1+(mid/2)*math.max(0,tns))

        



        render.AddBeam( pos , w, 0, col )
    end
    render.EndBeam()
end