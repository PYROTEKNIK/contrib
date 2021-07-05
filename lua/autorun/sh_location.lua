-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
module("Location", package.seeall)
local THEATER_NONE = 0 --default/public theater
local THEATER_PRIVATE = 1 --private theater
local THEATER_REPLICATED = 2 --public theater, shows on the scoreboard
local THEATER_PRIVATEREPLICATED = 3 --private theater, shows on the scoreboard
Debug = true

Map = {
    {
        Name = "Entrance",
        Min = Vector(-512, -256, -16),
        Max = Vector(512, 160, 352),
    },
    {
        Name = "Lobby",
        Min = Vector(-512, 160, -16),
        Max = Vector(512, 1264, 256),
        IsTerritory = true,
        RequireTerritories = {
        ["Vapor Lounge"] = true,
        ["Movie Theater"] = true,
        ["Bedroom"] = true,
        ["Restroom"] = true,
        ["Back Room"] = true,
        
        }
    },
    {
        Name = "Concessions",
        TerritoryGroup = "Lobby",
        Min = Vector(-512, 1264, -16),
        Max = Vector(512, 1536, 128)
    },
    {
        Name = "Restroom",
        IsTerritory = true,
        Min = Vector(0, 1104, -64),
        Max = Vector(640, 1792, 128)
    },
    --after lobby, concessions
    {
        Name = "Attic",
        Min = Vector(-472, 1344, 152),
        Max = Vector(128, 1504, 192),
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(83, 1491, 178.5),
            Ang = Angle(0, -45, 0),
            Width = 45,
            Height = 25
        }
    },
    --after lobby, concessions
    {
        Name = "Movie Theater",
        Min = Vector(-1776, 1120, -161),
        Max = Vector(-763, 2274, 382),
        IsTerritory = true,
        Theater = {
            Flags = THEATER_REPLICATED,
            Pos = Vector(-1696, 2250, 366),
            Ang = Angle(0, 0, 0),
            Width = 864,
            Height = 486,
            Thumb = "m_thumb",
            ProtectionTime = 7200,
        },
        Filter = function(pos) return (pos.x < -1538 and pos.z < 328) or pos.y > 1280 end
    },
    {
        Name = "West Hallway",
        Min = Vector(-1536, 1024, -32),
        Max = Vector(-512, 1792, 160),
        TerritoryGroup = "Lobby",
    },
    --after vapor lounge
    {
        Name = "East Hallway",
        Min = Vector(512, 512, -16),
        Max = Vector(2048, 1024, 256),
        TerritoryGroup = "Lobby",
    },
    {
        Name = "Public Theater",
        Min = Vector(-1536, 0, -144),
        Max = Vector(-512, 1024, 256),
        TerritoryGroup = "Lobby",
        Filter = function(pos) return pos.x + pos.y > -1024 end,
        Theater = {
            Flags = THEATER_REPLICATED,
            Pos = Vector(-1035, 48.5, 244),
            Ang = Angle(0, 135, 0),
            Width = 640,
            Height = 360,
            Thumb = "pub_thumb"
        }
    },
    {
        Name = "Private Theater 1",
        Min = Vector(512, 0, -16),
        Max = Vector(896, 512, 256),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(632, 487.2, 173),
            Ang = Angle(0, 0, 0),
            Width = 240,
            Height = 135,
            Thumb = "p1_thumb"
        }
    },
    {
        Name = "Private Theater 2",
        Min = Vector(896, 0, -16),
        Max = Vector(1280, 512, 256),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(1016, 487.2, 173),
            Ang = Angle(0, 0, 0),
            Width = 240,
            Height = 135,
            Thumb = "p2_thumb"
        }
    },
    {
        Name = "Private Theater 3",
        Min = Vector(1280, 0, -16),
        Max = Vector(1664, 512, 256),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(1400, 487.2, 173),
            Ang = Angle(0, 0, 0),
            Width = 240,
            Height = 135,
            Thumb = "p3_thumb"
        }
    },
    {
        Name = "Private Theater 4",
        Min = Vector(1664, 0, -16),
        Max = Vector(2048, 512, 256),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(1784, 487.2, 173),
            Ang = Angle(0, 0, 0),
            Width = 240,
            Height = 135,
            Thumb = "p4_thumb"
        }
    },
    {
        Name = "Private Theater 5",
        Min = Vector(640, 1024, -48),
        Max = Vector(1122, 1804, 232),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(664.2, 1048, 173),
            Ang = Angle(0, 90, 0),
            Width = 240,
            Height = 135,
            Thumb = "p5_thumb"
        }
    },
    {
        Name = "Private Theater 6",
        Min = Vector(1152, 1024, -48),
        Max = Vector(1720, 1490, 256),
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            Pos = Vector(1176.1, 1102, 214),
            Ang = Angle(0, 90, 0),
            Width = 324,
            Height = 184,
            Thumb = "p6_thumb"
        },
        Filter = function(pos) return pos.x < 1584 or pos.y < 1424 end
    },
    {
        Name = "Vapor Lounge",
        Min = Vector(1865, 268, -19),
        Max = Vector(2549, 1524, 242),
        IsTerritory = true,
        Theater = {
            Flags = THEATER_PRIVATEREPLICATED,
            -- Pos = Vector(2312+36, 1520-37, 210), -- Ang = Angle(0, 315, 0), -- Pos = Vector(2304 + 262.5 / 2, 273, 216), -- Width = 262.5, --21:9; should be 200 for 16:9 -- Height = 112.5,
            Pos = Vector(2304 + 256 / 2, 273 + 8 + 16, 216),
            Width = 256, --21:9; should be 200 for 16:9
            Height = 144,
            Ang = Angle(0, 180, 0),
            AllowItems = true,
            ProtectionTime = 3600,
        },
        Filter = function(pos) return pos.x < 2560 or (pos.y > 560 and pos.y < 688 and pos.z < 128) end
    },
    {
        Name = "Furnace",
        Min = Vector(1759, 1007, 0),
        Max = Vector(1855, 1120, 128)
    },
    {
        Name = "AFK Corral",
        Min = Vector(1680, 512, -128),
        Max = Vector(3008, 1866, 248)
    },
    {
        Name = "Back Room",
        Min = Vector(-512, 1536, -16),
        Max = Vector(0, 1792, 128),
        IsTerritory = true,
    },
    {
        Name = "Treatment Room",
        Underground = true,
        Min = Vector(-512, 1280, -144),
        Max = Vector(-256, 1536, -16),
        TerritoryGroup = "Back Room",
    },
    {
        Name = "Server Room",
        Underground = true,
        Min = Vector(-560, 1664, -144),
        Max = Vector(-360, 1792, -16),
        TerritoryGroup = "Back Room",
    },
    {
        Name = "Basement",
        Underground = true,
        Min = Vector(-512, 1536, -144),
        Max = Vector(0, 1792, -16),
        TerritoryGroup = "Back Room",
    },
    --after server room
    {
        Name = "Bedroom",
        Min = Vector(-736, 1536, -160),
        Max = Vector(-560, 2052, -32),
        IsTerritory = true,
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(-578.9, 1972, -101),
            Ang = Angle(0, 270, 0),
            Width = 32,
            Height = 18
        }
    },
    --after server room
    {
        Name = "Reddit",
        Min = Vector(-450, 1210, -292),
        Max = Vector(-210, 1450, -128),
        TerritoryGroup = "Sewer Tunnels",
        Underground = true,
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(-285, 1213, -214),
            Ang = Angle(0, 180, 0),
            Width = 60,
            Height = (60 * 9 / 16)
        }
    },
    {
        Name = "Rat's Lair",
        Min = Vector(-220, 440, -292),
        Max = Vector(-72, 1450, -128),
        Underground = true,
        TerritoryGroup = "Sewer Tunnels",
    },
    --after chromozone
    {
        Name = "Sewer Theater",
        Min = Vector(-1024, 1024, -1024),
        Max = Vector(0, 2220, -64),
        Underground = true,
        IsTerritory = true,
        Theater = {
            Flags = THEATER_REPLICATED,
            Pos = Vector(-1016, 1318, -368),
            Ang = Angle(0, 90, 0),
            Width = 676,
            Height = 376,
            AllowItems = true
        }
    },
    --after chromozone and rat's lair
    {
        Name = "Maintenance Room",
        Min = Vector(-1536, -560, -540),
        Max = Vector(-1264, -272, -412),
        Underground = true,
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(-1510.9, -493, -472),
            Ang = Angle(0, 90, 0),
            Width = 56,
            Height = 32
        }
    },
    {
        Name = "Moon Base",
        Min = Vector(3608, -872, 11336),
        Max = Vector(3944, -536, 11464),
        Filter = function(pos) return Vector(3776, -704, 0):Distance(Vector(pos.x, pos.y, 0)) < 168 end,
        Theater = {
            Flags = THEATER_NONE,
            Pos = Vector(3933, -725.2, 11466),
            Ang = Angle(0, 225, 0),
            Width = 192,
            Height = 108
        }
    },
    {
        Name = "Office of the Vice President",
        Min = Vector(-2480, -208, -320),
        Max = Vector(-2240, 48, -160),
        Underground = true,
        TerritoryGroup = "Trumppenbunker"
    },
    {
        Name = "Situation Monitoring Room",
        Min = Vector(-2752, 36, -320),
        Max = Vector(-2525, 230, -184),
        Underground = true,
        TerritoryGroup = "Trumppenbunker"
    },
    {
        Name = "Elevator Shaft",
        Min = Vector(-2768, 160, -144),
        Max = Vector(-2576, 288, 992),
        TerritoryGroup = "Trump Tower"
    },
    {
        Name = "Stairwell",
        Min = Vector(-3000, 44 - 64, -320),
        Max = Vector(-2776, 344, -1),
        Underground = true,
        Filter = function(pos) return pos.y > 120 or pos.z < -176 end,
        TerritoryGroup = "Trumppenbunker"
    },
    {
        Name = "Trump Lobby",
        Min = Vector(-2992, -432, 0),
        Max = Vector(-1968, 336, 256),
        TerritoryGroup = "Trump Tower"
    },
    --after office of the vice president & elevator shaft
    {
        Name = "Drunken Clam",
        Min = Vector(-2872, -1054, -10),
        Max = Vector(-1974, -560, 176),
        IsTerritory = true,
        Theater = {
            Flags = THEATER_REPLICATED,
            Pos = Vector(-2372, -1020.9, 142),
            Ang = Angle(0, 180, 0),
            Width = 96,
            Height = 54
        }
    },
    {
        Name = "SushiTheater",
        Min = Vector(-2912, -2008, -16),
        Max = Vector(-2096, -1192, 192),
        IsTerritory = true,
    },
    {
        Name = "SushiTheater Basement",
        Underground = true,
        Min = Vector(-2912, -2008, -176),
        Max = Vector(-2096, -1100, -24),
    },
    {
        Name = "SushiTheater Second Floor",
        Min = Vector(-2832, -1928, 192),
        Max = Vector(-2176, -1272, 376),
        TerritoryGroup = "SushiTheater",
    },
    {
        Name = "SushiTheater Third Floor",
        Min = Vector(-2736, -1832, 376),
        Max = Vector(-2272, -1368, 592),
        TerritoryGroup = "SushiTheater",
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(-2727.9, -1728, 568),
            Ang = Angle(0, 90, 0),
            Width = 256,
            Height = 128
        }
    },
    {
        Name = "SushiTheater Attic",
        Min = Vector(-2656, -1752, 624),
        Max = Vector(-2352, -1448, 717),
        TerritoryGroup = "SushiTheater",
    },
    {
        Name = "Auditorium",
        Min = Vector(-2916, 1040, -144),
        Max = Vector(-2310, 1796, 256),
        Theater = {
            Flags = THEATER_REPLICATED,
            Pos = Vector(-2849.8, 1208, 136),
            Ang = Angle(0, 90, 0),
            Width = 420,
            Height = 235,
            AllowItems = true
        }
    },
    {
        Name = "Bomb Shelter",
        Min = Vector(-1736, 761, -176),
        Max = Vector(-1592, 952, -34),
        Underground = true,
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(-1658, 800.1, -122),
            Ang = Angle(0, 180, 0),
            Width = 20,
            Height = 12
        }
    },
    {
        Name = "The Pit",
        --Filter = function(pos) return Vector(0,-1152,0):Distance(Vector(pos.x,pos.y,0)) < 650 or pos.y<-1152 end,
        Min = Vector(-1263, -2656, -144),
        Max = Vector(735, -511, 779),
        IsTerritory = true,
    },
    --[[Filter = function(pos) return Vector(0,-1152,0):Distance(Vector(pos.x,pos.y,0)) < 512 end,
		Min = Vector(-512,-1152-512,-128),
		Max = Vector(512,-1152+512,192)]] -- 10 "Mobile" theaters are used by prop_trash_theater
    {
        Name = "MOBILE",
    },
    {
        Name = "MOBILE",
    },
    {
        Name = "MOBILE",
    },
    {
        Name = "MOBILE",
    },
    {
        Name = "MOBILE",
    },
    {
        Name = "MOBILE",
    },
    {
        Name = "MOBILE",
    },
    {
        Name = "MOBILE",
    },
    {
        Name = "MOBILE",
    },
    {
        Name = "MOBILE",
    },
    {
        Name = "Control Room",
        Min = Vector(1423, 3905, -10),
        Max = Vector(1841, 4144, 120),
        TerritoryGroup = "Power Plant",
    },
    {
        Name = "Power Plant",
        Min = Vector(964, 2825, -48),
        Max = Vector(3456, 4608, 512),
        IsTerritory = true,
    },
    {
        Name = "Hot Tub",
        Min = Vector(2006, 3206, -1016),
        Max = Vector(2410, 3610, 8),
        Underground = true,
        TerritoryGroup = "Power Plant",
    },
    {
        Name = "Kleiner's Lab",
        Min = Vector(5824, 2752, -400),
        Max = Vector(6464, 3712, 92),
        IsTerritory = true,
        Underground = true,
        Filter = function(pos) return pos.x > 5887 or pos.y < 3472 end
    },
    {
        Name = "Strange Asian Hole",
        Underground = true,
        Min = Vector(2592, 2164, -440),
        Max = Vector(5888, 3712, -136),
    },
    {
        Name = "Cemetery",
        Min = Vector(-3264, 2880, -128),
        Max = Vector(-966, 4608, 768),
        IsTerritory = true,
    },
    {
        Name = "Swamp Hut",
        Min = Vector(-105, 2828, 26),
        Max = Vector(199, 3132, 146),
        IsTerritory = true,
        Theater = {
            Flags = THEATER_PRIVATE,
            Pos = Vector(17.5, 3121.7, 95),
            Ang = Angle(0, 0, 0),
            Width = 59,
            Height = 33
        },
        Filter = function(pos) return pos.x > -45 or pos.y > 2888 end
    },
    {
        Name = "The Underworld",
        Min = Vector(-13312, -7168, -9216),
        Max = Vector(-7168, -1024, -3072),
        Theater = {
            Flags = THEATER_NONE,
            Pos = Vector(-9912.4, -4390, -5934),
            Ang = Angle(0, 270, 0),
            Width = 260,
            Height = 148
        }
    },
    {
        Name = "Void",
        Min = Vector(-6144, 1024, 0),
        Max = Vector(-5120, 2048, 1024)
    },
    {
        Name = "The Box",
        Min = Vector(-13554, -242, -1547),
        Max = Vector(-10004, 3315, 1711)
    },
    {
        Name = "Throne Room",
        Min = Vector(-2560, -432, 800),
        Max = Vector(-2128, -112, 992),
        TerritoryGroup = "Trump Tower"
    },
    {
        Name = "Trump Tower",
        Min = Vector(-2993, -419, 260),
        Max = Vector(-1958, 346, 992),
        IsTerritory = true,
    },
    --after throne room --Filter = function(pos) return (pos.x+pos.y) > -4080 and (pos.x+pos.y) < -3136 end,
    {
        Name = "SportZone",
        Min = Vector(1952, -1680, -24),
        Max = Vector(2288, -1376, 128),
        IsTerritory = true,
        RequireTerritories = {
            ["Locker Room"] = true,
            ["Gym"] = true,
            ["Golf"] = true,
            
        },
        Filter = function(pos) return pos.x < 2142 or pos.y > -1561 end,
    },
    {
        Name = "Gym",
        Min = Vector(768, -2048, -24),
        Max = Vector(1952, -1376, 288),
        IsTerritory = true,
    },
    {
        Name = "Locker Room",
        Min = Vector(2016, -2064, -24),
        Max = Vector(2576, -1536, 128),
        IsTerritory = true,
    },
    {
        Name = "Janitor's Closet",
        Min = Vector(2288, -1536, -24),
        Max = Vector(2448, -1376, 104),
        TerritoryGroup = "SportZone"
    },
    {
        Name = "Sauna",
        Min = Vector(2288, -1536, -24),
        Max = Vector(2576, -1104, 128),
        TerritoryGroup = "Locker Room",
        Theater = {
            Flags = THEATER_NONE,
            Pos = Vector(2573.9, -1168, 96),
            Ang = Angle(0, -90, 0),
            Width = 128,
            Height = 72
        }
    },
    {
        Name = "Outdoor Pool",
        Min = Vector(1216, -1088, -128),
        Max = Vector(1632, -193, 128),
        TerritoryGroup = "Golf"
    },
    --after private theaters, pool
    {
        Name = "Golf",
        Min = Vector(1632, -2048, -128),
        Max = Vector(3009, 0, 226),
        IsTerritory = true,
        Filter = function(pos) return pos.x > 2592 or pos.y > -1087 end
    },
    {
        Name = "In Minecraft",
        Min = Vector(672, -2996, -3000),
        Max = Vector(5844, 2484, -128),
        Underground = true,
        Filter = function(pos) return pos.x < 5600 or pos.y < 2164 end
    },
    {
        Name = "Tree",
        Min = Vector(555, -1051, 224),
        Max = Vector(1355, -251, 1024)
    },
    {
        Name = "Weapons Testing Range",
        Min = Vector(-2160, -352, -320),
        Max = Vector(-1648, 1084, -180),
        Underground = true,
        TerritoryGroup = "Trumppenbunker"
    },
    {
        Name = "Trumppenbunker",
        Min = Vector(-3680, -753, -544),
        Max = Vector(-2160, 376, -176),
        Underground = true,
        IsTerritory = true,
        Filter = function(pos) return pos.x > -3008 or pos.z < -128 end
    },
    {
        Name = "Temple of Kek",
        Min = Vector(-2304, -5424, -640),
        Max = Vector(-1920, -4896, -384),
        Underground = true,
    },
    {
        Name = "Labyrinth",
        Min = Vector(-4096, -5407, -959),
        Max = Vector(672, -316, -384),
        Underground = true,
        Filter = function(pos) return pos.x > 0 or pos.y <= -768 end
    },
    {
        Name = "Moon",
        Min = Vector(-4000, -6000, 10400),
        Max = Vector(8000, 4000, 13500)
    },
    --after moon base
    {
        Name = "Deep Space",
        Min = Vector(5952, 4032, 6976),
        Max = Vector(16128, 16256, 16128)
    },
    --after moon
    {
        Name = "Potassium Palace",
        Min = Vector(-1512, 584, -2420),
        Max = Vector(-760, 1336, -144),
        Underground = true,
    },
    --after everything except sewer tunnels
    {
        Name = "Sewer Tunnels",
        IsTerritory = true,
        Min = Vector(-4000, -4000, -4000),
        Max = Vector(4000, 4000, -128),
        Underground = true,
    },
    --after everything except outside
    {
        Name = "Outside",
        Min = Vector(-4000, -4000, -4000),
        Max = Vector(4000, 4700, 16000)
    },
    --after everything
    {
        Name = "Way Outside",
        Min = Vector(-100000, -100000, -100000),
        Max = Vector(100000, 100000, 100000)
    }
}

--after everything
--set up and index mobile theaters
MobileLocations = {}

for k, v in pairs(Map) do
    if v.Name == "MOBILE" then
        table.insert(MobileLocations, k)
        v.MobileLocationIndex = #MobileLocations
        v.Name = "MobileTheater" .. tostring(v.MobileLocationIndex)
        v.Min = Vector(-1, -1, -10001)
        v.Max = Vector(1, 1, -10000)

        v.Theater = {
            Flags = 1,
            Pos = Vector(0, 0, 0),
            Ang = Angle(0, 0, 0),
            Width = 32,
            Height = 18
        }
    end
end

function RefreshPositions()
    for k, v in pairs(ents.GetAll()) do
        if v.LastLocationCoords ~= nil then
            v.LastLocationCoords = nil
        end
    end
end

-- returns a table of locations for the specified map, or the current map if nil
function GetLocations()
    return Map
end

-- returns the location string of the index
function GetLocationNameByIndex(iIndex)
    local temp = Map[iIndex]

    return temp and temp.Name or "Unknown"
end

-- find a location by name
-- note: this can be optimized with a second data structure
function GetLocationIndexByName(strName)
    local locations = GetLocations()
    if not locations then return end

    for k, v in pairs(locations) do
        if (v.Name == strName) then return k end
    end
end

-- find a location by index
function GetLocationByIndex(iIndex)
    return Map[iIndex]
end

-- find a location by name
-- note: this can be optimized with a second data structure
function GetLocationByName(strName)
    local locations = GetLocations()
    if not locations then return end

    for k, v in pairs(locations) do
        if (v.Name == strName) then return v end
    end
end

-- returns the index of the players current location or 0 if unknown
function Find(ply)
    local pos = isvector(ply) and ply or isentity(ply) and ply:GetPos()
    if (Map == nil) then return 0 end

    for k, v in next, Map do
        if (pos:InBox(v.Min, v.Max)) then
            if v.Filter then
                if v.Filter(pos) then return k end
            else
                return k
            end
        end
    end

    return 0
end

function GetPlayersInLocation(iIndex)
    local players = {}

    for _, ply in pairs(player.GetAll()) do
        if ply:GetLocation() == iIndex then
            table.insert(players, ply)
        end
    end

    return players
end

--war specific stuff

--Automate everything because data entry is cringe
TerritoryList = {}
for k,v in pairs(GetLocations())do
    local terr = v.TerritoryGroup or v.IsTerritory
    if(terr)then
        local tname = terr == true and v.Name or isstring(terr) and terr
        local ind = GetLocationIndexByName(tname)
        if(!ind or ind == 0)then print("bad territory group "..tname) continue end
        TerritoryList[ind] = tname
        GetLocations()[k]._TerritoryID = ind 
    end
    if(v.RequireTerritories)then
        for tname,_ in pairs(v.RequireTerritories)do
            v.RequireTerritories[tname] = GetLocationIndexByName(tname)
        end
    end


end
PrintTable(TerritoryList)







function IsTerritory(iIndex)
    return GetTerritory(iIndex) != nil
end

function GetTerritory(iIndex)
    local dat = GetLocations()[iIndex]
    if(!dat)then return end
    return dat._TerritoryID
end

function GetTerritoryName(iIndex)
    local territory = GetTerritory(iIndex)
    if(!territory)then return "" end
    return TerritoryList[territory]
end

function GetTerritoryControl(iIndex)

end

function GetPlayersInTerritory(iIndex,faction)
    if(!IsTerritory(iIndex))then return {} end
    local players = {}
    for _, ply in pairs(player.GetAll()) do
        if(!ply:Alive())then continue end
        if ply:GetTerritory() == iIndex and (faction == nil or ply:Team() == faction) then
            table.insert(players, ply)
        end
    end
    return players
end

