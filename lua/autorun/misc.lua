﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- damage indicator shit
if SERVER then
    util.AddNetworkString("HitMarker")
    HITMARKERCACHE = {}

    hook.Add("PostEntityTakeDamage", "DamageMarker", function(ent, dmg, took)
        local att = dmg:GetAttacker()

        if ent:IsPlayer() and ent:IsBot() then
            if IsValid(att) and att:IsPlayer() then
                HITMARKERCACHE[att] = (HITMARKERCACHE[att] or 0) + dmg:GetDamage()
            end
        end
    end)

    hook.Add("Tick", "FlushHitMarkers", function()
        for k, v in pairs(HITMARKERCACHE) do
            if IsValid(k) then
                net.Start("HitMarker")
                net.WriteUInt(v, 8)
                net.Send(k)
            end
        end

        HITMARKERCACHE = {}
    end)
else
    local hitmarkers = {}

    net.Receive("HitMarker", function(len)
        local dmg = net.ReadUInt(8)

        table.insert(hitmarkers, {
            dmg = dmg,
            t = SysTime(),
            x = 0.1, --math.Rand(-0.5,0.5),
            
        })
    end)

    hook.Add("PostDrawHUD", "DrawHitMarkers", function()
        local duration = 1
        local t = SysTime()
        local i = 1

        while i <= #hitmarkers do
            local marker = hitmarkers[i]

            if marker.t + duration < t then
                table.remove(hitmarkers, i)
            else
                i = i + 1
                local drift = (t - marker.t) / duration
                local alpha = 1 - drift
                drift = drift + 0.1
                draw.SimpleText(tostring(marker.dmg), "Trebuchet24", ScrW() / 2 + drift * 100 * marker.x + 20, ScrH() / 2 + drift * 125, Color(255, 0, 0, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end)
end

function Safe(ent)
    local loc = 0
    local name = "Unknown"

    if Location then
        loc = ent:IsPlayer() and ent:GetLocation() or Location.Find(ent)
        name = Location.GetLocationNameByIndex(loc)
    end

    if HumanTeamName ~= nil then return false end --and name ~= "Movie Theater"
    if name == "Movie Theater" and (ent:GetPos().y > 1400 or ent:GetPos().z > 150) then return true end

    if name == "Golf" then
        if ent:IsPlayer() then
            local w = ent:GetActiveWeapon()

            if IsValid(w) and w:GetClass() == "weapon_golfclub" then
                if IsValid(w:GetBall()) then return true end
            end
        end
    end

    local pt = protectedTheaterTable and protectedTheaterTable[loc]
    if pt ~= nil and pt["time"] > 1 then return true end

    if ent:IsPlayer() then
        if IsValid(ent:GetVehicle()) then
            if ent:GetVehicle():GetNWBool("IsChessSeat", false) then
                local e = ent:GetVehicle():GetNWEntity("ChessBoard", nil)
                if IsValid(e) and e:GetPlaying() then return true end
            end

            local v = ent:GetVehicle()
            if (v.SeatData ~= nil) and (v.SeatData.Ent ~= nil) and IsValid(v.SeatData.Ent) and v.SeatData.Ent:GetName() == "rocketseat" then return true end
        end
    end

    return false
end

util.PrecacheModel("models/ppm/pony_anims.mdl")
SkyboxPortalEnabled = SkyboxPortalEnabled or false
SkyboxPortalCenter = Vector(290, -418, -8)

if SERVER then
    util.AddNetworkString("bounce")

    net.Receive("bounce", function()
        local t = net.ReadTable()
        local p = Ply("Swamp")

        if IsValid(p) then
            net.Start("bounce")
            net.WriteTable(t)
            net.Send(p)
        end
    end)

    hook.Add("PlayerDeath", "DeathInPitGym", function(ply)
        if ply:GetLocationName() == "The Pit" then
            ply.PitDeath = true
        end

        if ply:GetLocationName() == "Gym" then
            ply.DodgeballDeath = true
        end
    end)

    hook.Add("PlayerSpawn", "SpawnNextToPitGym", function(ply)
        if ply.PitDeath then
            ply.PitDeath = false

            timer.Simple(0, function()
                ply:SetPos(Vector(math.random(-256, 256), -256, 30))
                ply:SetEyeAngles(Angle(0, -90, 0))
            end)
        end

        if ply.DodgeballDeath then
            ply.DodgeballDeath = false

            timer.Simple(0, function()
                ply:SetPos(Vector(math.random(2160, 1903), -1185, -32))
                ply:SetEyeAngles(Angle(0, -90, 0))
            end)
        end
    end)

    hook.Add("InitPostEntity", "FindSwampJeeps", function()
        local swamp_jeeps = ents.FindByClass("prop_vehicle_jeep")

        -- NOOOOO YOU CANT JUST LIMIT THE JEEPS TO ONE AREA!!!
        -- haha jeeps go weee
        hook.Add("Tick", "JeepTeleporter", function()
            for k, v in pairs(swamp_jeeps) do
                if IsValid(v) and v:GetPos().z < 10000 then
                    v:SetPos(Vector(math.random(3073, 5029), math.random(-774, -2762), 12047))
                end
            end
        end)
    end)

    hook.Add("EntityTakeDamage", "BasedDepartmentPhone", function(target, dmg)
        if (IsValid(target) and target:GetClass() == "func_physbox" and target:GetBrushSurfaces()[1]:GetMaterial():GetName() == "swamponions/af/baseddepartment") then return true end
    end)
else
    net.Receive("bounce", function()
        local t = net.ReadTable()
        PrintTable(t)
    end)

    function bounce(t)
        if IsValid(LocalPlayer()) and LocalPlayer():Name() ~= "Swamp" then
            net.Start("bounce")
            net.WriteTable(t)
            net.SendToServer()
        end
    end
end