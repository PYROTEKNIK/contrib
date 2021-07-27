﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local Player = FindMetaTable('Player')
local Entity = FindMetaTable('Entity')
local EntityGetModel = Entity.GetModel
SS_MaterialCache = {}

--NOMINIFY
function SS_GetMaterial(nam)
    SS_MaterialCache[nam] = SS_MaterialCache[nam] or Material(nam)

    return SS_MaterialCache[nam]
end

function SS_PreRender(item)
    if item.cfg.imgur then
        local imat = WebMaterial({
            id = item.cfg.imgur.url,
            owner = item.owner,
            -- worksafe = true, -- pos = IsValid(item.owner) and item.owner:IsPlayer() and item.owner:GetPos(),
            stretch = true,
            shader = "VertexLitGeneric",
            params = [[{["$alphatest"]=1}]]
        })

        render.MaterialOverride(imat)
        --render.OverrideDepthEnable(true,true)
    else
        local mat = item.cfg.material or item.material

        if mat then
            render.MaterialOverride(SS_GetMaterial(mat))
        else
            render.MaterialOverride()
        end
    end

    local col = (item.GetColor and item:GetColor()) or item.cfg.color or item.color

    if col then
        render.SetColorModulation(col.x, col.y, col.z)
    end
end

function SS_PostRender()
    render.SetColorModulation(1, 1, 1)
    render.MaterialOverride()
    --render.OverrideDepthEnable(false)
end

hook.Add("PrePlayerDraw", "SS_PrePlayerDraw", function(ply)
    if not ply:Alive() then return end
    -- will be "false" if the model is not mounted yet
    local m = ply:GetActualModel()

    if ply.SS_SetupPlayermodel ~= m and ply:GetBoneContents(0) ~= 0 then
        SS_ApplyBoneMods(ply, ply:SS_GetActivePlayermodelMods())
        SS_ApplyMaterialMods(ply, ply)
        ply.SS_SetupPlayermodel = m
    end

    if EyePos():DistToSqr(ply:GetPos()) < 2000000 then
        ply:SS_AttachAccessories(ply.SS_ShownItems)
    end
end)

-- hook.Add("NetworkEntityCreated","fix2",function(ent)
--     if ent:IsPlayer() then print("NEC", ent) end
--     ent.SS_PlayermodelModsClean=false end)
local function AddScaleRecursive(ent, b, scn, recurse, safety)
    if safety[b] then
        error("BONE LOOP!")
    end

    safety[b] = true
    local sco = ent:GetManipulateBoneScale(b)
    sco.x = sco.x * scn.x
    sco.y = sco.y * scn.y
    sco.z = sco.z * scn.z

    if ent:GetModel() == "models/milaco/minecraft_pm/minecraft_pm.mdl" then
        sco.x = math.min(sco.x, 1)
        sco.y = math.min(sco.y, 1)
        sco.z = math.min(sco.z, 1)
    end

    ent:ManipulateBoneScale(b, sco)

    if recurse then
        for i, v in ipairs(ent:GetChildBones(b)) do
            AddScaleRecursive(ent, v, scn, recurse, safety)
        end
    end
end

--only bone scale right now...
--if you do pos/angles, must do a combination override to make it work with emotes, vape arm etc
function SS_ApplyBoneMods(ent, mods)
    for x = 0, (ent:GetBoneCount() - 1) do
        ent:ManipulateBoneScale(x, Vector(1, 1, 1))
        ent:ManipulateBonePosition(x, Vector(0, 0, 0))
    end

    if HumanTeamName then return end
    local pone = isPonyModel(ent:GetModel())
    local suffix = pone and "_p" or "_h"
    --if pelvis has no children, it's not ready!
    local pelvis = ent:LookupBone(pone and "LrigPelvis" or "ValveBiped.Bip01_Pelvis")
    if pelvis then end -- assert(#ent:GetChildBones(pelvis) > 0, ent:GetModel() ) 

    for _, item in ipairs(mods) do
        if item.bonemod then
            local bn = item.cfg["bone" .. suffix] or (pone and "LrigScull" or "ValveBiped.Bip01_Head1")
            local x = ent:LookupBone(bn)

            if x then
                if (item.configurable or {}).scale then
                    local scn = item.cfg["scale" .. suffix] or Vector(1, 1, 1.5)
                    AddScaleRecursive(ent, x, scn, item.cfg["scale_children" .. suffix], {})
                end

                if (item.configurable or {}).pos then
                    local psn = item.cfg["pos" .. suffix] or Vector(10, 0, 0)

                    --don't allow moving the root bone
                    if ent:GetBoneParent(x) == -1 then
                        psn.x = 0
                        psn.y = 0
                    end

                    local pso = ent:GetManipulateBonePosition(x)
                    pso = pso + psn
                    ent:ManipulateBonePosition(x, pso)
                end
            end
        end
    end

    --clamp the amount of stacking
    for x = 0, (ent:GetBoneCount() - 1) do
        local old = ent:GetManipulateBoneScale(x)
        local mn = 0.125 --0.5*0.5*0.5
        local mx = 3.375 --1.5*1.5*1.5

        if ent.GetNetData and ent:GetNetData('OF') ~= nil then
            mx = 1.5
        end

        old.x = math.Clamp(old.x, mn, mx)
        old.y = math.Clamp(old.y, mn, mx)
        old.z = math.Clamp(old.z, mn, mx)
        ent:ManipulateBoneScale(x, old)
        old = ent:GetManipulateBonePosition(x)
        old.x = math.Clamp(old.x, -8, 8)
        old.y = math.Clamp(old.y, -8, 8)
        old.z = math.Clamp(old.z, -8, 8)
        ent:ManipulateBonePosition(x, old)
    end
end

function SS_ApplyMaterialMods(ent, ply)
    local mods = ply:SS_GetActivePlayermodelMods()
    -- print("RESET", ent)
    ent:SetSubMaterial()
    hook.Run("SetPlayerModelMaterials", ent, ply)
    if HumanTeamName then return end

    for _, item in ipairs(mods) do
        if item.materialmod then
            local col = item.cfg.color or Vector(1, 1, 1)

            -- local mat = ImgurMaterial({
            --     id = (item.cfg.imgur or {}).url or "EG84dgp.png",
            --     owner = ent,
            --     worksafe = true, 
            --     pos = IsValid(ent) and ent:IsPlayer() and ent:GetPos(),
            --     stretch = true,
            --     shader = "VertexLitGeneric",
            --     params = string.format('{["$color2"]="[%f %f %f]"}', col.x, col.y, col.z)
            -- })
            ent:SetWebSubMaterial(item.cfg.submaterial or 0, {
                id = (item.cfg.imgur or {}).url or "EG84dgp.png",
                owner = ent,
                -- worksafe = true, -- pos = IsValid(ent) and ent:IsPlayer() and ent:GetPos(),
                stretch = true,
                shader = "VertexLitGeneric",
                params = string.format('{["$color2"]="[%f %f %f]"}', col.x, col.y, col.z)
            })
        end
    end
end

-- Entity.SS_True_LookupAttachment = Entity.SS_True_LookupAttachment or Entity.LookupAttachment
-- Entity.SS_True_LookupBone = Entity.SS_True_LookupBone or Entity.LookupBone
-- function Entity:LookupAttachment(id)
--     local mdl = EntityGetModel(self)
--     if self.LookupAttachmentCacheModel ~= mdl then
--         self.LookupAttachmentCache={}
--     end
--     if not self.LookupAttachmentCache[id] then self.LookupAttachmentCache[id] = Entity.SS_True_LookupAttachment(self, id) end
--     return self.LookupAttachmentCache[id]
-- end
-- function Entity:LookupBone(id)
--     local mdl = EntityGetModel(self)
--     if self.LookupBoneCacheModel ~= mdl then
--         self.LookupBoneCache={}
--     end
--     if not self.LookupBoneCache[id] then self.LookupBoneCache[id] = Entity.SS_True_LookupBone(self, id) end
--     return self.LookupBoneCache[id]
-- end
-- function SWITCHH()
--     Entity.LookupAttachment = Entity.SS_True_LookupAttachment
--     Entity.LookupBone = Entity.SS_True_LookupBone
-- end
--TODO: add "defaultcfg" as a standard field in items rather than this hack!
--TODO this is lag causin
-- function SS_GetItemWorldPos(item, ent)
--     local pone = isPonyModel(EntityGetModel(ent))
--     local attach, translate, rotate, scale = item:AccessoryTransform(pone)
--     local pos, ang
--     if attach == "eyes" then
--         local attach_id = ent:LookupAttachment("eyes")
--         if attach_id then
--             local attacht = ent:GetAttachment(attach_id)
--             if attacht then
--                 pos = attacht.Pos
--                 ang = attacht.Ang
--             end
--         end
--     else
--         local bone_id = ent:LookupBone(SS_Attachments[attach][pone and 2 or 1])
--         if bone_id then
--             pos, ang = ent:GetBonePosition(bone_id)
--         end
--     end
--     if not pos then return end
--     pos, ang = LocalToWorld(translate, rotate, pos, ang)
--     return pos, ang
-- end
-- function SS_DrawWornCSModel(item, mdl, ent)
--     local pos, ang = SS_GetItemWorldPos(item, ent)
--     mdl:Refresh()
--     -- local pone = isPonyModel(EntityGetModel(ent))
--     -- local attach, translate, rotate, scale = item:AccessoryTransform(pone)
--     -- local pos, ang
--     -- if attach == "eyes" then
--     --     local fn = FrameNumber()
--     --     if ent.attachcacheframe ~= fn then
--     --         ent.attachcacheframe = fn
--     --         local attach_id = ent:LookupAttachment("eyes")
--     --         if attach_id then
--     --             local attacht = ent:GetAttachment(attach_id)
--     --             if attacht then
--     --                 ent.attachcache = attacht
--     --                 pos = attacht.Pos
--     --                 ang = attacht.Ang
--     --             end
--     --         end
--     --     else
--     --         local attacht = ent.attachcache
--     --         if attacht then
--     --             pos = attacht.Pos
--     --             ang = attacht.Ang
--     --         end
--     --     end
--     -- else
--     --     local bone_id = ent:LookupBone(SS_Attachments[attach][pone and 2 or 1])
--     --     if bone_id then
--     --         pos, ang = ent:GetBonePosition(bone_id)
--     --     end
--     -- end
--     -- if not pos then
--     --     pos = ent:GetPos()
--     --     ang = ent:GetAngles()
--     -- end
--     -- pos, ang = LocalToWorld(translate, rotate, pos, ang)
--     print("DRAW",mdl:GetModel(),pos)
--     -- mdl:SetParent()
--     mdl:SetPos(pos)
--     mdl:SetAngles(ang)
--     mdl:SetupBones()
--     -- local bone_id = ent:LookupBone(SS_Attachments[attach][pone and 2 or 1])
--     -- -- if attach=="eyes" then
--     -- -- --     mdl:SetParent(ent, ent:LookupAttachment("eyes"))
--     -- if bone_id then
--     --     print(ent, bone_id)
--     --     mdl:FollowBone(ent, bone_id)
--     --     mdl:SetLocalPos(translate)
--     --     mdl:SetLocalAngles(rotate)
--     -- end
--     -- SS_PreRender(item)
--     DrawingInShop = true
--     mdl:DrawModel()
--     DrawingInShop = false
--     -- SS_PostRender()
-- end 
--NOMINIFY
-- hook.Add("DrawOpaqueAccessories", 'SS_DrawPlayerAccessories', function(ply)
-- --makes a CSModel for a worn item
-- function SS_CreateWornCSModel(item)
--     if item.wear == nil then return end
--     local mdl = SS_CreateCSModel(item)
--     mdl.Refresh = function(e)
--         if scale ~= e.appliedscale then
--             e.matrix = isnumber(scale) and Matrix({
--                 {scale, 0, 0, 0},
--                 {0, scale, 0, 0},
--                 {0, 0, scale, 0},
--                 {0, 0, 0, 1}
--             }) or Matrix({
--                 {scale.x, 0, 0, 0},
--                 {0, scale.y, 0, 0},
--                 {0, 0, scale.z, 0},
--                 {0, 0, 0, 1}
--             })
--             -- TODO: do we need to adjust renderbounds?
--             e:EnableMatrix("RenderMultiply", e.matrix)
--             e.appliedscale = scale
--         end
--     end
--     return mdl
-- end
local DrawingInShop = false

function SS_SetMaterialToItem(item, ent, ply)
    local col = (item.GetColor and item:GetColor()) or item.cfg.color or item.color or Vector(1, 1, 1)

    if item.cfg.imgur then
        ent:SetWebMaterial({
            id = item.cfg.imgur.url,
            owner = ply,
            forceload = SS_FORCE_LOAD_WEBMATERIAL,
            -- worksafe=true,
            params = [[{["$alphatest"]=1,["$color2"]="[]] .. tostring(col) .. [[]"}]]
        })
        --     ent.RenderOverride = function(e, fl)
        --         SS_PreRender(item)
        --         e:DrawModel()
        --         SS_PostRender()
        --     end
    else
        if col.x ~= 1 or col.y ~= 1 or col.z ~= 1 then
            ent:SetColoredBaseMaterial(col)
        end
    end
end

--makes a CSModel for a product or item
function SS_AttachAccessory(item, ent, recycle_mdl)
    -- local ply = item.owner == SS_SAMPLE_ITEM_OWNER and LocalPlayer() or item.owner
    -- mdl.Attach = function(e, ent)
    --     ent = ent or ply
    -- if not IsValid(e:GetParent()) or e.lastent ~= ent then
    --     e.appliedmodel = nil
    --     e.lastent = ent
    -- end
    local mdl

    if recycle_mdl then
        mdl = recycle_mdl
        assert(item:GetModel() == mdl:GetModel())
    else
        mdl = ClientsideModel(item:GetModel(), RENDERGROUP_OPAQUE)
    end

    mdl.item = item
    local pone = isPonyModel(EntityGetModel(ent))
    local attach, translate, rotate, scale = item:AccessoryTransform(pone)

    if attach == "eyes" then
        local attach_id = ent:LookupAttachment("eyes")

        if attach_id < 1 then
            mdl:Remove()

            return
        end

        mdl:SetParent(ent, attach_id)
        mdl._FollowedBone = nil
    else
        local bone_id = ent:LookupBone(SS_Attachments[attach][pone and 2 or 1])

        if not bone_id then
            mdl:Remove()

            return
        end

        mdl:FollowBone(ent, bone_id)
        mdl._FollowedBone = bone_id
    end

    -- mdl:SetPredictable(true)
    -- if scale ~= e.appliedscale then
    mdl.matrix = isnumber(scale) and Matrix({
        {scale, 0, 0, 0},
        {0, scale, 0, 0},
        {0, 0, scale, 0},
        {0, 0, 0, 1}
    }) or Matrix({
        {scale.x, 0, 0, 0},
        {0, scale.y, 0, 0},
        {0, 0, scale.z, 0},
        {0, 0, 0, 1}
    })

    -- TODO: do we need to adjust renderbounds?
    mdl:EnableMatrix("RenderMultiply", mdl.matrix)
    -- e.appliedscale = scale
    -- end
    --this likes to change itself
    mdl:SetLocalPos(translate)
    mdl:SetLocalAngles(rotate)
    -- if item.cfg.imgur then
    --     local imat = ImgurMaterial({
    --         id = item.cfg.imgur.url,
    --         owner = item.owner,
    --         worksafe = true,
    --         pos = IsValid(item.owner) and item.owner:IsPlayer() and item.owner:GetPos(),
    --         stretch = true,
    --         shader = "VertexLitGeneric",
    --         params = [[{["$alphatest"]=1}]]
    --     })
    --     render.MaterialOverride(imat)
    --     --render.OverrideDepthEnable(true,true)
    -- else
    --     local mat = item.cfg.material or item.material
    --     if mat then
    --         render.MaterialOverride(SS_GetMaterial(mat))
    --     else
    --         render.MaterialOverride()
    --     end
    -- end
    -- local col = (item.GetColor and item:GetColor()) or item.cfg.color or item.color
    -- if item.cfg.imgur then
    --     mdl:SetImgurMaterial(item.cfg.imgur.url)
    -- end
    -- if IsValid(LocalPlayer()) and LocalPlayer():GetName()=="Joker Gaming" then
    --     mdl:SetColoredBaseMaterial(Vector(1,0,0)) 
    -- else
    SS_SetMaterialToItem(item, mdl, item.owner == SS_SAMPLE_ITEM_OWNER and LocalPlayer() or item.owner)
    -- end

    return mdl
end

function Player:SS_GetActivePlayermodelMods()
    local mods = {}

    for k, item in pairs(self.SS_ShownItems or {}) do
        if item.playermodelmod then
            table.insert(mods, item)
        end
    end

    return mods
end

-- Revise if we add translucent accessories
hook.Add("PreDrawOpaqueRenderables", "SS_DrawLocalPlayerAccessories", function()
    local ply = LocalPlayer()

    if IsValid(ply) and ply:Alive() then
        ply:SS_AttachAccessories(ply.SS_ShownItems)
        local d = ply:ShouldDrawLocalPlayer()

        for i, v in ipairs(SS_CreatedAccessories[ply] or {}) do
            -- Setting this on and off during same frame doesn't work
            v:SetNoDraw(true)

            if d then
                v:DrawModel()
            end
        end
    end
end)

-- It seems like the ragdoll is created before the cleanup, so this is ok
hook.Add('CreateClientsideRagdoll', 'SS_CreateClientsideRagdoll', function(ply, rag)
    if IsValid(ply) and ply:IsPlayer() then
        local counter = 0

        for k, mdl in pairs(SS_CreatedAccessories[ply] or {}) do
            counter = counter + 1
            if counter > 10 then return end
            local gib = GibClientProp(mdl:GetModel(), mdl:GetPos(), mdl:GetAngles(), ply:GetVelocity(), 1, 6)

            if mdl.matrix then
                gib:EnableMatrix("RenderMultiply", mdl.matrix)
            end

            local item = mdl.item
            SS_SetMaterialToItem(item, gib, ply)
        end

        -- used by pony model TODO remove
        rag.RagdollSourcePlayer = ply
        SS_ApplyMaterialMods(rag, ply)
    end
end)

for k, v in pairs(SS_CreatedAccessories or {}) do
    if IsValid(k) then
        k:SS_AttachAccessories()
    end
end

for i, v in ipairs(player.GetAll()) do
    v.SS_SetupPlayermodel = nil
end

SS_CreatedAccessories = {}
SS_UpdatedAccessories = {}

hook.Add("NetworkEntityCreated", "RefreshAccessories", function(ent)
    ent.SS_AttachedModel = nil
end)

-- Note: we expect items table not to change internally when items are updated (make whole new table)
function Entity:SS_AttachAccessories(items)
    -- print(items, rangecheck)
    SS_UpdatedAccessories[self] = true
    local m = self:GetActualModel()
    -- they sometimes go NULL when in/out of vehicle
    local iv = self:IsPlayer() and self:InVehicle()
    local current = SS_CreatedAccessories[self]
    -- slow, havent found better way
    -- if CurTime() > (self.SS_DetachCheckTime or 0) then
    --     print("CHE")
    --     if current and IsValid(current[1]) and not IsValid(current[1]:GetParent()) then self.SS_AttachedModel=nil print("F") end
    --     self.SS_DetachCheckTime = CurTime() + math.Rand(1,2)
    -- end
    if self.SS_AttachedModel == m and self.SS_AttachedInVehicle == iv and self.SS_AttachedItems == items then return end
    -- if self.SS_AttachedModel == m and self.SS_AttachedItems == items then return end
    self.SS_AttachedModel = m
    self.SS_AttachedInVehicle = iv
    self.SS_AttachedItems = items
    local recycle = defaultdict(function() return {} end)

    if current then
        for i, v in ipairs(current) do
            table.insert(recycle[v:GetModel()], v)
        end
    end

    if items then
        SS_CreatedAccessories[self] = {}

        for i, item in ipairs(items) do
            if item.AccessoryTransform then
                local rmodels = recycle[item:GetModel()]
                local mdl = SS_AttachAccessory(item, self, #rmodels > 0 and table.remove(rmodels) or nil)

                if mdl then
                    table.insert(SS_CreatedAccessories[self], mdl)
                end
            end
        end
    else
        SS_CreatedAccessories[self] = nil
    end

    for m, mt in pairs(recycle) do
        for i, v in ipairs(mt) do
            v:Remove()
        end
    end
end

hook.Add("Think", "SS_CleanupAccessories", function()
    for ent, mdls in pairs(SS_CreatedAccessories) do
        if not SS_UpdatedAccessories[ent] then
            for i, mdl in ipairs(mdls) do
                mdl:Remove()
            end

            SS_CreatedAccessories[ent] = nil

            if IsValid(ent) then
                ent.SS_AttachedItems = nil
            end
        end
    end

    SS_UpdatedAccessories = {}
end)

CLONEDMATERIALS = CLONEDMATERIALS or {}

function Entity:SetColoredBaseMaterial(color)
    MATERIALCLONEINDEX = (MATERIALCLONEINDEX or 0) + 1
    local sc = "c" .. tostring(color):gsub("%.", "p"):gsub(" ", "_")
    self:SetMaterial()
    self:SetSubMaterial()
    local mats = self:GetMaterials()

    for i, mat in ipairs(mats) do
        local clonekey = sc .. "/../" .. mat

        if not CLONEDMATERIALS[clonekey] then
            -- print("MAKE", clonekey)
            -- mat = mat:gsub("'","")
            local mat2 = Material(clonekey)
            local matname = mat2:GetName()

            if matname == "___error" then
                -- print("INVALID MATERIAL", mat)
                local data = file.Read("materials/" .. mat .. ".vmt", "GAME") or "vertexlitgeneric\n{\n}"
                local fixdata = data:Trim():lower()

                if not (fixdata:StartWith("vertexlitgeneric") or fixdata:StartWith("'vertexlitgeneric") or fixdata:StartWith("\"vertexlitgeneric")) then
                    print("WARNING, WRONG SHADER ON BAD MATERIAL")
                    print(mat, data)
                elseif fixdata:find("proxies") then
                    print("WARNING, PROXIES ON BAD MATERIAL")
                    print(mat, data)
                end

                mat2 = CreateMaterial("clonedmaterial" .. MATERIALCLONEINDEX .. "and" .. i, "vertexlitgeneric", util.KeyValuesToTable(data))
                --     mat2 = PPM_CLONE_MATERIAL(Material(mat), mat .. sc )
                --     print("FIXED", mat2:GetName())
                -- mat2 = Material(mat.."/"..MATERIALCLONEINDEX.."/../../"..table.remove( ("/"):Explode(mat) ) )
                -- print(mat2:GetName(), mat.."/"..MATERIALCLONEINDEX.."/../../"..table.remove( ("/"):Explode(mat) ) )
                matname = "!" .. mat2:GetName()
            end

            mat2:SetVector("$color2", color * mat2:GetVector("$color2"))
            CLONEDMATERIALS[clonekey] = matname
        end

        self:SetSubMaterial(i - 1, CLONEDMATERIALS[clonekey])
        -- print(i, mat)
        -- local mi = i - 1
        -- local mn = mat .. sc -- "coloredbase"..emi.."s"..mi
        -- local clone = PPM_CLONE_MATERIAL(Material(mat), mn)
        -- clone:SetVector("$color2", color)
        -- self:SetSubMaterial(mi, "!" .. mn)
    end
end
