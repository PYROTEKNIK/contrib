SWEP.PrintName = "Territory Map"
-- INSTALL: CINEMA
SWEP.Author = "PYROTEKNIK"
SWEP.Instructions = ""
SWEP.Category = "PYROTEKNIK"
SWEP.Spawnable = true
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.DrawAmmo = false
SWEP.ViewModel = "models/props_phx/rt_screen.mdl"
SWEP.WorldModel = "models/props_phx/rt_screen.mdl"
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Ammo = "none"
SWEP.SwayScale = 0
SWEP.BobScale = 0

function SWEP:GetViewModelPosition(pos,ang)
    pos = pos + ang:Up() * -44
    pos = pos + ang:Forward() * 110
    ang:RotateAroundAxis(ang:Up(),180)
    ang:RotateAroundAxis(ang:Right(),15)

    return pos,ang
end

local def = "phoenix_storms/rt_camera"


function SWEP:PreDrawViewModel(vm,ply,wep)
    self.ScreenMat = Material(vm:GetMaterials()[2])
    self.ScreenMat:SetTexture("$basetexture",WARMAP_MAPRT)
    render.SetLightingOrigin( EyePos() )
end

function SWEP:PostDrawViewModel(vm,ply,wep)
    
    self.ScreenMat:SetTexture("$basetexture",def)
end