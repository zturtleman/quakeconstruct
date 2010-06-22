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
	
	self.autorestock = 45000
	self.storedhp = 150
	self:SetDelay(180)
	self.net.remain = self.storedhp
	self.net.restock = 35000
	self.net.hp = self.storedhp
	self.restocking = false
end

function ENT:SetDelay(d)
	self.delay = d
	self.net.delay = d
end

function ENT:Removed()

end

function ENT:Think()
	if(self.net.remain < self.storedhp) then
		self.net.remain = self.storedhp
		self.Entity:AddEvent(3)
		self.restocking = false
		print("Restocked\n")
	end
	self.Entity:SetNextThink(LevelTime() + self.autorestock)
end

function ENT:Affect(other)
	local hp = other:GetHealth()
	other:SetHealth(hp + 5)
	if(hp + 10 > 100) then
		other:SetHealth(100)
	end
	
	self.net.remain = self.net.remain - 5
	if(self.net.remain <= 0) then
		print("We're out, restock in " .. self.net.restock/1000 .. " seconds\n")
		self.Entity:SetNextThink(LevelTime() + self.net.restock)
		self.Entity:AddEvent(2)
		self.restocking = true
		return
	end
	
	self.nextgive = LevelTime() + self.delay
	
	self.Entity:AddEvent(1)
end

function ENT:CanEffect(other,trace)
	if(self.restocking) then return false end
	if(other:GetHealth() <= 0) then return false end
	if(other:IsPlayer() == false) then return false end
	if(self.nextgive > LevelTime()) then return false end
	if(other:GetHealth() + 5 > 100) then return false end
	return true
end

function ENT:Touch(other,trace)
	if(other != nil and self:CanEffect(other,trace)) then
		self.Entity:SetNextThink(LevelTime() + self.autorestock)
		self:Affect(other)
	end
end