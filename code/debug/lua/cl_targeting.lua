--require("cl_marks")
--require("cl_cgtab")
--self.VAriblae

local fx = LoadShader("railCore")
local flare = LoadShader("flareShader")
local blood = LoadShader("bloodMark")
blood = LoadShader("viewBloodBlend")

local poly = Poly(flare)

local len = 5
local min = -(len-2) * 20
local max = 5

local v1 = Vector(-1,-1,0) * max
local v2 = Vector(1,-1,0) * max
local v3 = Vector(1,1,0) * max
local v4 = Vector(-1,1,0) * max

poly:AddVertex(v1,0,0,{1,1,1,1})
poly:AddVertex(v2,1,0,{1,1,1,1})
poly:AddVertex(v3,1,1,{1,1,1,1})
poly:AddVertex(v4,0,1,{1,1,1,1})

poly:Split()	

poly:Fuse()

local store = {}

local function getBeamRef(v1,v2,r,g,b)
	local st1 = RefEntity()
	st1:SetType(RT_RAIL_CORE)
	st1:SetPos(v1)
	st1:SetPos2(v2)
	st1:SetColor(r,g,b,1)
	st1:SetRadius(5)
	st1:SetShader(fx)
	return st1
end

local function showRay(res)
	--getBeamRef(res.start,res.endpos,1,1,1):Render()
end

local function project(off)
	local pos = _CG.viewOrigin
	local ang = _CG.refdef.forward
	local r = _CG.refdef.right
	local u = _CG.refdef.up
	
	pos = pos + (r * off.x)
	pos = pos + (u * off.y)
	
	local endpos = pos + (ang * 2000)
	local res = TraceLine(pos,endpos,nil,1)
	res.normal = res.normal or Vector(0,0,1)
	res.start = pos
	
	showRay(res)
	
	return res.endpos + res.normal*3
end

poly:SetOffset(Vector(0,0,0))

for k,v in pairs(poly:GetVerts()) do
	store[k] = store[k] or {}
	store[k].pos = store[k].pos or Vectorv(v[1])
end

local function d3d()
	for k,v in pairs(poly:GetVerts()) do
		v[1] = project(store[k].pos)
	end
	poly:Render(false)
end
hook.add("Draw3D","cl_targeting",d3d)