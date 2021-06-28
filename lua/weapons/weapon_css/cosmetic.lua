AddCSLuaFile()

SWEP.BoostBase = 64

function SWEP:GetHighlightColor()
    local boost = Vector(1,1,1)*self.BoostBase
    local basecolor = Vector(0,0.4,1)
    local glowclr = boost * basecolor
    return glowclr
end



function SWEP:CopyMat(ent)
    local matcopy = ent:GetMaterials()[1]
    local oldmat = Material(matcopy)
    local copytable = {}
    copytable["$basetexture"] = oldmat:GetString("$basetexture")
    copytable["$normalmap"] = oldmat:GetString("$normalmap") or oldmat:GetString("$bumpmap") or "effects/flat_normal"

    local newmat = ent.CopyMat 
    if(!newmat)then
    newmat = CreateMaterial(self:EntIndex().." "..matcopy.."custcopy1",oldmat:GetShader(),copytable)
    newmat:SetTexture("$basetexture", copytable["$basetexture"])
    newmat:SetTexture("$normalmap", copytable["$normalmap"])
    newmat:SetTexture("$bumpmap", copytable["$normalmap"])

    --[[
    newmat:SetTexture("$detail","guncustomization/camo_pattern")

    newmat:SetInt("$detailscale",1)
    newmat:SetFloat("$detailblendfactor",1)
    newmat:SetInt("$detailblendmode",4)
    newmat:SetVector("$detailtint",Vector(1,1,1))
    ]]
    newmat:SetVector("$color2",self:GetHighlightColor() / 10)

    newmat:SetInt("$phong",1)
    newmat:SetInt("$basemapluminancephongmask",1)
    newmat:SetInt("$phongboost",64)
    newmat:SetInt("$phongexponent",16)
    newmat:SetVector("$phongtint",self:GetHighlightColor() / self.BoostBase)
   
    
    newmat:SetVector("$phongfresnelranges",Vector(0,0.5,1))

    ent.CopyMat = newmat
    return ent.CopyMat
end

function SWEP:TweakMaterial(mat)
    mat:SetString("$detail","models/guncustomization/pattern_camo")
end
function SWEP:UnTweakMaterial(mat)
mat:SetString("$detail","")
end



function SWEP:PreDrawViewModel(vm,wep,ply)
    local mat = self:CopyMat(vm)
    vm:SetMaterial("!"..mat:GetName())
    --render.MaterialOverride(mat)
    --ply:GetHands():SetParent(ply:GetViewModel(0))
end

function SWEP:PostDrawViewModel(vm,wep,ply)
    vm:SetMaterial("")
    render.MaterialOverride()
    --ply:GetHands():SetParent(ply:GetViewModel(0))
end

function SWEP:DrawWorldModel()
    local glowclr = self:GetHighlightColor()
    render.SetColorModulation(glowclr.x,glowclr.y,glowclr.z)
    self:DrawModel()
    render.SetColorModulation(1,1,1)
end
