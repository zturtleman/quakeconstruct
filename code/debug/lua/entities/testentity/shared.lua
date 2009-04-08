print("Loaded Shared\n")
if(SERVER) then
	//__DL_BLOCK
	downloader.add("lua/entities/spawnpad/shared.lua")
	print("Loaded Init\n")
	local function writeVector(msg,v)
		message.WriteFloat(msg,v.x)
		message.WriteFloat(msg,v.y)
		message.WriteFloat(msg,v.z)
	end

	function ENT:Initialized()
		self.Entity:SetNextThink(-1)
		self.Entity:SetTrType(TR_STATIONARY)
		self.Entity:SetMins(Vector(-5,-5,-5))
		self.Entity:SetMaxs(Vector(5,5,5))
		self.Entity:SetClip(0)
	end

	function ENT:Removed()
		print("Ent Removed\n")
	end

	function ENT:Think()

	end

	function ENT:Touch(other,trace)

	end
	//__DL_UNBLOCK
elseif(CLIENT) then
	print("Loaded CL_Init\n")

	local mach = LoadModel("models/weapons2/machinegun/machinegun.md3")
	local sphere = LoadModel("models/powerups/health/medium_sphere.md3")

	function ENT:Draw()
		local pos = self.Entity:GetPos()
		local tr = TraceLine(pos,pos - Vector(0,0,9999))
	
		self.rot = self.rot or 0
		self.rot = self.rot + 1
		local pos = self.Entity:GetPos()
		local gun = RefEntity()
		gun:AlwaysRender(true)
		gun:SetModel(sphere)
		gun:SetPos(tr.endpos)
		gun:SetAngles(Vector(0,self.rot,0))
		gun:Scale(Vector(2,2,.2))
		gun:Render()
	end
end