local flare = LoadShader("flareShader")
local edge = LoadShader("screen_white_filter") --viewBloodBlend2_HQ
local edge_add = LoadShader("screen_bluredge_add")
local add = LoadShader("white")

local poly = Poly(edge)
poly:SetOffset(Vector())

local count = 3
local incr_x = 640/count
local incr_y = 480/count

for x=0, count-1 do
	for y=0, count-1 do
		local v1 = Vector(incr_x*x,incr_y*y,0)
		local v2 = Vector(incr_x*(x+1),incr_y*y,0)
		local v3 = Vector(incr_x*(x+1),incr_y*(y+1),0)
		local v4 = Vector(incr_x*x,incr_y*(y+1),0)
		
		poly:AddVertex(v1,0,0,{1,1,1,1})
		poly:AddVertex(v2,1,0,{1,1,1,1})
		poly:AddVertex(v3,1,1,{1,1,1,1})
		poly:AddVertex(v4,0,1,{1,1,1,1})

		poly:Split()
	end
end

local aspect = (1 + ((640 - 480) / 640)) - .35

local refdef = {}
refdef.x = 0
refdef.y = 0
refdef.width = 640
refdef.height = 480
refdef.origin = Vector()
refdef.angles = Vector()
refdef.fov_y = 29
refdef.fov_x = (refdef.fov_y * aspect)

local function ToScreenCoords(v)
	local x = v.x
	local y = v.y
	x = x / 640
	y = y / 480
	x = x * 160
	y = y * 160
	local nx = 80-x
	local ny = 80-y
	nx = nx * aspect

	return Vector(300,nx,ny)
end

local centerverts = {}

for k,v in pairs(poly:GetVerts()) do
	if(v[1].x == 0 or v[1].x == 640) then v.fixed = true end
	if(v[1].y == 0 or v[1].y == 480) then v.fixed = true end
	v[2].u = (v[1].x / 640) + 0
	v[2].v = (v[1].y / 480) + 0
	
	--v[2].u = (v[2].u * .9) + .04
	--v[2].v = (v[2].v * .67) + .168
	

	local cv = Vector(320,240,0)
	if(VectorLength(v[1] - cv) < 200) then
		--v[3] = 0
		--v[4] = 0
		--v[5] = 0
	end
	
	v[1] = ToScreenCoords(v[1])
end

poly:Fuse()

local base = {}

for k,v in pairs(poly:GetVerts()) do
	base[k] = {v[1],v[2]}
end

local lr = {}
local lhpx = 0

local function lrtest(id,i)
	i = LerpReach(lr,id,i,math.random(-10,10)/10,.6,.01,function(lr)
		lr.t = math.random(-10,10)/10
	end)
	return i
end

local function lrtest2(id,i,targ)
	i = LerpReach(lr,id,i,targ,1,.025,function(lr)
		lr.t = targ
	end)
	return i
end

--local poly2 = poly:Copy()

local function renderPoly(shader)
	render.CreateScene()
	poly:SetShader(shader)
	poly:Render()
	render.RenderScene(refdef)
end

local function draw()
	local verts = poly:GetVerts()
	local ohpx = (1 - (_CG.stats[STAT_HEALTH]/100))
	local hpx = (ohpx*1.6) - .6
	if(hpx > 1) then hpx = 1 end
	if(hpx < 0) then hpx = 0 end
	
	if(lhpx != ohpx and lhpx < ohpx and ohpx >= 0) then
		local v = ((ohpx - lhpx)*1600)
		if(lr[2000] != nil) then
			lr[2000].t = 255*hpx
			lr[2000].v = lr[2000].v + v
			if(lr[2000].v > 255) then lr[2000].v = 255 end
		end
	end
	
	local nh2 = (lrtest2(2000,0,255*hpx) )
	
	for k,v in pairs(verts) do
		local nhx = nh2 * 1.4
		if(nhx > 255) then 
			nhx = nhx - 255
			v[3] = 255 - nhx
			v[4] = (255-nh2) + nhx
		else
			v[3] = 255
			v[4] = 255-nh2
			v[5] = 255-nh2
		end
		v[6] = 255
	end
	
	renderPoly(edge)
	
	for k,v in pairs(verts) do
		v[3] = 0
		v[4] = 0
		v[5] = 0
		v[6] = 0
		
		local nhx = nh2 * 1.4
		if(nhx > 255) then 
			nhx = nhx - 255
			v[3] = 255 --255-nhx
			v[4] = 50 --255-nhx
			v[5] = 0
			v[6] = nhx
		end
	end
	
	renderPoly(add)
	
	for k,v in pairs(verts) do
		if(!v.fixed) then
			local nx = lrtest((k*2),0) * 25
			local ny = lrtest((k*2) + 1,0) * 25
			
			--local r,g,b = fasthue(nh,255)
			
			v[1] = base[k][1] + Vector(0,nx,ny)		
		end
		v[3] = nh2/1.4
		v[4] = 0
		v[5] = 0
		v[6] = 0
	end
	
	renderPoly(edge_add)
	
	lhpx = ohpx
end
hook.add("Draw2D","cl_tscoords",draw)