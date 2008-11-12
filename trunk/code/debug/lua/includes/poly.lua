local PolyT = {}

function PolyT:Init()
	self.set = {}
	self.verts = {}
	self.flipped = {}
	self.offset = Vector()
	self.shd = 0
	self.splitted = false
end

function PolyT:AddVertex(pos,u,v,color)
	r = color.r or color[1]
	g = color.g or color[2]
	b = color.b or color[3]
	a = color.a or color[4]

	u = math.min(1,math.max(u,0))
	v = math.min(1,math.max(v,0))
	r = math.min(1,math.max(r,0)) * 255
	g = math.min(1,math.max(g,0)) * 255
	b = math.min(1,math.max(b,0)) * 255
	a = math.min(1,math.max(a,0)) * 255
	table.insert(self.verts,{pos,Vector(u,v),r,g,b,a})
	if(#self.verts > 1) then
		self.flipped = table.Flip(self.verts)
	else
		self.flipped = self.verts
	end
	self.splitted = false
end

function PolyT:Split()
	table.insert(self.set,{self.verts,self.flipped})
	self.verts = {}
	self.flipped = {}
	self.splitted = true
end

function PolyT:GetVerts()
	return table.Copy(self.verts)
end

function PolyT:ClearVerts()
	self.set = {}
	self.verts = {}
	self.flipped = {}
	self.splitted = false
end

function PolyT:SetOffset(o)
	self.offset = o
end

function PolyT:SetShader(s)
	if(s != nil and type(s) == "number") then
		self.shd = s
	end
end

function PolyT:GetShader()
	return self.shd
end

function PolyT:Render(flipped)
	if(!self.splitted) then
		self:Split()
	end

	for i=1, #self.set do
		local s = self.set[i]
		if(type(s) == "table") then
			if(#s[1] >= 3) then
				render.DrawPoly(s[1],self.shd,self.offset)
				if(flipped) then
					render.DrawPoly(s[2],self.shd,self.offset)
				end
			else
				error("Not enough vertices.\n")
			end
		end
	end
end

function Poly(tex)
	local o = {}

	setmetatable(o,PolyT)
	PolyT.__index = PolyT
	
	o:Init()
	o:SetShader(tex)
	o.Init = nil
	
	return o;
end