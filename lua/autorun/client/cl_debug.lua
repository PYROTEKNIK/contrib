-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
module("Location", package.seeall)
local DebugEnabled = CreateClientConVar("cinema_debug_locations", "0", false, false)

function render.ScreenText(vec, text, scale, color)
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


-- is there magical more mathy way to do this
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

-- location visualizer for debugging
hook.Add("PostDrawTranslucentRenderables", "CinemaDebugLocations", function(depth, sky)
    if sky or depth then return end
    if (not DebugEnabled:GetBool()) then return end
    render.ClearDepth()
    for k, v in pairs(GetLocations() or {}) do
        local center = (v.Min + v.Max) / 2
        render.DrawBox(Vector(), Angle(), v.Min, v.Max, Color(255,255,255,1))
        render.DrawBoxEdges(mins, maxs, color)
        --Debug3D.DrawText(center, v.Name, "VideoInfoSmall")
        render.ScreenText(center, v.Name, 64, Color(255,255,255))
    end
end)

