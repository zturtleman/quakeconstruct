print("Loaded CL_Init\n")

local mach = LoadModel("models/weapons2/machinegun/machinegun.md3")
local sphere = LoadModel("models/powerups/health/medium_sphere.md3")

function ENT:Draw()
	self.rot = self.rot or 0
	self.rot = self.rot + 1
	local pos = self.Entity:GetPos()
	local gun = RefEntity()
	gun:SetModel(sphere)
	gun:SetPos(pos)
	gun:SetAngles(Vector(0,self.rot,0))
	gun:Scale(Vector(2,2,2))
	gun:Render()
end