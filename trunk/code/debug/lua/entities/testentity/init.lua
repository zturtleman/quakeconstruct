print("Loaded Init\n")

function ENT:Initialized()
	print("Ent Init\n")
	self.Entity:SetNextThink(-1)
	self.hp = 35
	self.nextheal = 0
end

function ENT:Removed()
	print("Ent Removed\n")
end

function ENT:Think()
	self.hp = 35

	local function writeVector(msg,v)
		message.WriteFloat(msg,v.x)
		message.WriteFloat(msg,v.y)
		message.WriteFloat(msg,v.z)
	end
	
	local msg = Message()
	message.WriteString(msg,"testentity")
	writeVector(msg,self.Entity:GetPos())
	writeVector(msg,self.Entity:GetPos())
	message.WriteLong(msg,1)
	
	for k,v in pairs(GetEntitiesByClass("player")) do
		SendDataMessage(msg,v,"itempickup")
	end
	
	self.nextheal = 0
end

function ENT:Touch(other,trace)
	if(other != nil and other:IsPlayer() and self.nextheal < LevelTime()) then
		--print("Ent Touched\n")
		if(self.hp > 0) then
			local hp = other:GetHealth()
			if(hp < 100) then
				other:SetHealth(hp + 1)
				self.hp = self.hp - 1
				self.nextheal = LevelTime() + 100
			end
			if(self.hp <= 0) then
				self.Entity:SetNextThink(LevelTime() + 4000)
			end
		end
		--self.Entity:Remove()
	end
end