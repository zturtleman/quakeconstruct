print("Loaded CL_Init\n")

local mach = LoadModel("models/weapons2/machinegun/machinegun.md3")

function ENT:Draw()
	self.rot = self.rot or 0
	self.rot = self.rot + 1
	local pos = self.Entity:GetPos()
	local gun = RefEntity()
	gun:SetModel(mach)
	gun:SetPos(pos)
	gun:SetAngles(Vector(0,self.rot,0))
	gun:Render()
end