AddCSLuaFile()

local em = FindMetaTable("Entity")
local pm = FindMetaTable("Player")
local wm = FindMetaTable("Weapon")


em.BasedSetWeaponModel = em.BasedSetWeaponModel or em.SetWeaponModel

pm.BasedSetHands = pm.BasedSetHands or pm.SetHands
pm.BasedGetHands = pm.BasedGetHands or pm.GetHands

wm.BasedSendWeaponAnim = wm.BasedSendWeaponAnim or wm.SendWeaponAnim

timer.Simple(0,function()
local wb = weapons.GetStored("weapon_base")

function wb:Holster( new )
	return hook.Run( "OnWeaponHolster", self:GetOwner(),self,new ) or true
end

function wb:Deploy()
	return hook.Run( "OnWeaponDeploy", self:GetOwner(), self ) or true
end
end) 



function wm:SendWeaponAnim(act,viewmodel)
    assert(isnumber(viewmodel) or viewmodel == nil,"Expected number, got "..type(viewmodel))
    if(viewmodel)then
        local ply = self:GetOwner()
        local vm = ply:GetViewModel( viewmodel )
        vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(act))
    else
        self:BasedSendWeaponAnim(act)
    end
end
function em:SetWeaponModel(modelname,wep)
    self:BasedSetWeaponModel( modelname, wep )
    self:GetOwner():SetHandsVisible(self:ViewModelIndex(), IsValid(wep) and modelname != "" and modelname != nil)
end

function em:GetHandsModel()
    
    if(self:ViewModelIndex() != nil and IsValid(self:GetOwner()))then
        self:GetOwner():GetHands(self:ViewModelIndex())
        return 
    end
end

function pm:GetNumHands()
    local c = 0
    for i=0,2 do
        local vst = i == 0 and "" or i
        if(IsValid(self:GetHands(i)))then
            c = c + 1
        end
    end
    return c
end

hook.Add("OnWeaponDeploy","SetupViewmodels",function(ply,wep)

end)

hook.Add("OnWeaponHolster","SetupViewmodels",function(ply,wep,new)

end)

hook.Add("PlayerPostThink","FixupVMs",function(ply)
    local wep= ply:GetActiveWeapon()
    for vmid = 1,2 do
        local vst = vmid == 0 and "" or vmid
        local vmodel = wep["ViewModel"..vst] or (vmid == 0 and new:GetWeaponViewModel())
        if(vmodel == false)then vmodel = nil end
        if(vmodel == "")then vmodel = nil end
        local wm = vmodel != "" and wep
        if(ply:GetViewModel( vmid ).LastWeaponModel != wm)then
        ply:GetViewModel( vmid ):SetWeaponModel( vmodel or "", wm )
        ply:GetViewModel( vmid ).LastWeaponModel =  wm
        end
    end

end)

function pm:SetupHands()
    self:SetHandsVisible(0,true)
end

function pm:SetHandsVisible(vmid,on)
    if(SERVER)then
    vmid = vmid or 0
    if(on)then
        local hands = self:GetHands(vmid)
        if(!IsValid(hands))then
            local newhands = ents.Create("gmod_hands")
            newhands:SetOwner(self)
            newhands:DoSetup( self, nil, vmid )
            newhands:Spawn()
            hands = newhands
        end
    else
        local hands = self:GetHands(vmid)
        if(IsValid(hands))then
            hands:Remove()
            self:SetHands(NULL,vmid)
        end
    end
    end
end


function pm:SetHands(ent,vmid)
    vmid = vmid or 0
    self:SetNWEntity("HandsEnt"..vmid,ent)
end


function pm:GetHands(vmid)
    vmid = vmid or 0
    return self:GetNWEntity("HandsEnt"..vmid)
end


timer.Simple(0,function()
local GM = gmod.GetGamemode()
function GM:PostDrawViewModel( ViewModel, Player, Weapon )

	if ( !IsValid( Weapon ) ) then return false end

	if ( Weapon.UseHands || !Weapon:IsScripted() ) then

        local hands = Player:GetHands(ViewModel:ViewModelIndex())
		if ( IsValid( hands ) && IsValid( hands:GetParent() ) and hands:GetParent() == ViewModel) then

			if ( not hook.Call( "PreDrawPlayerHands", self, hands, ViewModel, Player, Weapon ) ) then
                local vms = ViewModel:ViewModelIndex() == 0 and "" or ViewModel:ViewModelIndex()
                local flip = Weapon["ViewModelFlip"..vms]
				if ( flip ) then render.CullMode( MATERIAL_CULLMODE_CW ) end
               
				hands:DrawModel()
                hands:SetupBones()
				render.CullMode( MATERIAL_CULLMODE_CCW )

			end

			hook.Call( "PostDrawPlayerHands", self, hands, ViewModel, Player, Weapon )

		end

	end

	player_manager.RunClass( Player, "PostDrawViewModel", ViewModel, Weapon )

	if ( Weapon.PostDrawViewModel == nil ) then return false end
	return Weapon:PostDrawViewModel( ViewModel, Weapon, Player )

end
end)
