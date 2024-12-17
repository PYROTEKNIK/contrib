-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SWEP.PrintName = "Fishing Pole"
SWEP.Category = "PYROTEKNIK"
SWEP.Instructions = ""
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.m_WeaponDeploySpeed = 9
SWEP.ViewModel = "models/pyroteknik/fishingpole.mdl"
SWEP.WorldModel = "models/pyroteknik/fishingpole.mdl"
SWEP.BobberModel = "models/pyroteknik/fishing_bobber.mdl"
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV           = 90
SWEP.Spawnable = true
SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Instructions = "Catch a fish"


SWEP.ReelForce = 10000 //force to pull bobber while reeling
SWEP.MinCastForce = 200 //Force to throw bobber at lowest hold time
SWEP.MaxCastForce = 2000 //Force to throw bobber at highest hold time
SWEP.MaxCastTime = 2 //highest hold time before force stops increasing
SWEP.MaxLineLength = 2000
SWEP.CatchLen = 48
SWEP.SnapTension = 25

function SWEP:Initialize()
end

function SWEP:Equip(ply)

end



function SWEP:SetupDataTables()
    self:NetworkVar("Entity",0,"Bobber")
    self:NetworkVar("Float",0,"ReelLength")
    self:NetworkVar("Float",1,"SwingStart")
    self:NetworkVar("Float",2,"SwingPower")
    self:NetworkVar("Bool",0,"ReelHeld")

    
    self:NetworkVar("Bool",1,"SwingMode")
    
end

function SWEP:GetLineRatio()
    return 1-(self:GetReelLength() / self.MaxLineLength)

end


function SWEP:ReleaseReel(amount)
    if amount == 0 then return end
    local reel = self:GetReelLength()
    self:SetReelLength(reel+amount)
end

function SWEP:Reel(amount)
    if amount == 0 then return end
    local reel = self:GetReelLength()
    self:SetReelLength(reel-amount)
end

function SWEP:GetLineLength()
    if !self:IsCast() then return nil end
    return self:GetBobber():GetPos():Distance(self:GetPoleTip())
end
SWEP.LineStretch = 16


function SWEP:GetTension(pos)
    if !self:IsCast() then return 0 end
    return (self:GetBobber():GetPos():Distance(pos or self:GetPoleTip()) - self:GetReelLength()) / self.LineStretch
end

function SWEP:GetPullVector()
    if !self:IsCast() then return Vector() end

    if IsValid(self:GetBobber()) then
        return self:GetBobber():GetPullVector()
    end
    return self:GetPoleTip() - self:GetBobber():GetPos() 
end

function SWEP:GetPull()
    if !self:IsCast() then return nil end
    return 0
end

function SWEP:IsHooked()
    return IsValid(self:GetHookedEntity())
end

function SWEP:GetHookedEntity()
    local ent = self:GetBobber()
    local hk
    if IsValid(ent) and ent.GetFish then 
        return ent:GetFish()
    end
end


function SWEP:PrimaryAttack()


end


function SWEP:GetPullbackValue()
    local swing = self:GetSwingStart()
    local casting = self:GetSwingMode()
    local cast = self:IsCast()
    if casting or cast then
        local ct = CurTime()
        
        local dif = math.max(ct-swing,0)
        local fwd = self:GetSwingPower() > 0


        if fwd then 
            local spd = 3
            dif = dif * spd 
           
        else
            dif = dif / self.MaxCastTime
        end
        if cast then 
            dif = dif/4 / self:GetSwingPower()
        end

        dif = math.Clamp(dif,0,1)

        return dif
    end


    return 0
end


function SWEP:Reload()

    local cur_len = self:GetLineLength()
    if SERVER and reel and reelhold and IsValid(bobber) and IsValid(hooked) and cur_len <= self.CatchLen then
        local fish = hooked
        fish:GetPhysicsObject():ApplyForceOffset(vec*4000,bobber:GetPos())
        fish:SetCaught(true)
        bobber:Unhook()
        local vec = self:GetPullVector()
        vec.z = 1
        vec:Normalize()
    

        bobber:EmitSound( Sound( "Flashbang.Bounce" ) )
        return
    end


    if SERVER and self:IsCast() then
        self:RemoveBobber()
    end
end


function SWEP:Think()
    local ply = self:GetOwner()
    if !IsValid(ply) then return end
    local cast = self:IsCast()
    local casting = self:IsCasting()
    local reel = ply:KeyDown(IN_ATTACK)
    local reelhold = ply:KeyDown(IN_ATTACK2)
    local hooked = self:GetHookedEntity()
    local bobber = self:GetBobber()
    
    local holdtype = "passive"

    local pb = self:GetPullbackValue()
    if casting or pb < 1 or reelhold then holdtype = "melee2" end

    if reelhold != self:GetReelHeld() then
        self:SetReelHeld(reelhold)
    end

    if !cast then 

        if !self:GetSwingMode() and reel then
            self:SetSwingMode(true)
            casting = self:IsCasting()
            self:SetSwingStart(CurTime())
            self:SetSwingPower(0)
        end

        if self:GetSwingMode() then
            local pb = self:GetPullbackValue()
            if !reel then


                if self:GetSwingPower() == 0 then
                    self:SetSwingPower(pb)
                    self:SetSwingStart(CurTime()) 
                    ply:SetAnimation(PLAYER_ATTACK1)
                else
                    if self:GetPullbackValue() >= 1 then
                        local pwr = self:GetSwingPower()
                        local force = Lerp(pwr,self.MinCastForce,self.MaxCastForce)
                        
                        if SERVER then 
                            self:Cast(force)
                        end
                        self:SetSwingMode(false)
                        self:SetSwingStart(CurTime())
                        //self:SetSwingPower(0)
                    end

                end

            end

            if self:GetHoldType() != holdtype then
                self:SetHoldType(holdtype)
            end
            self:SetNextPrimaryFire(CurTime())
            return
        end

    end

    
    local min = 32
    local max = self.MaxLineLength
    if cast then 
        local reel_len = self:GetReelLength()
        local cur_len = self:GetLineLength()
        reel_len = math.max(reel_len,min)
        cur_len = math.max(cur_len,min)
        
        local newline = reel_len*1
        local dif = cur_len-reel_len //get difference between current line length, and intended line length
        local delta = 0 //how much reel should be adjusted
        local bob = self:GetBobber()
        local phys = bob:GetPhysicsObject()
        local pv = self:GetPullVector():GetNormalized()
        self.LineClick = self.LineClick or 0
        local tens = self:GetTension()
        --tens = math.min(tens,3)
        //calculate how tension force is applied between bobber and player
        local ndif = (newline-reel_len)
        local ptens = tens
        local massratio = 0
        local pmass = SERVER and ply:GetPhysicsObject():GetMass() or 85
        local reelforce = self.ReelForce
        local fish = bobber:GetFish()


        if ply:OnGround() then
            if ply:Crouching() then 
                pmass = pmass * 2 
            end
        else
            
            pmass = pmass / 2 
        end
        
        local fmass = 1

        if SERVER and IsValid(bobber) and IsValid(bobber:GetFish()) then 
            fmass = bobber:GetFish():GetPhysicsObject():GetMass()
        end
        if IsValid(fish) then --modulate fish pull by 
            fmass = fmass * Lerp(fish:GetInput():Length(),0.25,1)
        end
    

        massratio = fmass / pmass

        local plypull = math.max(massratio,0)
        local fshpull = math.max(1-massratio,0)
        local tensforce = (pmass + fmass) * tens
        
        
        if self:GetReelHeld() or cur_len >= self.MaxLineLength or cur_len < self.CatchLen then

            if SERVER and reel then //pull bobber to match line tension
                if cur_len > min then 
                    local pwr = reelforce*FrameTime()
                    phys:ApplyForceCenter(pv*pwr*fshpull)
                    ply:SetVelocity(-pv*pwr*15*plypull)
                end
            end

            
            if SERVER then //pull bobber to match line tension
                if cur_len > min then 
                    local pwr = tensforce*FrameTime() 
                    phys:ApplyForceCenter(pv*pwr*fshpull)
                    ply:SetVelocity(-pv*pwr*15*plypull)
                    newline = math.max(math.min(newline,cur_len),min)
                end
            end

            local pullm = math.Clamp(tens,0,10)*fshpull

            if SERVER and dif > -1 and pullm > 0 then 
                phys:ApplyForceCenter(pv*phys:GetMass()*pullm)
            end
            if dif < 0 and reel then 
                local pull = math.Clamp(dif,FrameTime()*20,0)
                newline = newline + pull

                ply:SetAnimation(PLAYER_RELOAD)
            end

        else //reel is not being held

            local slackd = cur_len-(reel_len+10) 
            if slackd > 0 then 
            newline = newline + slackd //let reel out to match current length
            end

        end

        newline = math.Clamp(newline,5,self.MaxLineLength)
        if newline != reel_len then
            self:SetReelLength(newline)
        end

        //don't modify newline after this point


      

        if CLIENT then 
            local rl = self:GetReelLength()
            self.LastLineCL = self.LastLineCL or rl
            local ndif = self.LastLineCL - rl
            self.LastLineCL = rl


            self.LineClick = self.LineClick + ndif/8

            self.LineSpin = (self.LineSpin or 0) + ndif*5


            local click = false
            
            if  self.LineClick > 1 then
                self.LineClick = self.LineClick - 1
                click = true
            end

            if  self.LineClick < 0 then
                self.LineClick = self.LineClick + 1
                click = true
            end


            if click then
                self.ClickSound = self.ClickSound or CreateSound( self,"pyroteknik/fishreel_click.wav" )
                self.ClickSound:Stop()
                self.ClickSound:PlayEx(math.Rand(0.3,0.4),math.Rand(99,101))
            end
        end

    end
    if self:GetHoldType() != holdtype then
        self:SetHoldType(holdtype)
    end

end

function SWEP:DrawHUD()
    local bg = Color(4,4,4,128)
    local reel = self:GetReelLength() or 0
    

	local line = self:GetLineLength() or 0
    local gw = 160
    local gh = 64

    local gx = ScrW() - gw - 16
    local gy = ScrH() - gh - 16


    draw.RoundedBox( 8, gx,gy,gw,gh, bg )



    draw.SimpleText( "line: ", "Trebuchet24", gx+64, gy + gh*0.25, color_white,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER )
    draw.SimpleText( "cur: ", "Trebuchet24", gx+64, gy + gh*0.75, color_white,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER )

    draw.SimpleText( string.Comma(math.Round(reel / 52.49344,2)).."m", "Trebuchet24", gx+64, gy + gh*0.25, color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER )
    draw.SimpleText( string.Comma(math.Round(line / 52.49344,2)).."m", "Trebuchet24", gx+64, gy + gh*0.75, color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER )

    local bg = Color(4,4,4,128)
    local fg = Color(255,0,0,255)
    local v = self:GetPullbackValue()
    if self:GetSwingPower() != 0 then
        v = 1-v
    end

    local gw = 256
    local gh = 32

    local c = 8
    local gx = ScrW()/2 - gw/2 - c*2
    local gy = ScrH() - gh - c*2

    if self:IsCast() then
        v = 1
        fg = Color(0,64,128)
    end







    draw.RoundedBox( c*2, gx-c,gy-c,gw+c*2,gh+c*2, bg )

    draw.RoundedBox( c, gx,gy,gw*v,gh, fg )
    
    if self:IsCast() then
        local bs = c
        local fshx = gx + gw * (1-self:GetLineRatio())
        
        local tns = self:GetTension()
        if tns > 0 then
            tns = tns/self.SnapTension
        end
        if tns < 0 then
            tns = 0
        end

        local pullx = fshx + tns
        
        local pg = Color(255,0,0)
        local pw = Lerp(math.pow(tns,2),bs,bs*8)
        local ph = gh * Lerp(1-tns,0,1)

        draw.RoundedBox( 6, pullx - pw/2 + (tns)*pw*0.5,gy + gh/2 - ph/2,pw,ph, pg )

        
        local cg = Color(0,200,0)
        draw.RoundedBox( 4, fshx - bs/2,gy,bs,gh, cg )
        
    
    

    end




end

function SWEP:CustomAmmoDisplay()

	return {}
end


function SWEP:Cast(force)
    local ply = self:GetOwner()
    if !IsValid(self:GetBobber()) then
        local bobber = ents.Create("fishing_bobber")
        assert(bobber,"bobber spawn fail")
        self:SetReelLength(0)

        bobber:SetPos(ply:EyePos() + ply:GetAimVector()*32 + Vector(0,0,16))
        bobber:SetAngles(ply:GetRenderAngles())
        bobber:SetPole(self)
        bobber:SetOwner(ply)
        bobber:Spawn()
        bobber:SetModel(self.BobberModel)
        bobber:Activate()

        local bphys = bobber:GetPhysicsObject()
        if IsValid(bobber) and IsValid(bphys) then
            bphys:SetVelocity(ply:GetVelocity() + ply:GetAimVector()*(force or 600))
            bphys:AddAngleVelocity(VectorRand()*math.Rand(600,1000))
        end

        self:SetBobber(bobber)
        return bobber 
    end
end

function SWEP:RemoveBobber()
    if CLIENT then return end
    local ply = self:GetOwner()
    local bobber = self:GetBobber()
    if IsValid(bobber) then
        bobber:Unhook()
        bobber:Remove()
        self:SetBobber(NULL)
    end
end

function SWEP:IsCast()
    return IsValid(self:GetBobber())
end

function SWEP:IsCasting()
    return !self:IsCast() and self:GetSwingMode()
end

function SWEP:OnRemove()
    if SERVER and self:IsCast() then
        self:RemoveBobber()
    end
end





function SWEP:GetPosition(wr)
    local ply = self:GetOwner()
    local pos = LerpVector(0.7,ply:GetPos(),ply:GetShootPos())

    pos = pos + ply:EyeAngles():Right()*12
    local ang = ply:GetAimVector():Angle()
    if wr then 
        local b1 = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Hand"))
        local b2 = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Hand"))
        
        pos = LerpVector(0.5,b1,b2)
    end
    

    ang:RotateAroundAxis(ang:Right(),30)


    local casting = self:GetSwingMode()
    local cast = self:IsCast()
    if casting or cast then 
        local pba = self:GetPullbackValue()
        local pwr = self:GetSwingPower()
        local fwd = pwr > 0

        local function backf(r)
            return math.ease.OutCirc(r)
        end
        local function fwdf(r)
            return math.ease.OutQuad(r)
        end
        local function retf(r)
            return math.ease.OutQuad(r) 
        end
        local backval = pba
        local fwdval = 0
        if fwd then 
            backval = pwr*(1-pba)
            fwdval = pba
        end
        if cast then
            fwdval = 1
            backval = 0
        end

        local backpos = backf(backval)
        local fwdpos = fwdf(fwdval)



        local swing = (backpos*80) - (fwdpos*45)
        if cast then 
            swing = Lerp(retf(pba),swing,0)
        end


        ang:RotateAroundAxis(ang:Right(),swing)
    end
    

    return pos,ang
end


function SWEP:GetPoleTip()
    local ply = self:GetOwner()
    local pos,ang = self:GetPosition(CLIENT and ply:ShouldDrawLocalPlayer())
        --local pull = self:GetPullVector():Angle()
    for i=0,self:GetBoneCount()-1 do
        --print(i,self:GetBoneName(i))
    end        
    pos = pos + ang:Forward()*5
    local rem = 76
    local bobber = self:GetBobber()

    if CurTime() != self.PoleSimTime then
        self.PoleSim = nil
    end

    if self.PoleSim then return self.PoleSim[#self.PoleSim], self.PoleSim end
    if IsValid(bobber) and CLIENT then
    
        self.PoleSim = {pos}
        local tp = bobber:GetPos() 
        local i = 0
        local lastpos = pos
        while rem >= 0 do
            i = i + 1
            
        
            local sc = math.Clamp(self:GetTension(pos + ang:Forward()*rem)/20,0,i/12)
            rem = rem - 20
            local pull = (tp-pos):Angle()
            ang = LerpAngle(sc,ang,pull)
            
            pos = pos + ang:Forward()*20
            
            
            table.insert(self.PoleSim,pos)
            debugoverlay.Line(pos,lastpos,0,Color(255,0,0),true)
            lastpos = pos 
        end
        self.PoleSimTime = CurTime()

    else
        pos = pos + ang:Forward()*85
    end

    return pos 
end


function SWEP:SecondaryAttack()
end





function SWEP:Deploy()
    self:SetHoldType("passive")
    if self.BonePositionsCallback then self:RemoveCallback("BuildBonePositions",self.BonePositionsCallback) end
    self.BonePositionsCallback = self:AddCallback("BuildBonePositions",function() self:BuildBonePositions() end)

end

function SWEP:BoneMatrixPoleBend(ent)
    ent = ent or self




    
    local matrices = {} --record all local offsets
    for i=0,ent:GetBoneCount()-1 do
        --print(i,self:GetBoneName(i))
        local lmat = ent:GetBoneMatrix(i)
        local pmat = ent:GetBoneMatrix(ent:GetBoneParent(i))
        if !pmat then continue end
        matrices[i] = pmat:GetInverse() * lmat
    end

    local cache = {}
    local a,b = 3,7

    local spin = math.pow(self:GetLineRatio(),0.7) * 8000
    local scale = math.pow(self:GetLineRatio(),0.4) 
    

    matrices[1]:Rotate(Angle(0,0,-spin))

    local sp = math.Clamp(scale,0,1)
    local s = Lerp(sp,0.305,1)
    

    matrices[2]:Scale(Vector(1,s,s))

    matrices[8]:Translate(Vector(math.sin(math.rad(spin/8)),0,Lerp(sp,-2,0)))
    

    local a,b = 3,7

    local rot = Angle(0,0,0)

    local sim = self.PoleSim
    
    if sim then 
    local sm = 1
    local smp = ent:GetBoneMatrix(a)

    for i=a,b do
        
        local mat = Matrix(ent:GetBoneMatrix(ent:GetBoneParent(i)))
        if !mat then continue end

        local p1,p2 = self.PoleSim[sm] ,self.PoleSim[sm+1]
        
        mat:SetTranslation(p1)
        if self.PoleSim[sm+1] then 
            local pa = (p2-p1):AngleEx(Vector(0,0,1))
            mat:SetAngles(pa)
            mat:Rotate(Angle(0,0,90))
        end
        --mat:Rotate(Angle(yaw,pitch,0))
        ent:SetBoneMatrix(i,mat)
        matrices[i] = nil
        sm = sm + 1
    end    
    for k, v in pairs(matrices) do
        local umat = ent:GetBoneMatrix(ent:GetBoneParent(k))
        umat:Mul(v)
        matrices[k] = umat
        ent:SetBoneMatrix(k, umat)
    end
    end
end


function SWEP:BuildBonePositions()

    local ply = self:GetOwner()


    self:BoneMatrixPoleBend()

end

function SWEP:DrawWorldModel(flags)
    local pos,ang = self:GetPosition(true)
    self:SetRenderOrigin(pos)
    self:SetRenderAngles(ang)

    self:DrawModel(flags)
    self.DrawnViewModel = nil
end

function SWEP:PreDrawViewModel(vm,ply,wep)
    self.ViewModelFOV = LocalPlayer():GetFOV()
    local tns = self:GetTension()
    local pull = math.Clamp(tns*3,0,2)
    vm:SetupBones()


    
    local cache = {}
    local a,b = 3,7

    local matrices = {} --record all local offsets
    for i=0,vm:GetBoneCount()-1 do
        local lmat = vm:GetBoneMatrix(i)
        local pmat = vm:GetBoneMatrix(vm:GetBoneParent(i))
        if !pmat then continue end
        matrices[i] = pmat:GetInverse() * lmat
    end

    local spin = self.LineSpin or 0

    matrices[1]:Rotate(Angle(0,0,-spin))
    for i=0,vm:GetBoneCount()-1 do
        --print(i,vm:GetBoneName(i))
    end
    local rot = Angle(0,0,0)

    self:BoneMatrixPoleBend(vm)

end

function SWEP:PostDrawViewModel(vm,ply)
    self.DrawnViewModel = vm
end

function SWEP:GetViewModelPosition(pos,ang)
    local tns = self:GetTension()
    local pull = math.Clamp(tns-1,0,2)
    pull = 0

    local pos,ang = self:GetPosition()
    return pos,ang
end
