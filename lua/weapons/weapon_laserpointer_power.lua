AddCSLuaFile()
SWEP.Base = "weapon_laserpointer"
SWEP.PrintName = "Epic Laser Pointer"
SWEP.Author = "PYROTEKNIK & Brian"
SWEP.Category = "PYROTEKNIK"
SWEP.Instructions = "Left Click to fry people, Press R to change color"
SWEP.Purpose = "Modified to drain its battery very fast"
SWEP.Slot = 1
SWEP.SlotPos = 100
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/brian/laserpointer.mdl")
SWEP.WorldModel = Model("models/brian/laserpointer.mdl")

SWEP.Damage = 20 --damage to inflict on high power mode
SWEP.BeamBatteryCost = 15
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1000
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "laserpointer"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.BobScale = 0
SWEP.SwayScale = 0
SWEP.ClickSound = Sound("Weapon_Pistol.Empty")
SWEP.UnClickSound = Sound("Weapon_AR2.Empty")
SWEP.DrawCrosshair = false
SWEP.BounceWeaponIcon = false
SWEP.LaserMask = nil --MASK_SHOT

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "OnState")
    self:NetworkVar("Bool", 1, "BeamMode")
    self:NetworkVar("Vector", 0, "CustomColor")
    function self:GetBeamMode()
        return true
    end
end


hook.Add("NetworkEntityCreated", "LaserPointerFind2", function(ent)
    if ent:GetClass() == "weapon_laserpointer_power" then --because derived classes shouldn't need extra hooks, that's why
        lpointer_laser_source[ent] = true
    end
end)

hook.Add("EntityRemoved", "LaserPointerRemove2", function(ent)
    if ent:GetClass() == "weapon_laserpointer_power" then
        lpointer_laser_source[ent] = nil
    end
end)

local pony_head_hitbones = {}
pony_head_hitbones["LrigScull"] = true
pony_head_hitbones["Mane01"] = true
pony_head_hitbones["Mane02"] = true
pony_head_hitbones["Mane03"] = true
pony_head_hitbones["Mane04"] = true
pony_head_hitbones["Mane05"] = true

function SWEP:SVBeam(ply, origin, dir, phase)
    if (not SERVER or not IsValid(ply) or not IsValid(self) or origin == nil or dir == nil) then return end
    phase = phase or 0
    if (phase >= 15) then return end
    local trace = {}
    trace.start = origin
    trace.endpos = origin + (dir * 60000)
    trace.mask = self.LaserMask

    if (phase == 0) then
        trace.filter = {ply}
    end

    local tr = util.TraceLine(trace)
    if (tr.HitSky and (math.random(1, 10000) == 1)) then
        self:MakePlane(tr.HitPos + (origin - tr.HitPos):GetNormal() * 1000, ply:GetPos())
    end

    if (tr.HitWorld or tr.Hit) then
        local reflect = tr.Entity:GetClass() == "func_reflective_glass" or tr.MatType == MAT_GLASS

        if (reflect) then
            local newstart = tr.HitPos
            local dir3 = tr.Normal - 2 * tr.Normal:Dot(tr.HitNormal) * tr.HitNormal
            self:SVBeam(ply, newstart, dir3, phase + 1)
        else
            if (IsValid(tr.Entity) and tr.Entity.Health ~= nil) then
                if (Safe == nil or (isfunction(Safe) and not Safe(tr.Entity))) then
                    local d = DamageInfo()
                    d:SetDamage(self.Damage)
                    d:SetAttacker(ply)
                    d:SetInflictor(self)
                    d:SetDamageType(DMG_DISSOLVE)
                    tr.Entity:TakeDamageInfo(d)
                end
                self:SVBeam(ply, tr.HitPos, dir, phase + 1)
            end
            
        end
    end
end

if (CLIENT) then
    beam_material = CreateMaterial("laserpointer_beam", "UnlitGeneric", {
        ["$basetexture"] = "sprites/light_glow02",
        ["$model"] = 1,
        ["$additive"] = 1,
        ["$translucent"] = 1,
        ["$color2"] = Vector(4, 4, 4),
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1
    })

    laser_material = CreateMaterial("laserpointer_shine", "UnlitGeneric", {
        ["$basetexture"] = "sprites/physgun_glow",
        ["$model"] = 1,
        ["$additive"] = 1,
        ["$translucent"] = 1,
        ["$color2"] = Vector(4, 4, 4),
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1
    })
end

function SWEP:DrawBeam(ply, origin, dir, color, phase, startoverride)
    if (not CLIENT or not IsValid(ply) or not IsValid(self) or origin == nil or dir == nil or color == nil) then return end
    phase = phase or 0
    if (phase >= 15) then return end
    local trace = {}
    trace.start = origin
    trace.endpos = origin + (dir * 60000)
    trace.mask = self.LaserMask

    if (phase == 0) then
        trace.filter = {ply}
    end

    local bigstart = false
    local basesize = 32

    local tr = util.TraceLine(trace)
    local beamstart = origin
    local beamend = tr.HitPos

    if (tr.Entity == LocalPlayer():GetObserverTarget() or tr.Entity == LocalPlayer() or beamend:Distance(EyePos()) < 5) then
        local dot = dir:Dot(LocalPlayer():GetAimVector() * -1)

        if (tr.Entity:IsPlayer() and math.deg(math.acos(dot)) < 45) then
            local hitply = tr.Entity
            local bonehit = hitply:GetHitBoxBone(tr.HitBox, hitply:GetHitboxSet())
            local bonename = (bonehit ~= nil and hitply:GetBoneName(bonehit)) or "LrigScull" --if we can't find a head bone on your model, every hitbox is your face. fuck you.

            if (hitply:GetHitBoxHitGroup(tr.HitBox, hitply:GetHitboxSet()) == HITGROUP_HEAD or pony_head_hitbones[bonename]) then
                if (not tr.Entity:ShouldDrawLocalPlayer()) then
                    beamend = EyePos() + (origin - EyePos()):GetNormalized() * 16
                    tr.HitNormal = EyeAngles():Forward()
                    basesize = basesize * 16
                end
            end
        end
       
    end

    local _, _, cv = ColorToHSV(color)
    local cwh = Color(255 * cv, 255 * cv, 255 * cv)

    if (startoverride and type(startoverride) == "Vector") then
        beamstart = startoverride
    end

    
        local viewnormal = (EyePos() - beamstart):GetNormal()
        local startsize = basesize / 2
        --if(phase == 0)then startsize = startsize / 3 end
        render.DrawQuadEasy(beamstart + viewnormal * (basesize / 2), viewnormal, startsize / 2, startsize / 2, color, math.Rand(0, 360))
        render.DrawQuadEasy(beamstart, viewnormal * (basesize / 2), startsize / 4, startsize / 4, cwh, math.Rand(0, 360))

    render.SetMaterial(beam_material)
    local dist = math.Rand(0.45, 0.55)

    
    render.DrawBeam(beamstart, beamend, basesize / 4, dist, dist, color)
    render.DrawBeam(beamstart, beamend, basesize / 8, dist, dist, cwh)


    render.SetMaterial(laser_material)

    if ((tr.HitWorld or tr.Hit) and not tr.HitSky) then
        local reflect = tr.Entity:GetClass() == "func_reflective_glass" or tr.MatType == MAT_GLASS

        if (reflect) then
            local newstart = tr.HitPos
            local dir3 = tr.Normal - 2 * tr.Normal:Dot(tr.HitNormal) * tr.HitNormal
            self:DrawBeam(ply, newstart, dir3, color, phase + 1, nil)
        else
            --put the above 4 lines in else for if(reflect) if you want it to only place a dot on the end
            local viewnormal = (EyePos() - beamend):GetNormal()
            render.DrawQuadEasy(beamend + (viewnormal * 4), tr.HitNormal, basesize, basesize, color, math.Rand(0, 360))
            render.DrawQuadEasy(beamend + (viewnormal * 4), tr.HitNormal, basesize / 2, basesize / 2, cwh, math.Rand(0, 360))
            render.DrawQuadEasy(beamend + (viewnormal * 4), viewnormal, basesize, basesize, color, math.Rand(0, 360))
            render.DrawQuadEasy(beamend + (viewnormal * 4), viewnormal, basesize / 2, basesize / 2, cwh, math.Rand(0, 360)) 
        end
    end
end
