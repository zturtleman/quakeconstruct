print("Loaded lua_healspot\n")

downloader.add("lua/entities/lua_healspot/cl_init.lua")

function ENT:Initialized()
	self.nextgive = 0
	
	self.Entity:SetMins(Vector(-25,-25,0))
	self.Entity:SetMaxs(Vector(25,25,10))
	self.Entity:SetClip(1)
	self.Entity:SetContents(CONTENTS_TRIGGER)
	self.Entity:SetTrType(TR_STATIONARY)
	self.Entity:SetSvFlags(SVF_BROADCAST)
	
	self.respawning = false
	
	self:SetDelay(1000)
end

function ENT:SetDelay(d)
	self.delay = d
	self.net.delay = d
end

function ENT:Removed()

end

function ENT:Think()

end

function ENT:Affect(other)
	other:SetHealth(other:GetHealth() + 10)
	self.nextgive = LevelTime() + self.delay
	
	self.Entity:AddEvent(1)
end

function ENT:CanEffect(other,trace)
	if(other:IsPlayer() == false) then return false end
	if(self.nextgive > LevelTime()) then return false end
	return true
end

function ENT:Touch(other,trace)
	if(other != nil and self:CanEffect(other,trace)) then
		self:Affect(other)
	end
end