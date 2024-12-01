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


SWEP.ReelForce = 7500 //force to pull bobber while reeling
SWEP.MinCastForce = 200 //Force to throw bobber at lowest hold time
SWEP.MaxCastForce = 2000 //Force to throw bobber at highest hold time
SWEP.MaxCastTime = 2 //highest hold time before force stops increasing

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

function SWEP:GetTension()
    if !self:IsCast() then return 0 end

    return (self:GetLineLength() - self:GetReelLength()) / self.LineStretch
end


function SWEP:GetPullVector()
    if !self:IsCast() then return Vector() end
    return self:GetPoleTip() - self:GetBobber():GetPos() 
end

function SWEP:GetPull()
    if !self:IsCast() then return nil end

    return 0
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
    local max = 1000
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
        if self:GetReelHeld() or cur_len >= 1000 then
            if SERVER then 
                local ra = pv:Angle()
                local pvw = WorldToLocal(phys:GetVelocity(),Angle(),Vector(),ra)
                local ci = pvw:Length()
                pvw.x = math.max(pvw.x,0)
                pvw:Normalize()
                pvw = pvw*ci
                pvw.x = math.max(pvw.x,0)
                local pvn = LocalToWorld(pvw,Angle(),Vector(),ra)
                phys:SetVelocity(pvn) //halt velocity away from rod.
            end


            if SERVER and reel then //pull bobber to match line tension

                if cur_len > min then 
                    local pwr = self.ReelForce*FrameTime()
                    phys:ApplyForceCenter(pv*pwr)
                    newline = math.max(math.min(newline,cur_len),min)
                
                end
            end

            local pullm = math.Remap(cur_len,min-5,min,1,0)

            if SERVER and dif > -1 and pullm > 0 then 
                phys:ApplyForceCenter(pv*100*pullm)
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

        newline = math.Clamp(newline,5,1000)
        if newline != reel_len then
            self:SetReelLength(newline)
        end

        //don't modify newline after this point

        local ndif = (newline-reel_len)
        local tens = self:GetTension()
        local ptens = tens - 2

        if (reelhold or newline >= 1000) and newline > 100 and (ptens > 0) then


            local pull = math.Clamp(ptens,0,5)
            ply:SetVelocity(-pv*(pull)*80)
        end

        

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
    if IsValid(self:GetBobber()) then
        self:GetBobber():Remove()
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
    local pos,ang = self:GetPosition(w)
    pos = pos + ang:Forward()*85
    pos = pos + ang:Up()*0
    
    return pos 
end

function SWEP:SecondaryAttack()
end





function SWEP:Deploy()
    self:SetHoldType("passive")
    if self.BonePositionsCallback then self:RemoveCallback("BuildBonePositions",self.BonePositionsCallback) end
    self.BonePositionsCallback = self:AddCallback("BuildBonePositions",function() self:BuildBonePositions() end)

end

function SWEP:BuildBonePositions()

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
   
    local pullang = (-self:GetPullVector()):AngleEx(vm:GetAngles():Up())
    local _,aa = WorldToLocal(Vector(),pullang,ply:EyePos(),ply:EyeAngles())
    local m = pull*0.25
    local yaw = (aa.yaw/10) *m
    local pitch = (aa.pitch/10) *m

    for i=a,b do
        local mat = Matrix(matrices[i])

        
        
        --mat:Rotate(Angle(yaw,pitch,0))
        matrices[i] = mat
        --vm:ManipulateBoneAngles(i,Angle(0,0,0))
    end

    for k, v in pairs(matrices) do
        local umat = vm:GetBoneMatrix(vm:GetBoneParent(k))
        umat:Mul(v)
        matrices[k] = umat
        vm:SetBoneMatrix(k, umat)
    end


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
