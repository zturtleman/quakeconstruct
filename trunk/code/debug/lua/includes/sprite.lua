local SpriteT = {}
local aspect = (1 + ((640 - 480) / 640))
local refdef = {}
refdef.x = 0
refdef.y = 0
refdef.width = 640
refdef.height = 480
refdef.origin = Vector(0,0,0)
refdef.angles = Vector(0,0,0)
refdef.fov_y = 30
refdef.fov_x = (refdef.fov_y * aspect)

function SpriteT:Init()
	self.ref = RefEntity()
	self.ref:SetType(RT_SPRITE)
	self.ref:SetRadius(10)
	self.ref:SetRotation(0)
	self.ref:SetColor(1,1,1,1)
	self.rad = 10
	self.rot = 0
	self.col = {1,1,1,1}
	self.shd = 0
	self.x = 0
	self.y = 0
end

function SpriteT:SetColor(r,g,b,a)
	self.ref:SetColor(r,g,b,a)
	self.col = {r,g,b,a}
end

function SpriteT:GetColor()
	return self.col
end

function SpriteT:SetPos(x,y)
	self.x = x
	self.y = y
	x = x / 640
	y = y / 480
	x = x * 160
	y = y * 160
	local nx = 80-x
	local ny = 80-y
	nx = nx * aspect
	self.ref:SetPos(Vector(300,nx,ny))
end

function SpriteT:GetPos()
	return self.x,self.y
end

function SpriteT:SetRadius(r)
	self.ref:SetRadius(r/3)
	self.rad = r
end

function SpriteT:GetRadius()
	return self.rad
end

function SpriteT:SetRotation(r)
	self.ref:SetRotation(r)
	self.rot = r
end

function SpriteT:GetRotation()
	return self.rot
end

function SpriteT:SetShader(s)
	if(s != nil and type(s) == "number") then
		self.ref:SetShader(s)
		self.shd = s
	end
end

function SpriteT:GetShader()
	return self.shd
end

function SpriteT:Draw()
	render.CreateScene()
	self.ref:Render()
	render.RenderScene(refdef)
end

function Sprite(tex)
	local o = {}

	setmetatable(o,SpriteT)
	SpriteT.__index = SpriteT
	
	o:Init()
	o:SetShader(tex)
	o.Init = nil
	
	return o;
end