


--How much time is the mesh generator allowed to add to the current frametime before it's finished until next frame
WARMAPMESH_GEN_TIMEBUDGET = 1/600

if (SERVER) then return end
local map = Location.Map
local color_bg = NamedColor("BgColor")
local color_fg = NamedColor("FgColor")

local ignore = {
    ["Unknown"] = true,
    ["Outside"] = true,
    ["Potassium Palace"] = true,
    ["Moon"] = true,
    ["Attic"] = true,
    ["SushiTheater Basement"] = true,
    ["Moon Base"] = true,
    ["Deep Space"] = true,
    ["Void"] = true,
    ["The Box"] = true,
    ["The Underworld"] = true,
    ["Void"] = true,
    ["In Minecraft"] = true,
    ["Labyrinth"] = true,
    ["Strange Asian Hole"] = true,
    ["Auditorium"] = true,
    ["Temple of Kek"] = true,
}

local texignore = {
    ["tools/toolsblackmud"] = true,
    ["tools/toolsnodraw"] = true,
    ["swamponions/slime"] = true,
    ["swamponions/swampscum"] = true,
    ["liquid"] = true,
    ["water"] = true,
}

local terr = {}

local nofloor = {
    ["Sewer Tunnels"] = true,
    ["Trumppenbunker"] = true,
    ["Kleiner's Lab"] = true,
}

local shitty = {
    ["Way Outside"] = true,
    ["Outside"] = true,
    ["AFK Corral"] = true,
}

--WARHUD_ZOOM = 2000
local function SurfaceNormal(surf)
    local am = 0
    local nrm = Vector()
    local verts = surf:GetVertices()

    for k, v in pairs(verts) do
        am = am + 1
        local vprev = (verts[k + 1] or verts[1])
        local vnext = (verts[k - 1] or verts[#verts])
        local normal = ((vnext - v):GetNormalized()):AngleEx((vprev - v):GetNormalized()):Right()
        nrm = nrm + normal
        debugoverlay.Line(v, v + normal * 16, 1, Color(0, 255, 255), true)
    end

    nrm:Normalize()

    return nrm
end

local function SurfaceAverage(surf)
    local am = 0
    local pos = Vector()
    local verts = surf:GetVertices()

    for k, v in pairs(verts) do
        am = am + 1
        pos = pos + v
    end

    pos = pos / am
    local loc = Location.Find(pos) or -1
    local locname = Location.GetLocationNameByIndex(loc)

    if (loc == 0 or shitty[locname]) then
        loc = Location.FindNear(cent)
        locname = Location.GetLocationNameByIndex(loc)
    end

    for k, v in pairs(verts) do
        debugoverlay.Line(v, pos, 1, Color(0, 255, 0), true)
        debugoverlay.Line(verts[k + 1] or verts[1], v, 1, Color(255, 0, 255), true)
    end
    --debugoverlay.Text( pos, surf:GetMaterial():GetName(), 0.02)

    return pos
end

WARMAP_MAXMESHSIZE = 30000

local function SurfToGeom(surf, tb, loc)
    local count = 1
    local verts = surf:GetVertices()
    local itb = 1
    tb[itb] = tb[itb] or {}
    local ttb = tb[itb]

    while #tb[itb] > WARMAP_MAXMESHSIZE do
        itb = itb + 1
        tb[itb] = tb[itb] or {}
        ttb = tb[itb]
    end

    for i = 3, #verts do
        if (verts[i]) then
            count = count + 1
            table.insert(ttb, verts[1])
            table.insert(ttb, verts[i - 1])
            table.insert(ttb, verts[i])
        end
    end

    return count
end

local function floorverts(loc)
    --if(true)then return {} end
    local locd = Location.GetLocations()[loc]
    if (locd == nil or locd.Min == nil or locd.Max == nil) then return {} end
    if (nofloor[locd.Name]) then return {} end
    local mins = locd.Min
    local z = mins.z
    z = z - 32
    local maxs = locd.Max
    local v1 = Vector(mins.x, mins.y, z)
    local v2 = Vector(mins.x, maxs.y, z)
    local v3 = Vector(maxs.x, maxs.y, z)
    local v4 = Vector(maxs.x, mins.y, z)

    return {v1, v2, v3, v1, v3, v4}
end

local fat = Vector(32, 32, 128)

function Location.FindNear(ply)
    local pos = isvector(ply) and ply or isentity(ply) and ply:GetPos()
    if (Map == nil) then return 0 end
    local found
    local size

    for k, v in next, Map do
        if (pos:InBox(v.Min + Vector(1, 1, 1) * -fat, v.Max + Vector(1, 1, 1) * fat) and (size == nil or v.Min:Distance(v.Max) < size)) then
            if v.Filter then
                if v.Filter(pos) then
                    found = k
                end
            else
                found = k
            end

            size = v.Min:Distance(v.Max)
        end
    end

    return found or 0
end

function WARMAP_REGEN(cor)
    WARMAP_GENERATING = true
    if (MAPMESHES) then
        for k, v in pairs(MAPMESHES) do
            if (istable(v)) then
                for k, msh in pairs(v) do
                    msh:Destroy()
                end
            end
        end

        MAPMESHES = nil
    end

    local work = 0
    local iters = 0
    MAPMESHES = {}
    local world = game.GetWorld()
    local MAPMESHES_DAT = {}
    local surfs = table.Copy(world:GetBrushSurfaces())

    for k, surf in pairs(surfs) do
        if (surf:IsNoDraw()) then continue end
        if (surf:IsSky()) then continue end
        if (surf:IsWater()) then continue end
        if (texignore[surf:GetMaterial():GetName()]) then continue end
        local found = false

        for k, v in pairs(texignore) do
            if (string.find(string.lower(surf:GetMaterial():GetName()), string.lower(k))) then
                found = true
                break
            end
        end

        if (found) then continue end
        local cent = SurfaceAverage(surf) + SurfaceNormal(surf) * 1
        local loc = Location.Find(cent) or -1
        local locname = Location.GetLocationNameByIndex(loc)

        if (loc == 0 or shitty[locname]) then
            loc = Location.FindNear(cent)
            locname = Location.GetLocationNameByIndex(loc)
        end

        --loc = GetLocTerritory(loc) or loc
        --if (loc == 0 or locname == "Outside") then continue end
        if (ignore[locname]) then continue end

        --if( GetLocTerritory(loc) == nil)then continue end
        if (loc) then
            MAPMESHES_DAT[loc] = MAPMESHES_DAT[loc] or {
                verts = {floorverts(loc)},
                loc = loc,
                tricount = 0
            }

            local tri = SurfToGeom(surf, MAPMESHES_DAT[loc].verts, loc)
        end

        if (not cor) then

            if (WARMAP_LASTTIMEQUERY) then
                iters = iters + 1
                work = work + (os.clock() - WARMAP_LASTTIMEQUERY)
                WARMAP_LASTTIMEQUERY = os.clock()
            else
                iters = iters + 1
                WARMAP_LASTTIMEQUERY = os.clock()
            end

            if (work >= WARMAPMESH_GEN_TIMEBUDGET) then
                WARMAP_GEN_PERCENT = k / #surfs
                print("CAPPING WORK.. MANAGED "..iters.." ITERS",math.Round(WARMAP_GEN_PERCENT * 100,1).."%")
                iters = 0
                work = 0
                coroutine.yield()
                WARMAP_LASTTIMEQUERY = nil
            end
        end
        
    end
    WARMAP_GENERATING = nil
    print("DONE! "..iters.." ITERS",math.Round(WARMAP_GEN_PERCENT * 100,1).."%")
    WARMAP_GEN_PERCENT = nil


    --if(true)then return end
    for k, dat in pairs(MAPMESHES_DAT) do
        MAPMESHES[k] = MAPMESHES[k] or {}
        local locd = Location.GetLocations()[dat.loc or 0]
        local top = locd and locd.Max and locd.Max.z or 2048
        local bottom = locd and locd.Min and locd.Min.z or 0
        top = top + fat.z
        bottom = bottom - fat.z

        for ind, verts in pairs(dat.verts) do
            local color = Color(255, 255, 255) --HSVToColor(180+math.NormalizeAngle(-180 + ind*30),1,1)
            MAPMESHES[k][ind] = MAPMESHES[k][ind] or Mesh()
            mesh.Begin(MAPMESHES[k][ind], MATERIAL_TRIANGLES, #verts / 3)

            for k, vert in pairs(verts) do
                --if(vert.z >= 950)then vert.z = 4096 end
                local alpha = math.Remap(math.Clamp(vert.z, bottom, top), bottom, top, 150, 255)
                mesh.Position(vert) -- Set the position
                mesh.TexCoord(0, 0, 0) -- Set the texture UV coordinates
                mesh.Color(alpha, alpha, alpha, 255)
                mesh.AdvanceVertex() -- Write the vertex
            end

            mesh.End()
        end
    end
end

    if (not MAPMESHES) then
        WARMAP_REGEN()
    end

    concommand.Add("warmapmesh", function()
        MAPGEN_ROUT = coroutine.create(WARMAP_REGEN)
    end)

    concommand.Add("warmapmesh2", function()
        WARMAP_REGEN(1)
    end)

    hook.Add("Think", "mapgen", function()
        if (MAPGEN_ROUT) then
            coroutine.resume(MAPGEN_ROUT)
        end
    end)

    local wire = Material("editor/wireframe") -- The material (a wireframe)
    local color = Material("color")

    local map_flat = CreateMaterial("warhud_flat", "VertexLitGeneric", {
        ["$basetexture"] = "color/white",
        ["$model"] = 1,
    })

    local map_holo = CreateMaterial("warhud_holo1", "UnlitGeneric", {
        ["$basetexture"] = "color/white",
        ["$model"] = 1,
        ["$additive"] = 0,
        ["$translucent"] = 1,
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1,
        ["$nocull"] = 1,
    })

    local map_holo_fade = CreateMaterial("warhud_holo_fade1", "UnlitGeneric", {
        ["$basetexture"] = "color/white",
        ["$model"] = 1,
        ["$additive"] = 0,
        ["$translucent"] = 1,
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1,
        ["$nocull"] = 1,
    })

    CC = nil

    local function shoulddrawloc(loc)
        local dat = Location.GetLocations()[loc]
        if (not dat) then return false end
        if ((dat.Underground or false) ~= (LocalPlayer():IsUnderground())) then return false end

        return true
    end

    local function DrawMeshes(black)
        if (not MAPMESHES) then return end
        render.SetBlend(1)
        render.SetMaterial(map_holo)

        for loc, batch in pairs(MAPMESHES) do
            if (not shoulddrawloc(loc)) then continue end
            local territory = Location.GetTerritory(loc)
            local clr = War.GetTerritoryColor(territory)
            local mat = map_holo
            mat:SetVector("$color2", black and Vector() or clr:ToVector())
            render.SetMaterial(mat)

            for mshid, msh in pairs(batch) do
                if (IsValid(msh)) then
                    msh:Draw()
                end
            end
        end
    end

    hook.Add("PostDrawOpaqueRenderables", "testytest", function(depth, sky) end) --DrawMeshes()
    local rnames = "warmap_rt"
    WARHUD_MAP_TEXW = 1024
    WARHUD_MAP_TEXH = 512
    WARHUD_OVERLAY_TEXS = 512
    WARHUD_OVERLAY_WORLDSIZE = 6800
    WARHUD_OVERLAY_WORLDCENTER = Vector(96, 1200, 0)
    WARMAP_MAPRT = GetRenderTargetEx(rnames, WARHUD_MAP_TEXW, WARHUD_MAP_TEXH, RT_SIZE_LITERAL, MATERIAL_RT_DEPTH_SEPARATE, 12 + 2, 0, IMAGE_FORMAT_RGBA8888)
    WARMAP_MAPRT_GLOW = GetRenderTargetEx(rnames .. "_glow", WARHUD_MAP_TEXW, WARHUD_MAP_TEXH, RT_SIZE_LITERAL, MATERIAL_RT_DEPTH_SEPARATE, 12 + 2, 0, IMAGE_FORMAT_RGBA8888)
    WARMAP_MAPRT_OVERLAY = GetRenderTargetEx(rnames .. "_overlay", WARHUD_OVERLAY_TEXS, WARHUD_OVERLAY_TEXS, RT_SIZE_LITERAL, MATERIAL_RT_DEPTH_SEPARATE, 12 + 2, 0, IMAGE_FORMAT_RGB888)
    local maprt = WARMAP_MAPRT
    local maprt_glow = WARMAP_MAPRT_GLOW
    local maprt_overlay = WARMAP_MAPRT_OVERLAY

    local maprtmat = CreateMaterial(rnames .. "_mat", "UnlitGeneric", {
        ["$basetexture"] = maprt:GetName(), -- You can use "example_rt" as well
        ["$translucent"] = 1,
        ["$additive"] = 1,
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1
    })

    local maprtmat_glow = CreateMaterial(rnames .. "_glow_mat", "UnlitGeneric", {
        ["$basetexture"] = maprt_glow:GetName(), -- You can use "example_rt" as well
        ["$translucent"] = 1,
        ["$additive"] = 1,
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1
    })

    local maprtmat_overlay = CreateMaterial(rnames .. "_mat_overlay", "UnlitGeneric", {
        ["$basetexture"] = maprt_overlay:GetName(), -- You can use "example_rt" as well
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1
    })

    local maprtmat_clean = CreateMaterial(rnames .. "_fade_mat", "UnlitGeneric", {
        ["$basetexture"] = "color/white", -- You can use "example_rt" as well
        ["$translucent"] = 1,
        ["$color"] = Vector(0, 322, 0),
        ["$alpha"] = 1,
    })

    hook.Remove("PostDrawTranslucentRenderables", "Render3DWarMap")

    local OVERLAY_TREATMENT = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0.2,
        ["$pp_colour_contrast"] = 0.6,
        ["$pp_colour_colour"] = 0,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    local GLOW_TREATMENT = {
        ["$pp_colour_addr"] = -0.3,
        ["$pp_colour_addg"] = -0.3,
        ["$pp_colour_addb"] = -0.3,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1.5,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    if(CLIENT)then
        surface.CreateFont( "WarMap", {
            font = "Bebas Neue", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
            extended = false,
            size = 24,
            weight = 500,
            blursize = 0,
            scanlines = 0,
            antialias = true,
            underline = false,
            italic = false,
            strikeout = false,
            symbol = false,
            rotary = false,
            shadow = false,
            additive = false,
            outline = false,
        } )
    end

    WARHUD_CX = ScrW() / 2
    WARHUD_Y = 16
    WARHUD_MAP_W = 512
    WARHUD_MAP_H = 256
    WARHUD_ZOOM_DEF = 7000
    WARHUD_ZOOM_UND = 4000
    WARHUD_ZOOM_DEF = 7000
    WARHUD_ZOOM_UND = 7000
    WARHUD_ZOOM = WARHUD_ZOOM or WARHUD_ZOOM_DEF
    WARMAP_OUTLINETHICK = WARHUD_ZOOM / 100
    local refresh = true
    WARMAP_DOING_OVERLAY = nil
    hook.Remove("RenderScreenspaceEffects", "Render3DWarMap")

    --if(true)then return end
    hook.Add("RenderScreenspaceEffects", "Render3DWarMap", function()
        local und = LocalPlayer():IsUnderground()
        local plypos = LocalPlayer():GetPos()
        local w, h = WARHUD_MAP_W, WARHUD_MAP_H
        local orh = WARHUD_ZOOM
        local orv = WARHUD_ZOOM * (h / w)
        local ang = LocalPlayer():EyeAngles()

        local truecenter = WARHUD_OVERLAY_WORLDCENTER
        local len = plypos:Distance(truecenter)
        
        local dir = ((truecenter-plypos)*Vector(1,1,0)):GetNormalized()
        dir = LerpVector(math.Clamp(len/2000,0,1),Vector(0,0,-1),dir):GetNormalized()

        ang = (dir):Angle() 
        ang.pitch = 90 - math.Clamp(len/1000,0,1)*60
       
        local center = truecenter + (plypos / 4)
        center.z = 0

        --ang = Angle(50, ang.yaw)
        --ang.pitch = ang.pitch + 30
        ang.pitch = math.Clamp(ang.pitch,-89,89)

        center = center + ang:Forward() * -3000

        
        local pos = center

        WARHUD_ZOOM = math.Approach(WARHUD_ZOOM, und and WARHUD_ZOOM_UND or WARHUD_ZOOM_DEF, FrameTime() * 1500)
        WARMAP_OUTLINETHICK = WARHUD_ZOOM / 100

        WARHUD_RENDERPOS = pos
        WARHUD_RENDERANGLES = ang
        local oldw, oldh = ScrW() * 1, ScrH() * 1
        local oldRT = render.GetRenderTarget()
        local tw, th = WARHUD_MAP_TEXW, WARHUD_MAP_TEXH
        local OLS = WARHUD_OVERLAY_WORLDSIZE

        if (refresh and not WARMAP_DOING_OVERLAY) then
            WARMAP_DOING_OVERLAY = true
            render.SetRenderTarget(maprt_overlay)
            cam.Start2D()
            render.SetViewPort(0, 0, OLS, OLS)

            render.RenderView({
                origin = WARHUD_OVERLAY_WORLDCENTER + Vector(0, 0, 1024),
                angles = Angle(90, 90),
                x = 0,
                y = 0,
                zfar = 1280,
                w = WARHUD_OVERLAY_TEXS,
                h = WARHUD_OVERLAY_TEXS,
                ortho = {
                    left = -OLS / 2,
                    right = OLS / 2,
                    top = -OLS / 2,
                    bottom = OLS / 2,
                },
                dopostprocess = false,
                drawviewmodel = false,
                drawmonitors = false,
            })

            DrawColorModify(OVERLAY_TREATMENT)
            cam.End2D()
            render.SetViewPort(0, 0, oldw, oldh)
            WARMAP_DOING_OVERLAY = nil
            refresh = nil
        end

        render.ClearRenderTarget(maprt, Color(0, 0, 0, 255))
        render.ClearRenderTarget(maprt_glow, Color(0, 0, 0, 255))
        render.OverrideDepthEnable(true, true)
        render.OverrideAlphaWriteEnable(true, true)
        render.SetViewPort(0, 0, tw, th)
        -- In first RT:
        render.SetRenderTarget(maprt)
        render.ClearDepth()
        cam.Start2D()
        cam.Start3D(pos, ang, 40)
        render.SetViewPort(0, 0, tw, th)
        render.ClearDepth()
        cam.StartOrthoView(-orh, orv, orh, -orv)

        if (not und) then
            render.SetMaterial(maprtmat_overlay)
            render.DrawQuadEasy(WARHUD_OVERLAY_WORLDCENTER + Vector(0, 0, -50), Vector(0, 0, 1), OLS, OLS, Color(200, 200, 200), 90)
        end

        render.ClearDepth()
        DrawMeshes()
        render.ClearDepth()

        for k, v in pairs(Ents["player"]) do
            if (not v:Alive()) then continue end
            --if(War.GetTerritoryOwner(v:GetTerritory()) != LocalPlayer():Team() and LocalPlayer():GetLocation() != v:GetLocation())then continue end
            local pmins, pmaxs = v:GetCollisionBounds()
            pmins = pmins * 2
            pmaxs = pmaxs * 2
            local wall = WARHUD_ZOOM / 150
            render.SetMaterial(map_holo_fade)
            render.DrawBox(v:GetPos() + VectorRand() * 2, Angle(), pmins + Vector(1, 1, 1) * -wall, pmaxs + Vector(1, 1, 1) * wall, Color(0, 0, 0, 255))
            render.SetMaterial(map_holo)
            render.ClearDepth()
            local color = team.GetColor(v:Team()) or Color(255, 255, 255, 200)
            map_holo:SetVector("$color2", Vector(1, 1, 1))
            render.DrawBox(v:GetPos() + VectorRand() * 2, Angle(), pmins, pmaxs, color)
        end

        cam.EndOrthoView()
        cam.End3D()
        cam.End2D()

        render.SetViewPort(0, 0, oldw, oldh)
        surface.SetDrawColor(255, 255, 255, 255)
        render.SetColorMaterial()
        render.OverrideDepthEnable(false, true)

        if(WARMAP_GENERATING)then
            --render.BlurRenderTarget(maprt, 4, 4, 1)
            render.SetRenderTarget(maprt)
            local sw,sh = tw,th
            render.SetViewPort(0, 0, sw, sh)
            render.ClearDepth()
            cam.Start({
                type = "2D",
                x = 0,
                y = 0,
                w = sw,
                h = sh
            })
    
            local m = Matrix()
            local scl = 4
            --m:Scale(Vector(4,4,4))
        
            m:Scale(Vector(scl,scl,scl))
            m:Translate(Vector(sw*0.5 / scl,sh*0.5 /scl,0))
            
	        cam.PushModelMatrix( m )
            local clr = team.GetColor(LocalPlayer():Team())
            local pct = WARMAP_GEN_PERCENT
            
            

            local barx = 0
            local bary = 0
            local barw = 128
            local barh = 32
            local bars = pct 
            local barm = 4

            draw.RoundedBox( barm, barx - (barw / 2), bary - (barh/2), barw, barh, Color(0,0,0,255) )

            surface.SetDrawColor(clr)
            surface.DrawRect(barx - barw / 2 + barm, bary- (barh/2) + barm, (barw - (barm*2)) * bars, barh - (barm*2))

            draw.SimpleTextOutlined( "Scanning..."..math.Round(pct*100,0).."%", "WarMap", 0, 1, clr ,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(0,0,0))
            --draw.SimpleText( "Scanning..."..math.Round(pct*100,0).."%", "WarMap", 0, 0, clr ,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            

            cam.PopModelMatrix()


            cam.End2D()
            
            render.SetViewPort(0, 0, oldw, oldh)
           
            --render.BlurRenderTarget(maprt, 1, 1, 1)

        end


        render.CopyRenderTargetToTexture(maprt_glow)
        --render.BlurRenderTarget(maprt_glow,8,8,1)
        render.SetRenderTarget(maprt_glow)
        DrawColorModify(GLOW_TREATMENT)
        --render.SetViewPort(0,0,tw,th)
        render.BlurRenderTarget(maprt_glow, 1, 1, 4)

        --regular cam.Start2D seems to reset the viewport back to game window size
        cam.Start({
            type = "2D",
            x = 0,
            y = 0,
            w = tw,
            h = th
        })

        render.ClearDepth()
        local stp = 8
        local _, alt = math.modf(CurTime() * 15)
        alt = alt * stp * 2

        for y = 0, ScrH(), stp * 2 do
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(0, y + alt, ScrW(), stp)
        end

        cam.End2D()
        render.BlurRenderTarget(maprt_glow, 1, 1, 1)
        render.SetViewPort(0, 0, oldw, oldh)
        --draw glow on aberrated
        local gw, gh = ScrW(), ScrH()
        --print(gw,gh)
        render.SetRenderTarget(maprt)
        render.SetViewPort(0, 0, tw, th)

        cam.Start({
            type = "2D",
            x = 0,
            y = 0,
            w = tw,
            h = th
        })

        render.SetMaterial(maprtmat_glow)
        render.SetColorModulation(1, 1, 1)
        local offs = 4
        local glow = 8
        maprtmat_glow:SetVector("$color2", Vector(0, 1, 0) * glow)
        render.DrawScreenQuadEx(0, 0, gw, gh)
        maprtmat_glow:SetVector("$color2", Vector(1, 0, 0) * glow)
        render.DrawScreenQuadEx(0, -offs, gw, gh)
        maprtmat_glow:SetVector("$color2", Vector(0, 0, 1) * glow)
        render.DrawScreenQuadEx(0, offs, gw, gh)
        maprtmat_glow:SetFloat("$alpha", 1)
        cam.End2D()
        render.SetViewPort(0, 0, oldw, oldh)
        render.SetRenderTarget(oldRT)
        render.OverrideDepthEnable(false, false)
        render.OverrideAlphaWriteEnable(false, false)



    end)

    local BGREY = Color(32, 32, 32)

    hook.Add("HUDPaint", "WarHUD", function()
        local und = LocalPlayer():IsUnderground()
        local w, h = WARHUD_MAP_W, WARHUD_MAP_H
        local x, y = WARHUD_CX - (w / 2), WARHUD_Y
        local orh = WARHUD_ZOOM
        local orv = WARHUD_ZOOM * (h / w)
        surface.SetDrawColor(ColorAlpha(color_bg, 200))
        surface.DrawRect(x - 4, y - 4, w + 8, h + 8)
        surface.SetMaterial(maprtmat)
        maprtmat:SetFloat("$alpha", 1)
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.DrawTexturedRect(x, y, w, h)
        local ply = LocalPlayer()
        local barx = WARHUD_CX
        local bary = y + h + 8
        local barw = 128
        local barh = 8
        local terr = ply:GetTerritory()
        local barbc = BGREY
        local barfc = team.GetColor(ply:Team())
        local bars = 0

        if (terr) then
            if (War.GetTerritoryOwner(terr) == ply:Team()) then
                bars = War.GetTerritoryControlRatio(terr, ply:Team())
            else
                local owner = War.GetTerritoryOwner(terr)

                if (owner) then
                    bars = War.GetTerritoryControlRatio(terr, owner)
                    barfc = team.GetColor(owner)
                end
            end
        end

        surface.SetDrawColor(barbc)
        surface.DrawRect(barx - barw / 2, bary, barw * 1, barh)
        surface.SetDrawColor(barfc)
        surface.DrawRect(barx - barw / 2 + 1, bary + 1, (barw - 2) * bars, barh - 2)
    end)

    function draw.ScreenText(vec, text, scale, color)
        local angle = EyeAngles()
        angle:RotateAroundAxis(angle:Right(), 90)
        angle:RotateAroundAxis(angle:Up(), -90)
        local vec = vec * 1
        vec = vec + angle:Right() * -24 * scale
        vec = vec + angle:Forward() * -24 * scale
        cam.Start3D2D(vec, angle, scale)
        draw.SimpleText(text, "Trebuchet24", 24, 24, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end

    local function roundvec(v)
        v.x = math.Round(v.x, 0)
        v.y = math.Round(v.y, 0)
        v.z = math.Round(v.z, 0)
    end

    function render.DrawBoxEdges(mins, maxs, color)
        local c1 = Vector(maxs.x, maxs.y, maxs.z)
        local c2 = Vector(mins.x, maxs.y, maxs.z)
        local c3 = Vector(maxs.x, mins.y, maxs.z)
        local c4 = Vector(mins.x, mins.y, maxs.z)
        local c5 = Vector(maxs.x, maxs.y, mins.z)
        local c6 = Vector(mins.x, maxs.y, mins.z)
        local c7 = Vector(maxs.x, mins.y, mins.z)
        local c8 = Vector(mins.x, mins.y, mins.z)
        render.DrawLine(c1, c2, color, false)
        render.DrawLine(c3, c4, color, false)
        render.DrawLine(c1, c3, color, false)
        render.DrawLine(c2, c4, color, false)
        render.DrawLine(c5, c6, color, false)
        render.DrawLine(c7, c8, color, false)
        render.DrawLine(c5, c7, color, false)
        render.DrawLine(c6, c8, color, false)
        render.DrawLine(c1, c5, color, false)
        render.DrawLine(c2, c6, color, false)
        render.DrawLine(c3, c7, color, false)
        render.DrawLine(c4, c8, color, false)
    end

    wawa = nil

    hook.Add("PostDrawTranslucentRenderables", "Baba", function(depth, sky)
        if sky or depth then return end
        local pos = LocalPlayer():GetEyeTrace().HitPos
        roundvec(pos)
        local baba = BABA
        local baba2 = BABA2 or pos
        render.SetColorMaterial()

        if (baba and baba2) then
            render.CullMode(MATERIAL_CULLMODE_CW)
            local mins = Vector(math.min(baba.x, baba2.x), math.min(baba.y, baba2.y), math.min(baba.z, baba2.z))
            local maxs = Vector(math.max(baba.x, baba2.x), math.max(baba.y, baba2.y), math.max(baba.z, baba2.z))
            render.ClearDepth()
            render.SetMaterial(map_holo)
            render.DrawBox(Vector(), Angle(), mins, maxs, Color(0, 255, 0, 32))
            render.DrawBoxEdges(mins, maxs, Color(0, 255, 0, 255))
            render.CullMode(MATERIAL_CULLMODE_CCW)
        end

        if (wawa) then
            for k, v in pairs(Location.GetLocations()) do
                if (LocalPlayer():GetLocation() ~= k) then continue end
                local mins, maxs = v.Min, v.Max
                render.DrawBox(Vector(), Angle(), mins, maxs, Color(0, 255, 0, 4))
                render.DrawBoxEdges(mins, maxs, Color(0, 255, 0, 255))
            end
        end
    end)

    concommand.Add("baba", function()
        local pos = LocalPlayer():GetEyeTrace().HitPos

        if (BABA and BABA2) then
            BABA = nil
            BABA2 = nil
        end

        if (not BABA and not BABA2) then
            BABA = pos * 1
            roundvec(BABA)

            return
        end

        if (BABA and not BABA2) then
            BABA2 = pos * 1
            roundvec(BABA2)
            local mins = Vector(math.min(BABA.x, BABA2.x), math.min(BABA.y, BABA2.y), math.min(BABA.z, BABA2.z))
            local maxs = Vector(math.max(BABA.x, BABA2.x), math.max(BABA.y, BABA2.y), math.max(BABA.z, BABA2.z))
            roundvec(mins)
            roundvec(maxs)
            print("{")
            print("Min = Vector(" .. mins.x .. "," .. mins.y .. "," .. mins.z .. "),")
            print("Max = Vector(" .. maxs.x .. "," .. maxs.y .. "," .. maxs.z .. "),")
            print("},")

            return
        end
    end)
