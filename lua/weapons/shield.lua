if (SERVER) then
    resource.AddWorkshop(2449330138)
end

SWEP.UseHands = false
SWEP.PrintName = "Shield"
SWEP.Author = "PYROTEKNIK"
SWEP.Instructions = ""
SWEP.Category = "PYROTEKNIK"
SWEP.ShootSound = Sound("Airboat.FireGunRevDown")
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Slot = 2
SWEP.SlotPos = 4
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/props_phx/construct/metal_angle360.mdl"
SWEP.WorldModel = "models/props_phx/construct/metal_angle360.mdl"
SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = false
SWEP.DrawAmmo = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = 500
SWEP.Primary.ClipSize = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1

function SWEP:GetShotCount()
end

function SWEP:Initialize()
    self:SetHoldType("melee2")
end

function SWEP:OnRemove()
end

function SWEP:Reload()
end

function SWEP:SecondaryAttack(undo)
end

function SWEP:PrimaryAttack()
end

function SWEP:Think()
end

function SWEP:Deploy()
end

if (SERVER) then
    concommand.Add("ShieldTestBot", function(ply)
        if (not IsValid(SHIELD_TESTINGBOT)) then
            local bot = player.CreateNextBot("Fucker #" .. math.random(100000, 999999))
            bot.ShieldPlayer = true
            SHIELD_TESTINGBOT = bot
        end
       
        local bot = SHIELD_TESTINGBOT
        bot:Spawn()
        bot:SetPos(ply:GetEyeTrace().HitPos)
        bot:SetEyeAngles(Angle(0, ply:EyeAngles().yaw + 180, 0))
        bot:Give("shield")
        bot:SelectWeapon("shield")
    end)
end

if (not util.TraceLineOriginal) then
    util.TraceLineOriginal = util.TraceLine
end

util.TraceLine = util.TraceLineOriginal

Shield_OverrideTrace = function(trace, ply)
    local raypos = trace.StartPos
    local raydelta = trace.HitPos - trace.StartPos

    for k, shield in pairs(ents.FindByClass("shield")) do
        local shieldply = shield:GetOwner()
        if (shieldply == ply) then continue end
        if (IsValid(shieldply) and shieldply:GetActiveWeapon() ~= shield) then continue end

        if (IsValid(shield)) then
            local matrix = shield:DrawWorldModel(nil, true)
            local box = matrix:GetTranslation()
            local boxang = matrix:GetAngles()
            boxang:RotateAroundAxis(boxang:Right(), 22.5)
            local boxang2 = boxang * 1
            boxang2:RotateAroundAxis(boxang2:Right(), 45)
            local size = Vector(28, 3, 28)
            local maxs = size * 0.5
            local mins = size * -0.5
            local pos, normal, fraction = util.IntersectRayWithOBB(raypos, raydelta, box, boxang, mins, maxs)
            local pos2, normal2, fraction2 = util.IntersectRayWithOBB(raypos, raydelta, box, boxang2, mins, maxs)
            local clr = Color(0, 255, 64, 4)

            if (pos) then
                clr = Color(255, 0, 0, 4)
            end

            local t = 0.5
            debugoverlay.BoxAngles(box, mins, maxs, boxang, t, clr)
            debugoverlay.BoxAngles(box, mins, maxs, boxang2, t, clr)

            debugoverlay.Line(raypos,raypos + raydelta,t,clr)
            debugoverlay.SweptBox( raypos,raypos + raydelta, Vector(1,1,1)*-0.2, Vector(1,1,1)*0.2, Angle(), t,clr )
            if (pos and pos2 and raypos:Distance(pos) <= raypos:Distance(trace.HitPos)) then
                trace.Entity = shield
                trace.Fraction = fraction
                trace.HitPos = pos + normal * 0.1
                trace.HitNormal = normal
                trace.Contents = CONTENTS_SOLID
                trace.MatType = MAT_GLASS
                trace.SurfaceProps = util.GetSurfaceIndex("glass")
                trace.SurfaceFlags = SURF_HITBOX
            end
        end
    end

    return trace
end

local shield_dmgfuncs = {}
shield_dmgfuncs[DMG_BULLET] = function(dmg) return end

function Shield_DamageToRay(ent, dmg)
    local startpos = dmg:GetReportedPosition()
    local nocentering
    local inflictor = dmg:GetInflictor()
    local inflictortype = inflictor:GetClass()
    local delta = Vector()
    if (inflictortype == "prop_physics") then
        startpos = inflictor:GetPos()
        delta = dmg:GetDamageForce():GetNormalized()
    end
    if(dmg:GetDamageType() == DMG_BLAST)then
        delta = (ent:WorldSpaceCenter() - dmg:GetDamagePosition())
        startpos = startpos + delta*64
    end

    return startpos,delta
end

function Shield_Trace(raystart, raydelta,dmg)
    local tr = {}
    tr.start = raystart
    tr.endpos = raystart + raydelta:GetNormalized()*55000

    tr.filter = {dmg:GetAttacker()}

    local trace = util.TraceLine(tr)

    return trace
end


local TASER_FLINCHES = {ACT_FLINCH_HEAD, ACT_FLINCH_CHEST, ACT_FLINCH_STOMACH, ACT_FLINCH_LEFTARM, ACT_FLINCH_RIGHTARM, ACT_FLINCH_LEFTLEG, ACT_FLINCH_RIGHTLEG, ACT_FLINCH_PHYSICS, ACT_MP_JUMP_LAND,}

function SWEP:BlockDamage(dmg,trace)
    if (dmg == nil) then return end
    local ply = self:GetOwner()
    ply:AnimRestartGesture(GESTURE_SLOT_FLINCH, ACT_FLINCH_STOMACH, true)
    ply:SetVelocity(dmg:GetDamageForce() / 10)
    dmg:SetDamage(0)
    local effect = EffectData()
    effect:SetAngles(trace.HitNormal:Angle())
    effect:SetNormal(trace.HitNormal)
    effect:SetOrigin(trace.HitPos)
    effect:SetStart(trace.HitPos)
    effect:SetScale(1)
    effect:SetMagnitude(4)
    effect:SetRadius(3)
    util.Effect("Sparks",effect)
    self:EmitSound("physics/metal/metal_solid_impact_bullet" .. math.random(1, 4) .. ".wav", nil, 40)
end

local meta = FindMetaTable("Player")

function meta:GetShield()
    return self:GetWeapon("shield")
end

hook.Add("EntityTakeDamage", "shield_guard", function(ent, dmg)

    local pos,delta = Shield_DamageToRay(ent, dmg)
    local trace = Shield_Trace(pos, delta,dmg)

    local updatedtrace = Shield_OverrideTrace(trace) 
    local ent = updatedtrace.Entity

    if (IsValid(ent) and ent:GetClass() == "shield") then
        ent:BlockDamage(dmg,updatedtrace)

        return true
    end
end)

hook.Add("PlayerTraceAttack", "shield_guard", function(ply, dmg, dir, trace)
    trace = Shield_OverrideTrace(trace)
    local ent = trace.Entity

    if (IsValid(ent) and ent:GetClass() == "shield") then
        ent:BlockDamage(dmg,trace)

        return true
    end
end)

hook.Add("EntityFireBullets", "shield_block", function(ply, bullet)
    bullet.Callback = function(ent, tr, dmg)
        --dmg:SetDamagePosition(tr.StartPos)
        local trace = Shield_OverrideTrace(tr)
        local ent = trace.Entity

        if (IsValid(ent) and ent:GetClass() == "shield") then
            ent:BlockDamage(dmg,trace)
        end

        return trace
    end

    return true
end)

local nonemat = Material("engine/occlusionproxy")
local goldwm = Material("models/pyroteknik/v_gold_smg1_sheet")
local goldwm = Material("models/shiny")

function SWEP:PreDrawViewModel(vm, weapon, ply)
    local ammo = self:GetOwner():GetAmmoCount(self.Primary.Ammo)
    local zero = ammo < 1
    render.MaterialOverrideByIndex(1, goldwm)
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
    render.MaterialOverride(nil)
end

--[[
hook.Add( "PreDrawHalos", "AddPropHalos", function()
	halo.Add( LOLGUNS, Color(0,0,0), 5, 5, 4 ,false)
	halo.Add( LOLGUNS, Color(200,0,255), 4, 4, 4 )
end )
]]
SWEP.ViewModelFOV = 100

function SWEP:GetViewModelPosition(pos, ang)
    return pos, ang
end

function SWEP:DrawWorldModel(flags, check)
    local ply = self:GetOwner()
    local mrt = self:GetBoneMatrix(0)

    if (mrt) then
        mrt:SetTranslation(self:GetPos())
        mrt:SetAngles(self:GetAngles())
        mrt:SetScale(Vector(1, 1, 1))
    end

    if IsValid(ply) then
        local bname = ply.IsPony ~= nil and ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_L_Forearm"
        local bone = ply:LookupBone(bname) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()

        if (bone ~= 0) then
            local bp, ba = self.Owner:GetBonePosition(bone)

            if (bp) then
                opos = bp
            end

            if (ba) then
                oang = ba
            end

            mrt = Matrix()
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)

            if bname == "LrigScull" then
                opos = opos + oang:Right() * -0
                opos = opos + oang:Forward() * 0
                opos = opos + oang:Up() * 0
                oang:RotateAroundAxis(oang:Forward(), 90)
                oang:RotateAroundAxis(oang:Right(), -135)
            else
                opos = opos + oang:Right() * -1
                opos = opos + oang:Forward() * 3
                opos = opos + oang:Up() * 2
                oang:RotateAroundAxis(oang:Right(), 90)
                oang:RotateAroundAxis(oang:Up(), -90)
                oang:RotateAroundAxis(oang:Up(), 30)
            end

            if (not check) then
                self:SetupBones()
            end

            if mrt then
                mrt:SetTranslation(opos)
                mrt:SetAngles(oang)
                mrt:SetScale(Vector(0.3, 0.5, 0.3))

                if (not check) then
                    self:SetBoneMatrix(0, mrt)
                end
            end
        end
    end

    if (not check) then
        render.SetBlend(1)
        render.MaterialOverrideByIndex(1, goldwm)
        self:DrawModel(flags)
        render.MaterialOverride(nil)
        render.MaterialOverrideByIndex(1, nil)
        render.SetBlend(1)
    end

    return mrt
end