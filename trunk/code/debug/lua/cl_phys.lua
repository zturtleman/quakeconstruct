local data = [[{
	//deformVertexes wave 1000 sin 22 0 0 0
	{
		map gfx/charged_blue2.jpg
		blendFunc add
		rgbGen entity
		alphaGen entity
	}
}]]
local plaincolor = CreateShader("f",data)

local boxmodel = LoadModel("models/geom/box.MD3")
local conemodel = LoadModel("models/geom/cone16.MD3")
local rocketl = LoadModel("models/weapons2/rocketl/rocketl.MD3")
local flag = LoadModel("models/powerups/instant/quad_ring.md3")

if(PHYS_OBJECTS ~= nil) then
	for k,v in pairs(PHYS_OBJECTS) do
		if(v.native ~= nil) then
			phys.RemoveRigidBody(v.native)
			v.native = nil
		end
	end
end
PHYS_OBJECTS = {}

phys.SetWorldScale(2)

local function addPhysBox(size,pos,mass,model)
	local body = phys.NewBoxRigidBody(size,mass)
	phys.SetPos(body, pos)
	table.insert(PHYS_OBJECTS,{native = body, scale = size*2, mass = mass, mdl = (model or boxmodel)})
	return body
end

local function addPhysModel(model,pos,mass,scale,center)
	model = model or boxmodel
	scale = scale or Vector(1,1,1)
	center = center or Vector(0,0,0)
	local body = phys.NewModelRigidBody(model,mass,scale,center)
	if(body ~= nil) then
		phys.SetPos(body, pos)
	end
	table.insert(PHYS_OBJECTS,{native = body, scale = scale, mass = mass, mdl = (model or boxmodel), center = center})
	return body
end

local box = addPhysBox(Vector(280,280,5),Vector(0,0,7),0)
--[[local cone = addPhysModel(conemodel,Vector(0,0,20),10,Vector(15,15,15))
phys.SetAngles(cone,Vector(0,90,0))
]]
phys.SetAngles(box,Vector(0,0,0))

--addPhysModel(nil,Vector(0,0,0),10,Vector(20,40,5))
--addPhysModel(conemodel,Vector(0,0,10),10,Vector(3,3,15))

local plBox = addPhysBox(Vector(10,10,20),Vector(0,0,0),0)
for i=0, 10 do
	local b = addPhysBox(Vector(5,5,10),Vector(0,0,100 + i*10),10)
	phys.SetAngles(b,Vector(42,i*2,0))
end

for i=0, 3 do
	local rl = addPhysModel(rocketl,Vector(50,0,102 + i*10),10,Vector(1,1,1),Vector(20,0,0))
	phys.SetAngles(rl,Vector(0,i*10,0))
end

local fl = addPhysModel(flag,Vector(100,0,50),10,nil,Vector(0,0,0))

local selectbody = nil
local ref = RefEntity()
local function ptraceline()
	selectbody = nil
	local start = _CG.refdef.origin
	if(start == nil) then return end
	local en = start + _CG.refdef.forward * 1000
	
	local pos,normal,body = phys.TraceLine(start,en)
	normal = VectorToAngles(normal)
	
	if(body ~= nil) then
		selectbody = body
		phys.ApplyImpulse(body,Vector(0,0,300))
		phys.ApplyTorque(body,Vector(0,0,50))
	end
	
	ref:SetPos(pos)
	ref:SetAngles(normal)
	ref:Render()
end

local first = true
local lt = 0
local function d3d()
	if(first == true) then
		lt = LevelTime()
		first = false
	end
	
	local ref = RefEntity()
	ref:AlwaysRender(true)

	if(plBox ~= nil) then
		local pos = LocalPlayer():GetPos() - Vector(0,0,10)
		phys.SetPos(plBox,pos)
		phys.SetAngles(plBox,Vector(0,0,0))
	end
	
	for k,v in pairs(PHYS_OBJECTS) do
		ref:SetShader(0)
		if(v.native == nil) then error("No Native Handle For Physics Object\n") return end
		local pos = phys.GetPos(v.native)
		local f,r,u = phys.GetAngles(v.native)
		
		if(v.center) then
			pos = pos - f * (v.center.x * v.scale.x)
			pos = pos - r * (v.center.y * v.scale.y)
			pos = pos - u * (v.center.z * v.scale.z)
		end
		
		--ang = VectorToAngles(ang)
		--ref:SetAngles(ang)
		ref:SetAxis(f,r,u)
		--ref:SetAngles(Vector(0,0,0))
		ref:SetPos(pos)
		ref:Scale(v.scale)
		ref:SetModel(v.mdl)
		ref:SetColor(.2,.2,.2,1)
		
		if(v.mass ~= 0) then
			ref:SetColor(.2,0,.2,1)
		end
		if(v.native ~= plBox) then
			ref:Render()
		end
		
		if(selectbody == v.native) then
			ref:SetShader(plaincolor)
			ref:Render()
		end
	end
	
	local dt = LevelTime() - lt
	ptraceline()
	
	phys.Simulate(dt/1000)
	
	lt = LevelTime()
end
hook.add("Draw3D","cl_phys",d3d)