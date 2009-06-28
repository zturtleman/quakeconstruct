print("Loaded Base_Item\n")

downloader.add("lua/entities/lua_base_item/cl_init.lua")

function ENT:Initialized()
	self.Entity:SetNextThink(LevelTime() + 6000)
	
	self.Entity:SetMins(Vector(-15,-15,0))
	self.Entity:SetMaxs(Vector(15,15,20))
	self.Entity:SetContents(CONTENTS_TRIGGER)
	self.Entity:SetClip(CONTENTS_SOLID)
	self.Entity:SetBounce(.7)
	self.Entity:SetSvFlag(SVF_USE_CURRENT_ORIGIN)
	
	Timer(.03,function()
		self.Entity:SetPos(self.Entity:GetPos() + Vector(0,0,0))
		self.Entity:SetVelocity(VectorNormalize(VectorRandom())*200)
		self.Entity:SetTrType(TR_GRAVITY)
	end)
	
	self.net.fadetime = 1000
	self:SetType("item_armor_shard")
end

function ENT:SetType(t)
	if(type(t) == "string") then
		t = FindItemByClassname(t)
	end
	self.net.type = t
end

function ENT:Removed()

end

function ENT:Think()
	if(self.removing) then
		self.Entity:Remove()
		return
	end
	self.removing = true
	self.net.remove = LevelTime() + self.net.fadetime
	self.Entity:SetNextThink(LevelTime() + self.net.fadetime)
end

function ENT:ShouldPickup(other,trace)
	return other:IsPlayer()
end

function ENT:Affect(other)
	other:SetArmor(other:GetArmor() + 2)
end

function ENT:Touch(other,trace)
	if(other != nil and self:ShouldPickup(other,trace)) then
		AddEvent(other,EV_ITEM_PICKUP,(self.net.type or 1))
		self:Affect(other)
		self.Entity:Remove()
	end
end