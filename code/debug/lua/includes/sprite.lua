local SpriteT = {}
local aspect = (1 + ((640 - 480) / 640))

function SpriteT:Init()
	self.w = 10
	self.h = 10
	self.rot = 0
	self.shd = 0
	self.x = 0
	self.y = 0
end

function SpriteT:SetPos(x,y)
	self.x = x
	self.y = y
end

function SpriteT:GetPos()
	return self.x,self.y
end

function SpriteT:SetSize(w,h)
	self.w = w
	self.h = h
end

function SpriteT:SetRadius(r)
	self.w = r
	self.h = r
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
	if(self.animsprite == true) then self:DrawAnim() return end
	draw.RectRotated(self.x,self.y,self.w*2,self.h*2,self.shd,self.rot)
end

function SpriteT:SetFrame(f)
	self.frame = f
end

function SpriteT:DrawAnim()
	local rf = self.frame % self.rows
	local cf = math.floor(self.frame / self.rows)
	
	local rx = (1/self.rows)*rf
	local cx = (1/self.cols)*cf
	local rx1 = rx + (1/self.rows)
	local cx1 = cx + (1/self.cols)

	draw.RectRotated(self.x,self.y,self.w*2,self.h*2,self.shd,self.rot,rx,cx,rx1,cx1)
end

function SpriteT:GetCoords()
	local rf = self.frame % self.rows
	local cf = math.floor(self.frame / self.rows)
	
	local rx = (1/self.rows)*rf
	local cx = (1/self.cols)*cf
	local rx1 = rx + (1/self.rows)
	local cx1 = cx + (1/self.cols)
	
	return rx,cx,rx1,cx1
end

function SpriteT:Animate()
	local lt = LevelTime()
	if(self.nxt < lt) then
		self.frame = self.frame + 1
		if(self.frame >= self.frames) then 
			self.frame = self.start
			self.finished = true
		end
		self.nxt = lt+self.rate
	end
end

function SpriteT:Done()
	return self.finished
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

function AnimSprite(tex,rows,cols,rate,frame,cframes)
	local o = {}
	
	setmetatable(o,SpriteT)
	SpriteT.__index = SpriteT
	
	o:Init()
	o:SetShader(tex)
	o.Init = nil
	o.animsprite = true
	o.finished = false
	o.rows = rows or 1
	o.cols = cols or 1
	o.rate = rate or 30
	o.frame = frame or 0
	o.start = o.frame
	o.frames = cframes or (o.rows*o.cols)
	o.nxt = LevelTime() + o.rate
	
	return o
end