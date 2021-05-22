-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Tab("Construction", "bricks")
SS_Heading("Tools")

local function CannotBuyTrash(self, ply)
    if SERVER then return CannotMakeTrash(ply) end
end

SS_WeaponProduct({
    class = "weapon_trash_tape",
    price = 0,
    name = 'Tape Tool',
    description = "Use this to tape (freeze) and un-tape props.",
    model = 'models/swamponions/ducktape.mdl'
})

SS_WeaponProduct({
    class = "weapon_trash_paint",
    name = 'Paint Tool',
    description = "Paint a solid color onto props. Also changes the color of lights.",
    model = 'models/props_junk/metal_paintcan001a.mdl',
    price = 2000
})

SS_Product({
    class = 'trash',
    price = 0,
    name = 'Trash',
    description = "Spawn a random piece of junk for building stuff with",
    model = 'models/props_junk/cardboard_box001b.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        makeTrash(ply, trashlist[math.random(1, #trashlist)])
    end
})

SS_Heading("Props")

SS_Product({
    class = 'plate1',
    price = 1000,
    name = 'Small Plate',
    description = "Easy but costs money",
    model = 'models/props_phx/construct/metal_plate1.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        makeTrash(ply, self.model)
    end
})

SS_Product({
    class = 'plate2',
    price = 2000,
    name = 'Medium Plate',
    description = "Easy but costs money",
    model = 'models/props_phx/construct/metal_plate1x2.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        makeTrash(ply, self.model)
    end
})

SS_Product({
    class = 'plate3',
    price = 5000,
    name = 'Big Plate',
    description = "Easy but costs money",
    model = 'models/props_phx/construct/metal_plate2x2.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        makeTrash(ply, self.model)
    end
})

SS_Product({
    class = 'plate4',
    price = 2000,
    name = 'Triangle',
    description = "Easy but costs money",
    model = 'models/props_phx/construct/metal_plate2x2_tri.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        makeTrash(ply, self.model)
    end
})

SS_Product({
    class = 'trashfield',
    price = 200,
    name = 'Medium Protection Field',
    description = "While taped, prevents other players from building in your space. Also makes blocks stronger in the mines.",
    model = 'models/maxofs2d/hover_classic.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_field")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        timer.Simple(0, function()
            timer.Simple(0.001, function()
                makeForcefield(ply, self.model)
            end)
        end)
    end
})

SS_Product({
    class = 'trashfieldlarge',
    price = 3000,
    name = 'Large Protection Field',
    description = "While taped, prevents other players from building in your space. Also makes blocks stronger in the mines.",
    model = 'models/dav0r/hoverball.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_field")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        timer.Simple(0, function()
            timer.Simple(0.001, function()
                makeForcefield(ply, self.model)
            end)
        end)
    end
})

SS_Product({
    class = 'trashlight',
    price = 1000,
    name = 'Lights',
    description = "Lights up while taped",
    model = 'models/maxofs2d/light_tubular.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        local nxt = {}

        for k, v in pairs(trashlist) do
            if PropTrashLightData[v] then
                table.insert(nxt, v)
            end
        end

        e = makeTrash(ply, nxt[math.random(1, #nxt)])
    end
})

SS_Product({
    class = 'trashseat',
    price = 2000,
    name = 'Chairs',
    description = "Can be sat on",
    model = 'models/props_c17/furniturechair001a.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        local nxt = {}

        for k, v in pairs(trashlist) do
            if ChairOffsets[v] then
                table.insert(nxt, v)
            end
        end

        e = makeTrash(ply, nxt[math.random(1, #nxt)])
    end
})

SS_Product({
    class = 'trashtheater',
    price = 8000,
    name = 'Medium Theater Screen',
    description = "Create your own private theater anywhere! You'll remain owner even if you walk away.",
    model = 'models/props_phx/rt_screen.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_theater")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        timer.Simple(0, function()
            timer.Simple(0.001, function()
                makeTrashTheater(ply, self.model)
            end)
        end)
    end
})

SS_Product({
    class = 'trashtheatertiny',
    price = 4000,
    name = "Tiny Theater Screen",
    description = "Create your own private theater anywhere! You'll remain owner even if you walk away.",
    model = "models/props_c17/tv_monitor01.mdl",
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_theater")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        timer.Simple(0, function()
            timer.Simple(0.001, function()
                makeTrashTheater(ply, self.model)
            end)
        end)
    end
})

SS_Product({
    class = 'trashtheaterbig',
    price = 16000,
    name = 'Large Theater Screen',
    description = "Create your own private theater anywhere! You'll remain owner even if you walk away.",
    model = "models/hunter/plates/plate1x2.mdl",
    material = "tools/toolsblack",
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        for k, v in pairs(ents.FindByClass("prop_trash_theater")) do
            if v:GetOwnerID() == ply:SteamID() then
                v:Remove()
            end
        end

        --Delay 1 tick
        timer.Simple(0, function()
            timer.Simple(0.001, function()
                makeTrashTheater(ply, self.model)
            end)
        end)
    end
})
-- TODO finish this, make env_projectedtexture when in the theater
-- SS_Product({
--     class = 'trashtheaterprojector',
--     price = 640,
--     name = 'Projector Theater',
--     description = "Create your own private theater anywhere! You'll remain owner even if you walk away.",
--     model = "models/dav0r/camera.mdl",
--     OnBuy = function(self, ply)
--         for k, v in pairs(ents.FindByClass("prop_trash_theater")) do
--             if v:GetOwnerID() == ply:SteamID() then
--                 v:Remove()
--             end
--         end
--         --Delay 1 tick
--         timer.Simple(0, function()
--             timer.Simple(0.001, function()
--                 if tryMakeTrash(ply) then
--                     makeTrashTheater(ply, self.model)
--                 else
--                     ply:SS_GivePoints(self.price)
--                 end
--             end)
--         end)
--     end
-- })


SS_Heading("Defense")

SS_Product({
    class = 'prop_autoturret',
    price = 1000,
    name = 'Auto Turret',
    description = "Automatically shoots anything in front of it. Needs to be refilled with ammo. Can Carry up to 800 Rounds",
    model = 'models/weapons/w_irifle.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        local e = ents.Create("prop_autoturret")
        local pos = ply:GetPos() + (Vector(ply:GetAimVector().x, ply:GetAimVector().y, 0):GetNormalized() * 50) + Vector(0, 0, 10)
        e:SetPos(pos)
        e:SetAngles(Angle(0, math.random(0, 360), 0))
        e:Spawn()
        e:Activate()

    end
})

SS_Product({
    class = 'autoturret_ammo',
    price = 2000,
    name = 'Auto Turret Ammo x50',
    description = "Drop it on an Auto Turret to fill its Ammo by 50",
    model = 'models/items/boxmrounds.mdl',
    CannotBuy = CannotBuyTrash,
    OnBuy = function(self, ply)
        local e = ents.Create("autoturret_ammo")
        local pos = ply:GetPos() + (Vector(ply:GetAimVector().x, ply:GetAimVector().y, 0):GetNormalized() * 50) + Vector(0, 0, 10)
        e:SetPos(pos)
        e:SetAngles(Angle(0, math.random(0, 360), 0))
        e:Spawn()
        e:Activate()
    end
})
