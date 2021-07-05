module("War", package.seeall)
Enable = true

IdleScoreTimer = 0.2
TerritoryControlMax = 30

Score_KillBase = 10

HarmlessSpectators = true

TerritoryControl = TerritoryControl or {}
if(SERVER)then
    concommand.Add("resetwar",function()
        TerritoryControl = {}
    end)
end


--TeamSpawnPower is the weighted chance of spawning into friendly territory, if any exists. Should be distributed based on "secureness" and evenly based on spawn numbers.
--Values are also divided by number of spawns in the given area, so that areas with a denser nav mesh aren't given priority
NeutralSpawnPower = 4
TeamSpawnPower = 10 

TeamSpawnPowerMulCapping = 0.01


--you can have as many as you want i think
NeutralColor = Color(180, 180, 180)
Factions = {
    {
        Name = "The Assholes",
        Color = Color(69, 133, 216)
    },
    {
        Name = "The Fuckers",
        Color = Color(250, 124, 6)
    },
    {
        Name = "The Idiots",
        Color = Color(152, 6, 250)
    },
    {
        Name = "The Bitches",
        Color = Color(214, 68, 117)
    },
    {
        Name = "The Retards",
        Color = Color(135, 240, 37)
    },
}
for k,v in pairs(Factions)do
team.SetUp( k, v.Name,  v.Color, true)
end


if(CLIENT)then
    hook.Add("Think","LolMenus",function()
    
        _G.MenuTheme_Brand = team.GetColor(LocalPlayer():Team())
        _G.MenuTheme_BrandDarker = Color(MenuTheme_Brand.r * 0.7, MenuTheme_Brand.g * 0.7, MenuTheme_Brand.b * 0.7)
    end)
    hook.Add( "PreDrawHalos", "AddPropHalos", function()
        --halo.Add( team.GetPlayers(LocalPlayer():Team()), team.GetColor(LocalPlayer():Team()), 3, 3, 2,true,false )
    end )
end


function IdleScore(faction)
    local tcount = GetTerritoryCount(faction)
    local score = 1

    if (tcount > 0) then
        for i = 1, tcount do
            score = score * 1.05
        end
    end

    score = score - 1

    return math.max(0, score)
end

function KillScore(ply, faction)
    return 5 + 1
end


if(SERVER)then
    util.AddNetworkString("War_ChatMessage")
end
if(CLIENT)then
    net.Receive("War_ChatMessage",function(len)
        local vars = net.ReadTable()
        WarMessage(vars)
    end)
end


    function WarMessage(vars)
        if(SERVER)then
            net.Start("War_ChatMessage")
            net.WriteTable(vars)
            net.Broadcast()
        end
        if(CLIENT)then
        chat.AddText(unpack(vars))
        end
    end




function TerritoryAddControl(territory, faction, strength)
    if (strength == nil or strength == 0) then return end
    local control = TerritoryControl[territory]
    local cancap = true
    local capping = {}

    for fct, factioninfo in pairs(Factions) do
        control[fct] = control[fct] or 0
        --do we have work to do first?
        if (fct ~= faction) then
            if (control[fct] > 0) then
                cancap = false
            end
        end
    end
    if(!CanCaptureTerritory(territory,faction,true))then
        cancap = false
    end



    if (cancap and control[faction] < TerritoryControlMax) then
        local upd = math.Clamp(control[faction] + strength, 0, TerritoryControlMax)


        if (upd > control[faction]) then
            capping[faction] = GetTerritoryOwner(territory) ~= faction
        end
        if(control[faction] == 0 and upd > 0)then
            WarMessage({team.GetColor(faction),team.GetName(faction),Color(255,255,255)," have captured ".. Location.GetTerritoryName(territory).."!"})
        end
        if(control[faction] < TerritoryControlMax and upd >= TerritoryControlMax)then
            WarMessage({team.GetColor(faction),team.GetName(faction),Color(255,255,255)," have fully secured ".. Location.GetTerritoryName(territory).."!"})
        end

        control[faction] = upd
    end

    for fct, factioninfo in pairs(Factions) do
        control[fct] = control[fct] or 0
        --decrease other faction control over this territory until it's 0, then we can start taking it.
        if (fct ~= faction) then
            if (control[fct] > 0) then
                capping[faction] = GetTerritoryOwner(territory) != faction
                control[fct] = math.Clamp(control[fct] - 1, 0, TerritoryControlMax)
            end
        end
    end


end

function GetTerritoryControl(territory, faction)
    return GetGlobalInt("war_tc_" .. territory .. "_" .. faction) or 0
end

function GetTerritoryControlRatio(territory, faction)
    return GetTerritoryControl(territory, faction) / TerritoryControlMax
end

function CanCaptureTerritory(territory,faction,requirefully)
    local dat = Location.GetLocations()[territory]
    if(dat and dat.RequireTerritories)then
        local met = true 
        for k,v in pairs(dat.RequireTerritories)do
            if(Location.IsTerritory(v) and (GetTerritoryOwner(v) != faction or (requirefully and GetTerritoryControl(v,faction) < TerritoryControlMax)))then
                return false
            end
        end
    end
    return true
end



function GetTerritoryCapping(territory, faction)
    return GetGlobalBool("war_tc_" .. territory .. "_" .. faction .. "cap") or false
end

function GetTerritoryOwner(territory)
    if(territory == nil)then return end
    for faction, factioninfo in pairs(Factions) do
        if (GetTerritoryControl(territory, faction) > 0) then return faction end
    end
end

function GetTerritoryCount(faction)
    local tc = 0
    for k,v in pairs(Location.TerritoryList)do
        if(GetTerritoryOwner(k) == faction)then
            tc = tc + 1
        end
    end
    return tc
end

function GetFriendlyTerritories(ply)
    local terr = {}

    for territory, tname in pairs(Location.TerritoryList) do
        if (GetTerritoryOwner(territory) == ply:Team()) then
            table.insert(terr,territory)
        end
    end

    return terr
end

if (SERVER) then
    TerritorySpawns = {}
    for _, area in pairs(navmesh.GetAllNavAreas()) do
        if (area:GetSizeX() < 32) then continue end
        if (area:GetSizeY() < 32) then continue end
        if (area:IsBlocked()) then continue end
        if (area:IsUnderwater()) then continue end
        if (area:HasAttributes(NAV_MESH_CROUCH)) then continue end
        local loc = Location.Find(area:GetCenter() + Vector(0, 0, 32))
        if (loc == 0 or loc == nil) then continue end
        local outside = Location.GetLocationNameByIndex(loc) == "Outside"
        local territory = Location.GetTerritory(loc)
        if (territory == nil and !outside) then continue end
        territory = territory or 0
        TerritorySpawns[territory] = TerritorySpawns[territory] or {}
        table.insert(TerritorySpawns[territory], area:GetCenter() + Vector(0, 0, 16))
    end

    function GetTerritorySpawns(territory)
        return TerritorySpawns[territory]
    end

    function GetSpawnPoint(ply)
        local spots = {}
        local total = 0
 
        local neutspawns = GetTerritorySpawns(0)
        for _,spawn in pairs(neutspawns)do
            local power = NeutralSpawnPower
            local dist = 1 / #neutspawns
            local weight = power*dist
            table.insert(spots, {spawn,weight})
            total = total + weight
        end

        local fters = GetFriendlyTerritories(ply)
        local friendlytotal = 0
        for _, territory in pairs(fters) do
        friendlytotal = friendlytotal +  GetTerritorySpawnability(territory)
        end


        for _, territory in pairs(fters) do
            local control = GetTerritoryControl(territory,ply:Team())
            local spawnpoints = GetTerritorySpawns(territory)
            local spawntotal = 0

            for _, spawn in pairs(spawnpoints) do
                local power = (control / TerritoryControlMax) 
                local dist = 1 / #spawnpoints / friendlytotal
                local weight = power * TeamSpawnPower * dist * GetTerritorySpawnability(territory)
                table.insert(spots, {spawn,weight})
                total = total + weight
            end
        end

        total = total - math.Rand(0,total)
        for k,spawn in pairs(spots)do
            total = total - spawn[2]
            if(total <= 0)then
                return spawn[1]
            end
        end
    end
end

function GetTerritorySpawnability(territory)
    for faction,v in pairs(Factions)do
        if(faction == GetTerritoryOwner(territory))then continue end
        if(GetTerritoryCapping(territory, faction))then
            return TeamSpawnPowerMulCapping
        end
    end
    return 1
end


function GetTerritoryColor(territory)
    if (not Location.IsTerritory(territory)) then return Color(40, 40, 40) end
    local owner = GetTerritoryOwner(territory)

    if(CLIENT and !CanCaptureTerritory(territory,LocalPlayer():Team(),true) and owner == nil)then
        return Color(40,40,40)
    end

    if (owner == nil) then return NeutralColor end


    

    local control = GetTerritoryControl(territory, owner)
    local col = LerpVector(0.1 + ((control / TerritoryControlMax) * 0.9), NeutralColor:ToVector(), GetFactionColor(owner):ToVector())

    for faction, factioninfo in pairs(Factions) do
        
        
        if (CLIENT and faction == LocalPlayer():Team()) then continue end

        if (GetTerritoryCapping(territory, faction)) then
            col = col * (math.sin(CurTime() * 10) > 0 and 0.75 or 1)
        end
    end

    return col:ToColor()
end

function GetFactionColor(faction)
    return Factions[faction].Color
end


hook.Add("PlayerSpawn", "WarLoadout", function(ply)
    if(ply:Team() != TEAM_UNASSIGNED)then
    local spawn = GetSpawnPoint(ply)
    if(spawn)then ply:SetPos(spawn) end
    ply:Give("weapon_warmap")
    ply:SetCustomCollisionCheck(true)
    end
    ply:SetNoCollideWithTeammates( true )
end)
hook.Add( "ShouldCollide", "CustomCollisions", function( ent1, ent2 )
end)

hook.Add( "ShouldCollide", "TeamCollide", function( ent1, ent2 )

    -- If players are about to collide with each other, then they won't collide.
    if ( ent1:IsPlayer() and ent2:IsPlayer() and ent1:Team() == ent2:Team()) then return false end
    if ( HarmlessSpectators and ent1:IsPlayer() and ent2:IsPlayer() and (ent1:Team() == TEAM_UNASSIGNED or ent2:Team() == TEAM_UNASSIGNED)) then return false end

end )

hook.Add( "PlayerShouldTakeDamage", "TeamDamage", function( ent1, ent2 )

    -- If players are about to collide with each other, then they won't collide.
    if ( ent1:IsPlayer() and ent2:IsPlayer() and ent1:Team() == ent2:Team()) then return false end
    if ( HarmlessSpectators and  ent1:IsPlayer() and ent2:IsPlayer() and (ent1:Team() == TEAM_UNASSIGNED or ent2:Team() == TEAM_UNASSIGNED)) then return false end

end )




timer.Create("WarIdleTimer", IdleScoreTimer, 0, function()
    for faction, factioninfo in pairs(Factions) do
        IdleScore(faction)
    end
end)

if (SERVER) then
    timer.Create("WarTimer", IdleScoreTimer, 0, function()
        for zone, v in pairs(Location.TerritoryList) do
            TerritoryControl[zone] = TerritoryControl[zone] or {}

            for faction, factioninfo in pairs(Factions) do
                TerritoryControl[zone][faction] = TerritoryControl[zone][faction] or 0
                
                if(!CanCaptureTerritory(zone,faction,false))then
                    TerritoryControl[zone][faction] = 0
                end
               
                local strength = table.Count(Location.GetPlayersInTerritory(zone, faction))

                if (strength ~= 0) then
                    TerritoryAddControl(zone, faction, strength)
                end

                SetGlobalInt("war_tc_" .. zone .. "_" .. faction, TerritoryControl[zone][faction])
                SetGlobalBool("war_tc_" .. zone .. "_" .. faction .. "cap", (strength > 0 and GetTerritoryOwner(zone) ~= faction) or false)
            end
        end
    end)
end