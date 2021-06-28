-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Planted C4"

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel("models/weapons/w_c4_planted.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    

end

function ENT:Think()
end



function ENT:SetTimer(delay)
    self:SetTimeLeft( math.ceil(delay))
    self:TimerCreate("bombtimer",delay,1,function()
        local explosion = ents.Create( "env_explosion" ) -- The explosion entity
        explosion:SetPos( self:GetPos() ) -- Put the position of the explosion at the position of the entity
        explosion:SetOwner(self)
        explosion:Spawn() -- Spawn the explosion
        explosion:SetKeyValue( "iMagnitude", "150" ) -- the magnitude of the explosion
        explosion:Fire( "Explode", 0, 0 ) -- explode
        self:Remove()
    end)
    self:TimerCreate("beep",1,0,function()
        self:EmitSound("C4.PlantSound")
        self:SetTimeLeft( math.ceil(timer.TimeLeft(self.ENT_TIMERS.bombtimer) or 0))
    end)

end

function ENT:SetupDataTables()
    self:NetworkVar("Int",0,"TimeLeft")
end

function ENT:Draw()
    self:DrawModel()

    for i=0,self:GetBoneCount()-1 do
        --print(vm:GetBoneName(i))
    end
    local pos,ang = self:GetPos(),self:GetAngles()
    ang:RotateAroundAxis(ang:Forward(),0)
    ang:RotateAroundAxis(ang:Up(),-90)
    
    pos = pos + ang:Up() * 8.9
    pos = pos + ang:Right() * -3
    pos = pos + ang:Forward() * 4.6

    local times = string.FormattedTime(self:GetTimeLeft() , "%02i:%02i" )
    cam.Start3D2D(pos,ang,1/25)
    
    draw.SimpleText(times,"BombFont",0,0,Color(255,44,0,150),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.SimpleText(times,"BombFont2",0,0,Color(255,105,72,50),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    
    cam.End3D2D() 

end