local SpriteT = {}
local aspect = (1 + ((640 - 480) / 640))

function SpriteT:Init()
	self.rad = 10
	self.rot = 0
	self.col = {1,1,1,1}
	self.shd = 0
	self.x = 0
	self.y = 0
end

function SpriteT:SetColor(r,g,b,a)
	self.col = {r,g,b,a}
end

function SpriteT:GetColor()
	return self.col
end

function SpriteT:SetPos(x,y)
	self.x = x
	self.y = y
end

function SpriteT:GetPos()
	return self.x,self.y
end

function SpriteT:SetRadius(r)
	self.rad = r
end

function SpriteT:GetRadius()
	return self.rad
end

function SpriteT:SetRotation(r)
	self.rot = r
end

function SpriteT:GetRotation()
	return self.rot
end

function SpriteT:SetShader(s)
	if(s != nil and type(s) == "number") then
		self.shd = s
	end
end

function SpriteT:GetShader()
	return self.shd
end

function SpriteT:Draw()
	draw.SetColor(unpack(self.col))
	draw.RectRotated(self.x,self.y,self.rad*2,self.rad*2,self.shd,self.rot)
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