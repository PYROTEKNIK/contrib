-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Bounce Pad"
ENT.Spawnable = true

function ENT:CanEdit(steamid)
return true 
end

function ENT:GetTaped()
    return true
end

ENT.ForceSettings = {
    [1] = {300, Color(8, 255, 8)},
    [2] = {500, Color(255, 180, 8)},
    [3] = {700, Color(255, 6, 0)},
    [4] = {900, Color(32, 0, 255)},
}

function ENT:Initialize()
    if(CLIENT)then self:SetPredictable(true) end
       
    if CLIENT then return end
    self:SetModel("models/pyroteknik/booster.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    phys:Wake()
    self.IgnoreEnts = {}
    self.ForceSetting = 0
    self.Directional = true
    self:ChangePower()
end

function ENT:ChangePower()
    self.ForceSetting = (self.ForceSetting or 1) + 1

    if (self.ForceSetting > #self.ForceSettings) then
        self.ForceSetting = 1
    end

    if (self.ForceSettings[self.ForceSetting]) then
        local frozen = not self:GetPhysicsObject():IsMotionEnabled()
        local tab = self.ForceSettings[self.ForceSetting]
        local clr = tab[2]
        self:SetColor(frozen and clr or Color(8, 8, 8))
        self:SetBodygroup(0, self.Directional and 0 or 1)
    end
end

function ENT:Think()
    if (SERVER) then
        local frozen = not self:GetPhysicsObject():IsMotionEnabled()
        local tab = self.ForceSettings[self.ForceSetting]
        local clr = tab[2]
        self:SetColor(frozen and clr or Color(8, 8, 8))
        self:SetBodygroup(1, self.Directional and 0 or 1)
        --self:SetColor(Color(0,0,0))
    end

    if (CLIENT) then
        
        --should only display if other messages are expired
        if (self:CanEdit(LocalPlayer():SteamID()) and LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance(self:GetPos()) < 96) then
            local use = string.upper(input.LookupBinding("+use")) or "E"
            local shift =  string.upper(input.LookupBinding("+speed")) or "SHIFT"
            local notify = use.." to Adjust Power. "..shift.."+"..use.." to Toggle Diagonal Launch"
            if(!self:GetTaped())then
                notify = "Must be taped to activate."
            end
            local expired = LatestNotificationTime + 4 < CurTime()

            if ((LatestNotification ~= notify and expired)) then
                LocalPlayerNotify(notify)
            else
                LatestNotificationTime = CurTime() - 3.5
            end
        end
        self:SetNextClientThink(CurTime() + 0.5)
        return true
    end
end

function ENT:GetPower()
    local tab = self.ForceSettings[self.ForceSetting]

    return tab[1]
end

function ENT:Use(activator, caller)
    local frozen = not self:GetPhysicsObject():IsMotionEnabled()
    local shift = activator:KeyDown(IN_SPEED)

    if (frozen) then
        if (shift) then
            self.Directional = not self.Directional
            self:SetBodygroup(1, self.Directional and 1 or 0)
            activator:Notify(self.Directional and "Diagonal On" or "Diagonal Off")
        else
            self:ChangePower()
            activator:Notify("Power: "..string.Comma(self:GetPower()))
        end

        self:EmitSound("buttons/button16.wav", 60, (self.Directional and 70 or 50) + self:GetPower() / 150)
    end
    --self:EmitSound("physics/metal/metal_solid_impact_soft" .. math.random(1, 3) .. ".wav", 60, 50)
end

function ENT:PhysicsCollide(data, phys)
end


function ENT:Touch(ent)
    local frozen = not self:GetPhysicsObject():IsMotionEnabled()
    if (not frozen) then return end
    --if(!ent:IsPlayer())then return end
    local pos = WorldToLocal(ent:GetPos(), Angle(), self:GetPos(), self:GetAngles())
    local pos2 = WorldToLocal(ent:WorldSpaceCenter(), Angle(), self:GetPos(), self:GetAngles())

    if ((pos2 * Vector(1, 1, 0)):Length() > 40) then
        if (ent:IsPlayer() and pos.z < 2) then
            ent:SetPos(ent:GetPos() + self:GetUp() * 5)
            ent:SetVelocity(ent:GetUp() * 44)
        end

        return
    end

    if (pos.z < 0) then return end
    self.IgnoreEnts = self.IgnoreEnts or {}
    local ignored = (self.IgnoreEnts[ent] and self.IgnoreEnts[ent] > CurTime())

    if (not ignored) then
        local dir = (self:GetUp() * 1 + self:GetForward() * (self.Directional and 1 or 0))
        local shootvel = dir * self:GetPower()

        if (ent:IsPlayer()) then
            local mins, maxs = ent:GetCollisionBounds()
            local ofs = Vector(0, 0, -maxs.z / 2)
            local cmins = mins + ofs
            local cmaxs = maxs + ofs
            local centerpos = self:GetPos() + self:GetUp() * 8
            local cubeoffset = self:GetUp()
            local threshold = 0.06
            local thresholdz = 0.3
            cubeoffset.x = cubeoffset.x > threshold and 1 or cubeoffset.x < -threshold and -1 or 0
            cubeoffset.y = cubeoffset.y > threshold and 1 or cubeoffset.y < -threshold and -1 or 0
            cubeoffset.z = cubeoffset.z > thresholdz and 1 or cubeoffset.z < -thresholdz and -1 or 0
            debugoverlay.Box(centerpos + ofs + cubeoffset * cmaxs, mins, maxs, 5, Color(255, 0, 255, 32))
            local neworigin = centerpos + cubeoffset * cmaxs + ofs
            local tr = {}
            tr.endpos = neworigin
            tr.start = neworigin - self:GetUp()

            --tr.mask = MASK_SOLID
            tr.filter = {ent}

            tr.mins = mins
            tr.maxs = maxs
            local trace = util.TraceHull(tr)
            if (trace.Entity == self) then
                ent:Notify("Blocked by self! Complain to PYROTEKNIK if this happens super frequently.")
            end

            if (not trace.StartSolid) then
                ent:SetPos(neworigin)
            else
                ent:Notify("Blocked by object!")
                self:EmitSound("buttons/button3.wav", 60, 70 + self:GetPower() / 150)
                self.IgnoreEnts[ent] = CurTime() + 0.1

                return
            end

            if (ent:OnGround()) then
                shootvel.z = math.max(shootvel.z, 200)
            end

            ent.BouncePadOverride = shootvel
            ent.FeetAreBouncePadFlavored = true
        end

        local obj = ent

        if (not ent:IsPlayer() and IsValid(ent:GetPhysicsObject())) then
            obj = ent:GetPhysicsObject()
            obj:SetVelocity(shootvel)
        end

        --
        self:EmitSound("ambient/machines/spinup.wav", 60, 80)
        --self:EmitSound("physics/metal/metal_solid_impact_soft" .. math.random(1, 3) .. ".wav", 60, 50)
    end

    self.IgnoreEnts[ent] = CurTime() + 0.1
end




hook.Add("Move", "BouncePad_Override", function(ply, mv)
    if (ply.BouncePadOverride) then
        mv:SetVelocity(ply.BouncePadOverride * 1)
        ply.BouncePadOverride = nil
    end
end)

hook.Add("GetFallDamage", "BouncePadNoCrunch", function(ply, speed)
    if (IsValid(ply:GetGroundEntity()) and ply:GetGroundEntity():GetClass() == "boostpad" or ply.FeetAreBouncePadFlavored) then
        ply.FeetAreBouncePadFlavored = nil
        return 0
    end
end)