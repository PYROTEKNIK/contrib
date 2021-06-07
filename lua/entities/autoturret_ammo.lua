-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Base = "base_gmodentity"
ENT.Spawnable = true 
ENT.PrintName = "AutoTurret Ammo"
ENT.Category = "Special Trash"
function ENT:Initialize()
    if(SERVER)then
    self:SetModel("models/items/boxmrounds.mdl")
    self:SetColor(Color(41,61,179))
    self:PhysicsInit(SOLID_VPHYSICS) 
    self:SetMoveType(MOVETYPE_VPHYSICS)
    end
end

function ENT:Draw()
    self:DrawModel()
end


function ENT:Touch(ent)
end


