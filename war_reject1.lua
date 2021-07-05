if (SERVER) then return end
local map = Location.Map
local color_bg = NamedColor("BgColor")
local color_fg = NamedColor("FgColor")


--WARHUD_ZOOM = 2000
local map_holo = CreateMaterial("warhud_holo", "UnlitGeneric", {
    ["$basetexture"] = "color/white",
    ["$model"] = 1,
    ["$additive"] = 1,
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1,
})

local sewerfloors = {
    {
        Min = Vector(-320, 48, -688),
        Max = Vector(-144, 1092, -556),
    },
    --Test = true,
    {
        Min = Vector(-728, 740, -688),
        Max = Vector(-320, 868, -556),
    },
    {
        Min = Vector(-728, 740, -556),
        Max = Vector(-600, 868, -164),
        NoFloor = true,
    },
    {
        Min = Vector(-728, 2, -292),
        Max = Vector(-600, 740, -164),
    },
    {
        Min = Vector(-600, 2, -292),
        Max = Vector(0, 130, -164),
    },
    {
        Min = Vector(-256, 532, -484),
        Max = Vector(-144, 736, -356),
    },
    {
        Min = Vector(-384, 532, -484),
        Max = Vector(-256, 852, -357),
    },
    {
        Min = Vector(-336, 852, -484),
        Max = Vector(-272, 868, -372),
    },
    {
        Min = Vector(-128, 130, -292),
        Max = Vector(0, 674, -164),
    },
    {
        Min = Vector(-488, 120, -484),
        Max = Vector(-424, 868, -370),
    },
    {
        Min = Vector(-492, -176, -528),
        Max = Vector(-424, 120, -370),
    },
    {
        Min = Vector(-568, -176, -528),
        Max = Vector(-492, 868, -370),
    },
    {
        Min = Vector(-424, 186, -484),
        Max = Vector(-344, 242, -385),
    },
    {
        Min = Vector(-344, 186, -688),
        Max = Vector(-280, 242, -385),
    },
    {
        Min = Vector(-728, 868, -484),
        Max = Vector(-256, 996, -356),
    },
    {
        Min = Vector(-1136, -656, -650),
        Max = Vector(-272, -176, -300),
    },
    {
        Min = Vector(-1264, -564, -540),
        Max = Vector(-1136, -268, -392),
    },
    {
        Min = Vector(-40, 1581, -800),
        Max = Vector(671, 1932, -444),
        NoFloor = true,
    },
    {
        Min = Vector(-104, 1690, -752),
        Max = Vector(538, 1822, -752),
    },
}

local sewertfloors = {
    {
        Min = Vector(-892, 1092, -868),
        Max = Vector(-41, 2219, -364),
        NoFloor = true,
    },
    {
        Min = Vector(-488, 1248, -752),
        Max = Vector(-104, 2080, -752),
    },
    {
        Min = Vector(-269, 1156, -752),
        Max = Vector(-104, 1248, -752),
    },
    {
        Min = Vector(-492, 1092, -688),
        Max = Vector(-350, 1222, -688),
    },
    {
        Min = Vector(-350, 1092, -688),
        Max = Vector(-40, 1158, -688),
    },
    {
        Min = Vector(-106, 1252, -624),
        Max = Vector(-40, 1522, -624),
    },
}

local treatment = {
    {
        Min = Vector(-464, 1344, -128),
        Max = Vector(-304, 1504, -20),
    },
}

local trump = {
    {
        Min = Vector(-2996,20,-320),
        Max = Vector(-2932,44,-208),
    },   
    {
        Min = Vector(-3484, -168, -320),
        Max = Vector(-3100, 376, -192),
    },
    {
        Min = Vector(-3076, -176, -320),
        Max = Vector(-2776, 20, -176),
    },
    {
        Min = Vector(-3100, -130, -320),
        Max = Vector(-3076, -26, -216),
    },
    {
        Min = Vector(-3100, -130, -320),
        Max = Vector(-3076, -26, -216),
    },
    {
        Min = Vector(-2776, -130, -320),
        Max = Vector(-2752, -26, -216),
    },
    {
        Min = Vector(-2752,-176,-320),
        Max = Vector(-2496,12,-176),
    },
    {
        Min = Vector(-2697,12,-320),
        Max = Vector(-2641,36,-212),
    },
    {
        Min = Vector(-2628,-200,-320),
        Max = Vector(-2524,-176,-216),
    },
    {
        Min = Vector(-2656,-408,-320),
        Max = Vector(-2496,-200,-176),
    },
    {
        Min = Vector(-2672,-368,-320),
        Max = Vector(-2656,-252,-212),
    },
    {
        Min = Vector(-2882,-388,-320),
        Max = Vector(-2672,-224,-176),
    },
    {
        Min = Vector(-2496,-328,-320),
        Max = Vector(-2480,-280,-228),
    },
    {
        Min = Vector(-2480,-336,-320),
        Max = Vector(-2176,-272,-212),
    },
    {
        Min = Vector(-2176,-328,-320),
        Max = Vector(-2160,-280,-228),
    },  
}
local vice = {
    {
        Min = Vector(-2480,-208,-320),
        Max = Vector(-2240,48,-160),
    },
    {
        Min = Vector(-2496,-102,-320),
        Max = Vector(-2480,-54,-212),
    },
        
}
local stair = {
    {
        Min = Vector(-3000,44,-320),
        Max = Vector(-2776,344,144),
    },     
}

--[[{
Min = Vector(-488,120,-484),
Max = Vector(-424,868,-484),
},
]]
local terr = {}
terr["Trumppenbunker"] = true
terr["Restroom"] = true
terr["The Pit"] = true
terr["Golf"] = true
terr["Gym"] = true



local warmap = {}
for k, v in pairs(map) do
    if (v.Name == "Outside") then continue end
    if (v.Name == "Way Outside") then continue end
    if (v.Name == "Deep Space") then continue end
    if (v.Name == "Moon") then continue end
    if (v.Name == "Labyrinth") then continue end
    if (v.Name == "Temple of Kek") then continue end
    if (v.Name == "In Minecraft") then continue end
    if (v.Name == "The Underworld") then continue end
    if (v.Name == "Void") then continue end
    if (v.Name == "The Box") then continue end
    if (v.Name == "Potassium Palace") then continue end
    if (v.Name == "Moon Base") then continue end
    if (v.Name == "Moon") then continue end
    if (v.Name == "Tree") then continue end
    if (v.Name == "Attic") then continue end
    
    local nt = table.Copy(v)

    if (v.Name == "Cemetery") then
        v.Out = true
    end
    if (v.Name == "Power Plant") then
        v.Out = true
    end
    if (v.Name == "The Pit") then
        v.Out = true
    end

    if (v.Name == "Golf") then
        v.Out = true
    end 

    if (v.Name == "Sewer Tunnels") then
        nt.Draw = sewerfloors
        nt.Underground = true
    end

    if (v.Name == "Sewer Theater") then
        nt.Draw = sewertfloors
        nt.Underground = true
    end

    if (v.Name == "Treatment Room") then
        nt.Draw = treatment
    end
    if (v.Name == "Stairwell") then
        nt.Draw = stair
    end

    if (v.Name == "Trumppenbunker") then
        nt.Draw = trump
    end
    if (v.Name == "Office of the Vice President") then
        nt.Draw = vice
    end
    if (v.Name == "Trump Tower") then
        nt.NoFloor = true
    end
    nt.Territory = terr[v.Name]
    nt.Index = k

    if (not nt.Territory) then
        nt.Color = Color(48, 48, 48)
    else
        nt.Color = HSVToColor(math.Rand(0, 0), 1, 1)
    end

    table.insert(warmap, nt)
end

local function debugText(vec, text, scale, color)
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

maprender = {}

function maprender.Reset()
    render.OverrideBlend(false)
    render.CullMode(MATERIAL_CULLMODE_CCW)
    render.OverrideAlphaWriteEnable(false, false)
end

function maprender.DrawBoxEdges(mins, maxs, color)
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

function maprender.DrawBoxOutline(mins, maxs, color, leaveoutline)
    render.OverrideAlphaWriteEnable(true, true)
    render.CullMode(MATERIAL_CULLMODE_CW)
    local omins = mins * 1
    local omaxs = maxs * 1
    color.a = 255

    if (not leaveoutline) then
        mins = omins + Vector(1, 1, 1) * -WARMAP_OUTLINETHICK
        maxs = omaxs + Vector(1, 1, 1) * WARMAP_OUTLINETHICK
    end

    render.SetMaterial(Material("color"))
    render.DrawBox(Vector(), Angle(), mins, maxs, color)
    maprender.Reset()
end

function maprender.DrawBoxOutline2(mins, maxs, color, leaveoutline)
    render.OverrideAlphaWriteEnable(true, false)
    render.CullMode(MATERIAL_CULLMODE_CW)
    local omins = mins * 1
    local omaxs = maxs * 1
    mins = omins + Vector(1, 1, 1) * -WARMAP_OUTLINETHICK * 0.5
    maxs = omaxs + Vector(1, 1, 1) * WARMAP_OUTLINETHICK * 0.5
    color.a = 255
    render.SetMaterial(Material("color"))
    render.DrawBox(Vector(), Angle(), mins, maxs, Color(0, 0, 0, color.a))
    maprender.Reset()
end

function maprender.DrawBoxGap(mins, maxs, color)
    render.CullMode(MATERIAL_CULLMODE_CW)
    render.SetColorMaterial()
    local dark = 0.25
    color.a = 255
    local bgcol = Color(color.r * dark, color.g * dark, color.b * dark, color.a)
    --render.OverrideBlend( true, BLEND_SRC_COLOR, BLEND_SRC_COLOR, BLENDFUNC_REVERSE_SUBTRACT, BLEND_ZERO, BLEND_ZERO, BLENDFUNC_REVERSE_SUBTRACT )
    render.DrawBox(Vector(), Angle(), mins, maxs, bgcol)

    maprender.Reset()
end

function maprender.DrawPreFloor(mins, maxs, color)
    render.CullMode(MATERIAL_CULLMODE_CW)
    render.SetColorMaterial()
    local floor = mins + Vector(-1, -1, -1) * WARMAP_OUTLINETHICK * 0.5
    local floor2 = Vector(maxs.x, maxs.y, mins.z) + Vector(1, 1, 0) * WARMAP_OUTLINETHICK * 0.5
    color.a = 255
    render.DrawBox(Vector(), Angle(), floor, floor2, Color(0, 0, 0, color.a))
    maprender.Reset()
end

function maprender.DrawBoxFloor(mins, maxs, color)
    render.SetColorMaterial()
    local floor = Vector(maxs.x, maxs.y, mins.z)
    local dark = 1
    color.a = 255
    local bgcol = Color(color.r * dark, color.g * dark, color.b * dark, color.a)
    render.DrawBox(Vector(), Angle(), mins, floor, bgcol)
    maprender.Reset()
end

function maprender.AreaBounds(box)
    local mins = Vector(1, 1, 1) * 16000
    local maxs = Vector(1, 1, 1) * -16000

    if (box.Draw) then
        for k, v in pairs(box.Draw) do
            local kmins = v.Min
            local kmaxs = v.Max
            mins.x = math.min(mins.x, kmins.x)
            mins.y = math.min(mins.y, kmins.y)
            mins.z = math.min(mins.z, kmins.z)
            maxs.x = math.max(maxs.x, kmaxs.x)
            maxs.y = math.max(maxs.y, kmaxs.y)
            maxs.z = math.max(maxs.z, kmaxs.z)
        end

        local center = (mins + maxs) / 2
        local fcent = Vector(center.x, center.y, mins.z)

        return mins, maxs, center, fcent
    else
        local kmins = box.Min
        local kmaxs = box.Max
        mins.x = math.min(mins.x, kmins.x)
        mins.y = math.min(mins.y, kmins.y)
        mins.z = math.min(mins.z, kmins.z)
        maxs.x = math.max(maxs.x, kmaxs.x)
        maxs.y = math.max(maxs.y, kmaxs.y)
        maxs.z = math.max(maxs.z, kmaxs.z)
        local center = (mins + maxs) / 2
        local fcent = Vector(center.x, center.y, mins.z)

        return mins, maxs, center, fcent
    end
end

local function boxdepth(box)
    local mins, maxs, cent, fcent = maprender.AreaBounds(box)
    local pos, ang = WorldToLocal(fcent, Angle(), WARHUD_RENDERPOS, WARHUD_RENDERANGLES)
    --box.Color = HSVToColor(180+math.NormalizeAngle(-pos.x),1,1)

    return pos.x
end

function SetupMapElements(warmap)
    local boxes = {}
    local und = EyePos().z < 0
    
    
    for k, loc in pairs(warmap) do
        local color = table.Copy(loc.Color) or Color(100, 200, 255, 255)
        --loc.Color = color
        local mins, maxs = loc.Min, loc.Max
        local bcent = (mins + maxs) / 2
        if (LocalPlayer():GetLocation() == loc.Index) then 
        color = Color(0,180,0)
        end
        loc.Underground = bcent.z < 0

        if ((EyePos().z > 0) ~= (bcent.z > 0)) then continue end --color.a = color.a / 16

        if (loc.Draw) then
            for k, box in pairs(loc.Draw) do
                local t = table.Copy(box)
                if (EyePos().z + 0 < t.Min.z) then continue end
                if (boxdepth(loc) < 0) then end
                t.Underground = loc.Underground
                t.NoFloor = t.NoFloor or loc.NoFloor
                
                t.Color = color
                t.Index = loc.Index
                t.Out = loc.Out

                if (t.Test) then
                    t.Color = Color(0, 255, 255)
                end

                table.insert(boxes, t)
            end
        else
            local t = table.Copy(loc)
            t.Color = color
            if (t.Test) then
                t.Color = Color(0, 255, 255)
            end

            if (EyePos().z + 0 < t.Min.z) then continue end
            if (boxdepth(t) < 0) then end --continue
            table.insert(boxes, t)
        end
    end

    table.sort(boxes, function(a, b) return boxdepth(a) > boxdepth(b) end)

    return boxes
end

function DrawMapElements(boxes, func)
    for k, box in ipairs(boxes) do
        local mins, maxs = box.Min, box.Max
        local color = box.Color
        func(mins, maxs, color, box)
    end
end


WARHUD_CX = ScrW() / 2
WARHUD_Y = 16
WARHUD_MAP_W = 512
WARHUD_MAP_H = 512

WARHUD_ZOOM_DEF = 4000
WARHUD_ZOOM_UND = 2000

WARHUD_ZOOM = WARHUD_ZOOM or WARHUD_ZOOM_DEF

WARMAP_OUTLINETHICK = WARHUD_ZOOM / 100

hook.Add("HUDPaint", "WarHUD", function()
    local und = EyePos().z < 0
    WARHUD_ZOOM = math.Approach(WARHUD_ZOOM, und and WARHUD_ZOOM_UND or WARHUD_ZOOM_DEF, FrameTime() * 1500)
    WARMAP_OUTLINETHICK = WARHUD_ZOOM / 100
    local w, h = WARHUD_MAP_W, WARHUD_MAP_H
    local x, y = WARHUD_CX - (w / 2), WARHUD_Y
    local orh = WARHUD_ZOOM
    local orv = WARHUD_ZOOM * (h / w)
    surface.SetDrawColor(color_bg)
    surface.DrawRect(x, y, w, h)
    local center = EyePos()
    local ang = EyeAngles()


    local pos = center
    render.SetMaterial(map_holo)
    cam.Start3D(pos, ang, 40, x, y, w, h)
    WARHUD_RENDERPOS = pos
    WARHUD_RENDERANGLES = ang
    cam.StartOrthoView(-orh, orv, orh, -orv)
    --render.ClearDepth()
    render.OverrideDepthEnable(true, true)
    local boxes = SetupMapElements(warmap)



    DrawMapElements(boxes, function(mins, maxs, color, zone)
        if (zone.Out) then return end
        if !zone.Underground then return end
        maprender.DrawBoxOutline(mins, maxs, color)
    end)

    render.ClearDepth()

    DrawMapElements(boxes, function(mins, maxs, color, zone)
        if (zone.Out) then return end
        if !zone.Underground then return end
        maprender.DrawBoxOutline2(mins, maxs, color)
    end)

    render.ClearDepth()

    DrawMapElements(boxes, function(mins, maxs, color, zone)
        if (zone.Out) then return end
        if !zone.Underground then return end
        maprender.DrawBoxGap(mins, maxs, color)
    end)

    render.ClearDepth()

    DrawMapElements(boxes, function(mins, maxs, color, zone)
        if (zone.NoFloor) then return end
        maprender.DrawPreFloor(mins, maxs, color)
    end)

    DrawMapElements(boxes, function(mins, maxs, color, zone)
        if (zone.NoFloor) then return end
        maprender.DrawBoxFloor(mins, maxs, color)
    end)

    local pmins, pmaxs = LocalPlayer():GetCollisionBounds()
    local color = Color(255, 255, 255, 200)
    render.DrawBox(LocalPlayer():GetPos(), Angle(), pmins, pmaxs, color)
    cam.EndOrthoView()
    cam.End3D()
    render.OverrideDepthEnable(false, true)
end)

hook.Add("PostDrawTranslucentRenderables", "TestMapper", function(depth, sky)
    if sky or depth then return end
    local pos = LocalPlayer():GetEyeTrace().HitPos
    roundvec(pos)
    local baba = BABA
    local baba2 = BABA2 or pos

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