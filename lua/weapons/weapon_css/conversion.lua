
if(true)then return end
local swept = SWEP

for k, fl in pairs(file.Find("weapons/weapon_css/guns_raw/*", "LUA")) do
    local fc = file.Read("weapons/weapon_css/guns_raw/" .. fl, "LUA")
    local class = string.Explode(".", fl)[1]
    local tab = util.KeyValuesToTable(fc, false, true)
    local writecontents = [=[-- This file is subject to copyright - contact swampservers@gmail.com for more information.
    -- INSTALL: CINEMA
    AddCSLuaFile()
    ParseCSScript([[
        ]=]..fc..[=[
    ]])
    ]=]
    
    file.CreateDir("csw")
    file.Write("csw/" .. class .. ".txt", writecontents)
    print("wrote csw/"..class..".txt")
end

