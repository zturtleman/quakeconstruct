local flaretex = CreateShader("f",[[
{
	{
		map gfx/misc/flare.tga
		blendFunc add
		rgbGen entity
		alphaGen entity
	}
}
]])

local white = CreateShader("f",[[
{
	{
		map $whiteimage
		blendFunc add
		rgbGen entity
		alphaGen entity
	}
}
]])

local jshd = CreateShader("f",[[{
     nomipmaps
     cull disable
     {
		map models/mapobjects/jets/jet_1.tga
                blendFunc add
                tcmod scale  .5  1
                tcmod scroll 6 0
                rgbGen entity
	 }
}]])

local regen = LoadSound("sound/items/regen.wav")

function ENT:Initialized()
	self.model = LoadModel("models/mapobjects/jets/jets01.md3")
	self.scaletime = 0
	self.resettime = 0
end

function ENT:Scale()
	local s = .05
	if(self.scaletime > LevelTime()) then
		local dt = (self.scaletime - LevelTime()) / 200
		s = s + (1 - s)*dt
	end
	return s
end

function ENT:SideJet(pos,angle,scale)
	local p = Vectorv(pos)
	p.x = p.x + math.cos(angle/57.3)*-10
	p.y = p.y + math.sin(angle/57.3)*-10
	
	self.ref:SetPos(p)
	self.ref:SetAngles(Vector(90,angle,0))
	self.ref:Scale(Vector(.1,.1,scale))
	self.ref:Render()
end

function ENT:Ring(pos,o,scale)
	self:SideJet(pos,o,scale)
	self:SideJet(pos,o+90,scale)
	self:SideJet(pos,o+180,scale)
	self:SideJet(pos,o+270,scale)
end

function ENT:ResetDT()
	if(self.resettime < LevelTime()) then return 1 end
	return 1 - (self.resettime - LevelTime()) / self.net.delay
end

function ENT:Color()
	local r = 1
	local g = 1
	local b = 1
	
	if(self.resettime > LevelTime()) then
		local dt = self:ResetDT()
		g = dt/2
		b = dt/2
	else
		b = 0.2
		r = 0.2
	end

	return r,g,b,1
end

function ENT:DrawModel(active)
	local pos = self.Entity:GetPos()

	self.ref = RefEntity()
	self.ref:SetShader(jshd)
	self.ref:SetColor(self:Color())
	self.ref:SetPos(pos)
	self.ref:SetModel(self.model)
	self.ref:SetAngles(Vector(0,LevelTime()/6,0))
	self.ref:Scale(Vector(1,1,self:Scale()))
	
	self.ref:Render()
	
	local s = .2 + self:Scale()/4
	
	self:Ring(pos,0,s)
end

function ENT:Draw()
	self:DrawModel(true)
end

function ENT:OnEvent(id)
	self.scaletime = LevelTime() + 200
	self.resettime = LevelTime() + self.net.delay
	
	PlaySound(self.Entity,regen)
end