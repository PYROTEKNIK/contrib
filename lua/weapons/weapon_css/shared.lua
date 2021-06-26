AddCSLuaFile()
include("conversion.lua")

SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false
SWEP.Primary.DefaultClip = 5
SWEP.Primary.CycleTime = 0.2
SWEP.Primary.ClipSize = 5
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Spawnable = true
SWEP.Category = "Counter-Strike:Source"
SWEP.Sounds = {}

function SWEP:IsMoving()
    local ply = self:GetOwner()

    return ply:GetVelocity():Length() > 45
end
 
function SWEP:GetInaccuracy()
    local str = "Inaccuracy"
    local ply = self:GetOwner()
    local tp = "Stand"

    if (not ply:OnGround()) then
        tp = "Jump"
    end

    if (ply:GetMoveType() == MOVETYPE_LADDER) then
        tp = "Ladder"
    end

    if (self:IsMoving()) then
        tp = "Move"
    end

    if (ply:Crouching()) then
        tp = "Crouch"
    end

    str = str .. tp

    if (self:GetAiming()) then
        str = str .. "Alt"
    end

    return self.Primary.Accuracy[str] or 0
end

function SWEP:GetRecoveryTime()
    local ply = self:GetOwner()

    if (ply:OnGround()) then
        if (ply:Crouching()) then return (self.Primary.Accuracy.RecoveryTimeCrouch) or 0 end

        return (self.Primary.Accuracy.RecoveryTimeStand) or 0
    end

    return 0
end

function SWEP:AddSpread()
    self.TrackedSpread = self.TrackedSpread or 0
    self.TrackedSpread = math.Clamp(self.TrackedSpread + (self.Primary.Accuracy.InaccuracyFire or 0), 0, self:GetMaxSpread())
end

function SWEP:GetMaxSpread()
    return self.InaccuracyMove or 0
end

function SWEP:Think()
    local rate = (self:GetMaxSpread() / self:GetRecoveryTime())

    if (self:GetNextPrimaryFire() > CurTime()) then
        rate = rate / 10
    end

    local delta = FrameTime() * rate
    self.TrackedSpread = math.Clamp((self.TrackedSpread or 0) - (delta), 0, self:GetMaxSpread())
end

function SWEP:GetSpread()
    return math.max((self.Primary.Accuracy.Spread or 0) + self:GetInaccuracy() + (self.TrackedSpread or 0), 0)
end

function SWEP:GetKick()
    return self.Primary.Accuracy.InaccuracyFire
end

function SWEP:GetAimVector()
    local aimv = self.Owner:GetAimVector():Angle()
    aimv = aimv + self.Owner:GetViewPunchAngles()
    aimv = aimv:Forward()

    return aimv
end

function SWEP:ShootBullet(damage, num_bullets, aimcone, ammo_type, force, tracer)
    local bullet = {}
    bullet.Num = num_bullets
    bullet.Src = self.Owner:GetShootPos() -- Source
    bullet.Dir = self:GetAimVector() -- Dir of bullet
    bullet.Spread = Vector(aimcone, aimcone, 0) -- Aim Cone
    bullet.Tracer = tracer or 5 -- Show a tracer on every x bullets
    bullet.Force = force or 1 -- Amount of force to give to phys objects
    bullet.Damage = damage
    bullet.Attacker = self.Owner
    bullet.AmmoType = ammo_type or self.Primary.Ammo
    self:FireBullets(bullet)
    self:ShootEffects()
end

function SWEP:PrimaryAttack()
    -- Make sure we can shoot first
    if (not self:CanPrimaryAttack()) then return end

    -- Play shoot sound
    if (self.Sounds.single_shot) then
        self:EmitSound(self.Sounds.single_shot)
    end
 
    local kick = Vector(0, -1, self:GetKick()):Angle().pitch
    kick = math.NormalizeAngle(kick)

    if (not self.Owner:IsNPC()) then
        self.Owner:ViewPunch(Angle(kick, math.Rand(-kick / 2, kick / 2), 0))
    end 

    self:AddSpread()
    self:ShootBullet(self.Damage, self.Bullets, self:GetSpread(), self.Primary.Ammo)
    self:TakePrimaryAmmo(1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.CycleTime)
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Aiming")
end
 
function SWEP:SecondaryAttack()
    if (not self.CanScope) then return end
    self:SetAiming(not self:GetAiming())

    if (self.Sounds.special3) then
        self:EmitSound(self.Sounds.special3)
    end

    self:SetNextSecondaryFire(CurTime() + 0.1)
end

function SWEP:TranslateFOV(fov)
    if (self:GetAiming()) then return 30 end
end 
function SWEP:AdjustMouseSensitivity()
    if (self:GetAiming()) then return 0.2 end
end
 


function SWEP:DrawHUDBackground()
    if (not self:GetAiming()) then return end
    local x, y = ScrW() / 2, ScrH() / 2
    local scopemat = Material("sprites/scope_arc")
    local heightgap = 32
    local size = (ScrH()) / 2 - heightgap
    surface.SetMaterial(scopemat)
    surface.SetDrawColor(Color(0, 0, 0, 255))
    surface.DrawRect(0, 0, ScrW(), heightgap)
    surface.DrawRect(0, ScrH() - heightgap, ScrW(), heightgap)
    surface.DrawRect(0, heightgap, ScrW() / 2 - size, ScrH() - heightgap)
    surface.DrawRect(ScrW() / 2 + size, heightgap, ScrW() / 2 - size, ScrH() - heightgap)
    surface.DrawRect(ScrW() / 2 - 1, 0, 1, ScrH())
    surface.DrawRect(0, ScrH() / 2, ScrW(), 1)
    surface.DrawTexturedRectUV(x, y, size, size, 0, 0, 1, 1)
    surface.DrawTexturedRectUV(x - size, y, size, size, 1, 0, 0, 1)
    surface.DrawTexturedRectUV(x, y - size, size, size, 0, 1, 1, 0)
    surface.DrawTexturedRectUV(x - size, y - size, size, size, 1, 1, 0, 0)
end

SWEP.CrosshairInfo = {
    file = "sprites/crosshairs",
    x = 0,
    y = 48,
    width = 24,
    height = 24
}

function SWEP:DoDrawCrosshair(x, y)
    local clr = NamedColor("FGColor")
    local ply = self:GetOwner()
    local dir = self:GetAimVector() + ply:EyeAngles():Right() * self:GetSpread()
    
    local data2D = (EyePos() + (dir * 5)):ToScreen() -- Gets the position of the entity on your screen
    local r

    if (data2D.visible) then
        r = Vector(x, y, 0):Distance(Vector(data2D.x, data2D.y, 0))
        self.LerpCrosshair = Lerp(0.1,self.LerpCrosshair or r,r)
        r = self.LerpCrosshair

        surface.DrawCircle(x - 0.5, y + 0.5, r, clr.r, clr.g, clr.b, clr.a or 255)
    end

    if (self:GetAiming()) then return true end
    if (not self.CrosshairInfo) then return true end
    local info = self.CrosshairInfo
    local w, h = info.width, info.height

    if (r) then
        w, h = r, r
    end

    local mat = Material(info.file)
    local tw, th = mat:Width(), mat:Height()
    local uvx, uvy = info.x / tw, info.y / th
    local uvw, uvh = info.width / tw, info.height / th
    local w, h = info.width, info.height
    x = x - w / 2
    y = y - w / 2
    surface.SetMaterial(mat)
    surface.SetDrawColor(clr)
    surface.DrawTexturedRectUV(x, y, w, h, uvx, uvy, uvw, uvh)

    return true
end


-----------------------------------------

if (CLIENT) then
    surface.CreateFont("CSweaponsSmall", {
        font = "csd", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
        extended = true,
        size = 13,
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
    })

    language.Add("Cstrike_WPNHUD_HE_Grenade", "High-Explosive Grenade")
    language.Add("Cstrike_WPNHUD_Flashbang", "FLASHBANG")
    language.Add("Cstrike_WPNHUD_Smoke_Grenade", "SMOKE GRENADE")
    language.Add("Cstrike_WPNHUD_AK47", "AK-47")
    language.Add("Cstrike_WPNHUD_Aug", "BULLPUP")
    language.Add("Cstrike_WPNHUD_AWP", "MAGNUM SNIPER RIFLE")
    language.Add("Cstrike_WPNHUD_DesertEagle", ".50 DESERT EAGLE")
    language.Add("Cstrike_WPNHUD_Elites", ".40 DUAL ELITES")
    language.Add("Cstrike_WPNHUD_Famas", "CLARION 5.56")
    language.Add("Cstrike_WPNHUD_FiveSeven", "ES FIVE-SEVEN")
    language.Add("Cstrike_WPNHUD_G3SG1", "D3/AU-1")
    language.Add("Cstrike_WPNHUD_Galil", "IDF DEFENDER")
    language.Add("Cstrike_WPNHUD_Glock18", "9X19MM SIDEARM")
    language.Add("Cstrike_WPNHUD_Knife", "KNIFE")
    language.Add("Cstrike_WPNHUD_M249", "M249")
    language.Add("Cstrike_WPNHUD_m3", "LEONE 12 GAUGE SUPER")
    language.Add("Cstrike_WPNHUD_M4A1", "MAVERICK M4A1 CARBINE")
    language.Add("Cstrike_WPNHUD_MAC10", "INGRAM MAC-10")
    language.Add("Cstrike_WPNHUD_MP5", "K&M SUB-MACHINE GUN")
    language.Add("Cstrike_WPNHUD_P228", "228 COMPACT")
    language.Add("Cstrike_WPNHUD_P90", "ES C90")
    language.Add("Cstrike_WPNHUD_Scout", "SCHMIDT SCOUT")
    language.Add("Cstrike_WPNHUD_SG550", "KRIEG 550 COMMANDO")
    language.Add("Cstrike_WPNHUD_SG552", "KRIEG 552")
    language.Add("Cstrike_WPNHUD_Tmp", "SCHMIDT MACHINE PISTOL")
    language.Add("Cstrike_WPNHUD_UMP45", "K&M UMP45")
    language.Add("Cstrike_WPNHUD_USP45", "K&M .45 TACTICAL")
    language.Add("Cstrike_WPNHUD_xm1014", "LEONE YG1265 AUTO SHOTGUN")
    language.Add("Cstrike_WPNHUD_C4", "C4 EXPLOSIVE")
    language.Add("AMMO_TYPE_FLASHBANG_ammo", "Flashbang Grenades")
    language.Add("AMMO_TYPE_HEGRENADE_ammo", "High-Explosive Grenades")
    language.Add("AMMO_TYPE_SMOKEGRENADE_ammo", "Smoke Grenades")
    language.Add("BULLET_PLAYER_338MAG_ammo", ".338 Lapua Magnum")
    language.Add("BULLET_PLAYER_357SIG_ammo", ".357 SIG")
    language.Add("BULLET_PLAYER_45ACP_ammo", ".45 ACP")
    language.Add("BULLET_PLAYER_50AE_ammo", ".50 Action Express")
    language.Add("BULLET_PLAYER_556MM_ammo", ".556x45mm NATO")
    language.Add("BULLET_PLAYER_556MM_BOX_ammo", ".556x45mm NATO")
    language.Add("BULLET_PLAYER_57MM_ammo", "")
    language.Add("BULLET_PLAYER_762MM_ammo", ".762 MM")
    language.Add("BULLET_PLAYER_9MM_ammo", "9mm ")
    language.Add("BULLET_PLAYER_BUCKSHOT_ammo", "Buckshot")
end


--i didnt think you'd want a shit ton of extra files going in the weapons folder
local function MakeAmmo(ammo)
    CSS_AMMO = CSS_AMMO or {}
    if (CSS_AMMO[ammo]) then return end
    CSS_AMMO[ammo] = {}

    game.AddAmmoType({
        name = ammo,
        dmgtype = DMG_BULLET,
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 2000,
        minsplash = 10,
        maxsplash = 5
    })
end

local swept = SWEP
for k, fl in pairs(file.Find("weapons/weapon_css/guns/*", "LUA")) do
    local filetype = string.Explode(".", fl)[1]

    local class = string.Explode(".", fl)[1]

    _G.SWEP = {Base = "weapon_css",Primary={},Secondary={}}
    local script = "guns/"..fl
    AddCSLuaFile(script)
    include(script)

    weapons.Register(_G.SWEP,class)

    if(_G.SWEP.Primary.Ammo)then
        MakeAmmo(_G.SWEP.Primary.Ammo)
    end
    _G.SWEP = swept
    

end

//don't do anything after this or it'll probably break