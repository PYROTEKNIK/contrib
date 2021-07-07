
AddCSLuaFile()

ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_OTHER

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"HandsIndex")
end

function ENT:Initialize()

	hook.Add( "OnViewModelChanged", self, self.ViewModelChanged )

	self:SetNotSolid( true )
	self:DrawShadow( false )
	self:SetTransmitWithParent( true ) -- Transmit only when the viewmodel does!
 
end

function ENT:DoSetup( ply, spec, index )
	index = index or 0
	-- Set these hands to the player
	self:SetHandsIndex(index)
	ply:SetHands( self,index )
	self:SetOwner( ply )

	-- Which hands should we use? Let the gamemode decide
	hook.Call( "PlayerSetHandsModel", GAMEMODE, spec or ply, self )

	-- Attach them to the viewmodel
	local vm = ( spec or ply ):GetViewModel( index )
	self:AttachToViewmodel( vm )

	vm:DeleteOnRemove( self )
	ply:DeleteOnRemove( self )

end

function ENT:GetPlayerColor()

	--
	-- Make sure there's an owner and they have this function
	-- before trying to call it!
	--
	local owner = self:GetOwner()
	if ( !IsValid( owner ) ) then return end
	if ( !owner.GetPlayerColor ) then return end

	return owner:GetPlayerColor()

end

function ENT:ViewModelChanged( vm, old, new )

	-- Ignore other peoples viewmodel changes!
	if ( vm:GetOwner() != self:GetOwner() ) then return end
	if ( self:GetParent() != vm ) then return end
	
	self:AttachToViewmodel( vm )
	


end



local function HideBone(ent,bone)
	local bm = Matrix()
	bm:SetTranslation(Vector(0,0,0))
	bm:Scale(Vector(1,1,1)*0.01)
	ent:SetBoneMatrix(bone,bm)
	for k,v in pairs(ent:GetChildBones( bone ))do
		HideBone(ent,v) 
	end
end


function ENT:SetHideLeft()
	if(self.BoneCallback)then self:RemoveCallback("BuildBonePositions",self.BoneCallback) end
	self.BoneCallback = self:AddCallback( "BuildBonePositions", function( hands, numbones )
		local vsf = hands:GetHandsIndex() == 0 and "" or self:GetHandsIndex()
		local wep = hands:GetOwner():GetActiveWeapon()
		if(IsValid(wep) and (wep["ViewModelHideLArm"..vsf] or true))then
			
		local pfx = "L"
		local bone = hands:LookupBone("ValveBiped.Bip01_"..pfx.."_UpperArm")
		if(bone)then
			HideBone(hands,bone)
		end
		end
	end )
end

function ENT:Think()
	self:SetHideLeft()
end

function ENT:AttachToViewmodel( vm )
	self:AddEffects( EF_BONEMERGE )
	self:SetParent( vm )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetPos( vector_origin )
	self:SetAngles( angle_zero )
end
