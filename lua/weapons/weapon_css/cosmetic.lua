AddCSLuaFile()
SWEP.BoostBase = 4
SWEP.SubMatID = 1
SWEP.SubMatIDWorld = 1

function SWEP:GetHighlightColor()
    local ran = HSVToColor(math.Rand(0,360),math.Rand(0.7,0.9),math.Rand(1,1))
    ran = Color(ran.r,ran.g,ran.b)
    self.BaseColor = self.BaseColor or ran:ToVector()
    local boost = Vector(1, 1, 1) * self.BoostBase
    local basecolor =  self.BaseColor
    local glowclr = boost * basecolor

    return glowclr
end

local MatGen = {}

MatGen["livery"] = function(ent,newmat,copytable)

    newmat:SetVector("$color2", ent:GetHighlightColor())
    newmat:SetUndefined("$bumpmap")
    newmat:SetTexture("$detail","guncustomization/pattern_camo")
    newmat:SetUndefined("$phong")
    newmat:SetInt("$detailscale",1)
    newmat:SetFloat("$detailblendfactor",0.8)
    newmat:SetInt("$detailblendmode",8)
    newmat:SetVector("$detailtint",Vector(2,2,2))
    
end

MatGen["alloy"] = function(ent,newmat,copytable)
    newmat:SetTexture("$bumpmap", copytable["$normalmap"])
    newmat:SetVector("$color2", ent:GetHighlightColor()  ) 
    newmat:SetInt("$phong", 1)
    newmat:SetInt("$phongalbedotint", 0)
    newmat:SetInt("basemapluminancephongmask",1)
    newmat:SetTexture("$phongexponenttexture","guncustomization/albedotint")

    newmat:SetInt("$phongboost", 150)
    newmat:SetInt("$phongexponent", 16)

    newmat:SetVector("$phongtint", ent:GetHighlightColor() / ent.BoostBase)
    newmat:SetVector("$phongfresnelranges", Vector(0, 0.5, 1)) 
end



function SWEP:CopyMat(ent,index,matcopy)
    local rf,rk = table.Random(MatGen)
    self.MatFunc = self.MatFunc or rk
    self.MaterialCopies = self.MaterialCopies or {}
    
    --print(self:GetModel())
   -- print(self:GetMaterials()[index])
    --print(ent)
    --PrintTable(ent:GetMaterials())
    local oldmat = Material(matcopy)
    local copytable = {}
    copytable["$basetexture"] = oldmat:GetString("$basetexture")
    --copytable["$basetexturetransform"] = oldmat:GetMatrix("$basetexturetransform") or Matrix()
    copytable["$normalmap"] = oldmat:GetString("$normalmap") or oldmat:GetString("$bumpmap") or "effects/flat_normal"
    local newmat = self.MaterialCopies[matcopy]

    if (not newmat) then
        newmat = CreateMaterial(self:GetClass().." " ..self:EntIndex() .. " " .. matcopy .. "custcopy2", oldmat:GetShader(), copytable)
        --newmat:SetTexture("$basetexture", copytable["$basetexture"])
        --newmat:SetTexture("$normalmap", copytable["$normalmap"])

        MatGen[self.MatFunc](self,newmat,copytable)
        self.MaterialCopies[matcopy] = newmat
    end
    
        
    --MatGen[self.MatFunc](self,newmat,copytable)
    --print(self.MaterialCopies[matcopy]:GetString("$basetexture"))
    return self.MaterialCopies[matcopy]
end



function SWEP:PreDrawViewModel(vm, wep, ply)

    local matcopy = vm:GetMaterials()[self.SubMatID or 1]
    local mat = self:CopyMat(vm,self.SubMatID or 1,matcopy)
    render.MaterialOverrideByIndex((self.SubMatID or 1)-1, mat)

end

function SWEP:PostDrawViewModel(vm, wep, ply)
    render.MaterialOverrideByIndex((self.SubMatID or 1)-1)
    --ply:GetHands():SetParent(ply:GetViewModel(0))
end

SWEP.RenderGroup = RENDERGROUP_OPAQUE

function SWEP:DrawWorldModel(flags)
    

    local glowclr = self:GetHighlightColor()
    local matcopy =  self.WMat or self:GetMaterials()[self.SubMatIDWorld or 1]
    local mat = self:CopyMat(self,self.SubMatIDWorld or 1,matcopy)

    render.MaterialOverrideByIndex((self.SubMatIDWorld or 1)-1, mat)
    render.ModelMaterialOverride(mat)
    self:DrawModel(flags)
    if(self.DualWield)then
        local ply = self:GetOwner()

        local mat 
        if(IsValid(ply))then
            mat = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_L_Hand") or 0)
            if(mat)then
            
                local ang = mat:GetAngles()
                ang:RotateAroundAxis(ang:Forward(),180)
                mat:SetAngles(ang)
                mat:Translate(Vector(0,2,0))
                
            end
        else
            mat = self:GetBoneMatrix(0)
            local ang = mat:GetAngles()
                ang:RotateAroundAxis(ang:Forward(),180)
                ang:RotateAroundAxis(ang:Right(),45)
                ang:RotateAroundAxis(ang:Up(),15)
                
                mat:SetAngles(ang)
                mat:Translate(Vector(0,0,0))
        end
        
        if(mat)then
            self:SetBoneMatrix(0,mat)
               
            self:DrawModel(flags)
            self:SetupBones()
        end
       
    end

    render.ModelMaterialOverride()
    render.MaterialOverrideByIndex((self.SubMatIDWorld or 1)-1)
    -- i have no fucking clue why but checking this value before drawing the world model returns the viewmodel materials on the weapon's entity.
    if(self.WMat == nil)then
        local mat = self:GetMaterials()[self.SubMatIDWorld or 1]
        if(string.find(mat,"models/weapons/v_models/"))then return end
        print(mat)
    self.WMat = mat
    end



end