﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Tab("Playermodels", "user_suit")
SS_Heading("Mods")

SS_Item({
    class = "skinner",
    price = 1000000,
    name = 'Skinner',
    description = "attach a new skin to your body (WIP)",
    model = 'models/maxofs2d/gm_painting.mdl',
    invcategory = "Mods",
    maxowned = 5,
    playermodelmod = true, 
    materialmod = true,
    configurable = {
        color = {
            max = 5
        },
        imgur = true, 
        submaterial = true,
    }
})

SS_Item({
    class = "inflater",
    price = 200000,
    name = 'Inflater',
    description = "make bones fatter or skeletoner. MULTIPLE CAN STACK",
    model = 'models/Gibs/HGIBS.mdl', --'models/Gibs/HGIBS_rib.mdl',
    material = 'models/debug/debugwhite',
    invcategory = "Mods",
    maxowned = 25,
    playermodelmod = true,
    bonemod = true,
    configurable = {
        scale = {
            min = Vector(0.5, 0.5, 0.5),
            max = Vector(1.5, 1.5, 1.5)
        },
        bone = true,
        scale_children = true
    }
})

SS_Item({
    class = "offsetter",
    price = 100000,
    name = 'Offsetter',
    description = "moves bones around by using advanced genetic modification",
    model = 'models/Gibs/HGIBS_rib.mdl',
    material = 'models/debug/debugwhite',
    invcategory = "Mods",
    maxowned = 25,
    playermodelmod = true,
    bonemod = true,
    configurable = {
        pos = {
            min = Vector(-8, -8, -8),
            max = Vector(8, 8, 8),
        },
        bone = true
    }
})

SS_Heading("Permanent")

SS_Item({
    class = "outfitter2",
    price = 2000000,
    name = 'Outfitter',
    description = "Allows wearing any model from workshop - type !outfitter",
    model = 'models/maxofs2d/logo_gmod_b.mdl',
    configurable_label = "Change Model",
    configurable_menu = function()
    RunConsoleCommand("outfitter")
    SS_ToggleMenu()
    end, 
    invcategory = "Playermodels",
    never_equip = true
}) 
 
if SERVER then
    timer.Create("syncoutfitter", 1, 0, function()
        for k, v in pairs(player.GetAll()) do
            if v:GetNWBool("oufitr") ~= v:SS_HasItem("outfitter2") then
                v:SetNWBool("oufitr", v:SS_HasItem("outfitter2"))
            end
        end
    end)
end

hook.Add("CanOutfit", "ps_outfitter", function(ply, mdl, wsid) return ply:GetNWBool("oufitr") end)

--cant find workshop plus i think it needs to be colorable
SS_PlayermodelItem({
    class = 'crusadermodel',
    price = 300000,
    name = 'Crusader',
    model = 'models/player/crusader.mdl',
    PlayerSetModel = function(self, ply)
        ply:Give("weapon_deusvult")
        ply:SelectWeapon("weapon_deusvult")
    end
})

SS_PlayermodelItem({
    class = 'jokermodel',
    price = 180000,
    name = 'The Joker',
    description = "Now yuo see...",
    model = 'models/player/bobert/aojoker.mdl',
    workshop = '400762901',
    PlayerSetModel = function(self, ply) end
})

SS_PlayermodelItem({
    class = 'minecraftmodel',
    price = 400064,
    name = 'Block Man',
    description = "A Minecraft player model capable of applying custom skins.",
    configurable_label = "Change Skin",
    configurable_menu = function()
        local mderma = Derma_StringRequest("Minecraft Skin Picker", "Enter an Imgur URL to change your Minecraft skin.", "", function(text)
            RunConsoleCommand("say", "!minecraftskin " .. text)
        end, function() end, "Change Skin", "Cancel")

        local srdx, srdy = mderma:GetSize()
        local mdermacredits = Label("Minecraft Skins by Chev for Swamp Servers", mderma)
        mdermacredits:Dock(BOTTOM)
        mdermacredits:SetContentAlignment(2)
        mderma:SetSize(srdx, srdy + 15)
        mderma:SetIcon("icon16/user.png")


    end,
    model = 'models/milaco/minecraft_pm/minecraft_pm.mdl',
    PlayerSetModel = function(self, ply) end
})

SS_PlayermodelItem({
    class = 'neckbeardmodel',
    price = 240000,
    name = 'Athiest',
    model = 'models/player/neckbeard.mdl',
    -- workshop = '853155677', -- Not using workshop because of pony editor built in neckbeard
    PlayerSetModel = function(self, ply)
        ply:Give("weapon_clopper")
        ply:SelectWeapon("weapon_clopper")
    end
})

SS_PlayermodelItem({
    class = 'ogremodel',
    price = 100000,
    name = 'Ogre',
    description = "IT CAME FROM THE SWAMP",
    model = 'models/player/pyroteknik/shrek.mdl',
    workshop = '314261589',
    PlayerSetModel = function(self, ply) end
})

SS_PlayermodelItem({
    class = 'ponymodel',
    price = 500000,
    name = 'Pony',
    description = "*boop*",
    model = 'models/ppm/player_default_base.mdl',
    configurable_label = "Customize Pony",
    configurable_menu = function() RunConsoleCommand("ppm_chared3") end,
    PlayerSetModel = function(self, ply)
        ply:Give("weapon_squee")
        ply:SelectWeapon("weapon_squee")
    end 
})
SS_Heading("One-Life, Unique")

SS_UniqueModelProduct({
    class = 'celestia',
    name = 'Sun Princess',
    model = 'models/mlp/player_celestia.mdl',
    workshop = '419173474',
    CanBuyStatus = function(self, ply)
        if not ply:SS_HasItem("ponymodel") then return "You must own the ponymodel to buy this." end
    end
})

SS_UniqueModelProduct({
    class = 'luna',
    name = 'Moon Princess',
    model = 'models/mlp/player_luna.mdl',
    workshop = '419173474',
    CanBuyStatus = function(self, ply)
        if not ply:SS_HasItem("ponymodel") then return "You must own the ponymodel to buy this." end
    end
})

SS_UniqueModelProduct({
    class = 'billyherrington',
    name = 'Billy Herrington',
    description = "Rest in peace Billy Herrington, you will be missed.",
    model = 'models/vinrax/player/billy_herrington.mdl',
    workshop = '1422933575',
    OnBuy = function(self, ply)
        if SERVER then
            ply:Give("weapon_billyh")
            ply:SelectWeapon("weapon_billyh")
        end
    end
})

SS_UniqueModelProduct({
    class = 'doomguy',
    name = 'Doomslayer',
    description = "They are rage, brutal, without mercy. But you. You will be worse. Rip and tear, until it is done.",
    model = 'models/pechenko_121/doomslayer.mdl',
    workshop = '2041292605', --This one didn't use a bin file...
    OnBuy = function(self, ply) end
})

-- SS_UniqueModelProduct({
-- 	class = 'ketchupdemon',
-- 	name = 'Mortally Challenged',
-- 	description = '"Demon" is an offensive term.',
-- 	model = 'models/momot/momot.mdl'
-- })
SS_UniqueModelProduct({
    class = 'fatbastard',
    name = 'Fat Kid',
    description = "YEAR OF FAT KID",
    model = 'models/obese_male.mdl',
    workshop = '2467219933'
})

SS_UniqueModelProduct({
    class = 'fox',
    name = 'Furball',
    description = "Furries are proof that God has abandoned us.",
    model = 'models/player/ztp_nickwilde.mdl',
    workshop = '663489035'
})

SS_UniqueModelProduct({
    class = 'garfield',
    name = 'Lasagna Cat',
    description = "I gotta have a good meal.",
    model = 'models/garfield/garfield.mdl'
})

SS_UniqueModelProduct({
    class = 'realgarfield',
    name = 'Real Cat',
    description = "Garfield gets real.",
    model = 'models/player/yevocore/garfield/garfield.mdl',
    workshop = '905415234',
})

SS_UniqueModelProduct({
    class = 'hitler',
    name = 'Der Fuhrer',
    model = 'models/minson97/hitler/hitler.mdl',
    workshop = '1983866955',
})

SS_UniqueModelProduct({
    class = 'kermit',
    name = 'Frog',
    model = 'models/player/kermit.mdl',
    workshop = '485879458',
})

SS_UniqueModelProduct({
    class = 'darthkermit',
    name = 'Darth Frog',
    model = 'models/gonzo/lordkermit/lordkermit.mdl',
    workshop = '1408171201',
})

-- SS_UniqueModelProduct({
-- 	class = 'kim',
-- 	name = 'Rocket Man',
-- 	description = "Won't be around much longer.",
-- 	model = 'models/player/hhp227/kim_jong_un.mdl'
-- })
SS_UniqueModelProduct({
    class = 'minion',
    name = 'Comedy Pill',
    model = 'models/player/minion/minion5/minion5.mdl',
    workshop = '518592494',
})

-- SS_UniqueModelProduct({
-- 	class = 'moonman',
-- 	name = 'Mac Tonight',
-- 	model = 'models/player/moonmankkk.mdl'
-- })
SS_UniqueModelProduct({
    class = 'nicestmeme',
    name = 'Thanks, Lori.',
    description = 'John, haha. Where did you find this one?',
    model = 'models/player/pyroteknik/banana.mdl',
    workshop = '558307075',
})

SS_UniqueModelProduct({
    class = 'pepsiman',
    name = 'Pepsiman',
    description = 'DRINK!',
    model = 'models/player/real/prawnmodels/pepsiman.mdl',
    workshop = '1083310915',
})

SS_UniqueModelProduct({
    class = 'rick',
    name = 'Intellectual',
    description = 'To be fair, you have to have a very high IQ to understand Rick and Morty.',
    model = 'models/player/rick/rick.mdl',
    workshop = '557711922',
})

SS_UniqueModelProduct({
    class = 'trump',
    name = 'God Emperor',
    description = "Donald J. Trump is the President-for-life of the United States of America, destined savior of Kekistan, and slayer of Hillary the Crooked.",
    model = 'models/omgwtfbbq/the_ship/characters/trump_playermodel.mdl',
    workshop = '725320580'
})

--cant find workshop for it
-- SS_UniqueModelProduct({
--     class = 'weeaboo',
--     name = 'Weeaboo Trash',
--     description = "Anime is proof that God has abandoned us.",
--     model = 'models/tsumugi.mdl'
-- })
-- TODO: make them download/mount on the server, make sure there is not a lua backdoor!
SS_UniqueModelProduct({
    class = 'jokerjoker',
    name = 'Joker from JOKER',
    description = "Joker from JOKER",
    model = 'models/kemot44/models/joker_pm.mdl',
    workshop = "1899345304",
})
-- SS_UniqueModelProduct({
--     class = 'sans',
--     name = 'Sans Undertale',
--     description = "haha",
--     model = 'models/sirsmurfzalot/undertale/smh.mdl',
--     workshop = "1591120487",
-- })