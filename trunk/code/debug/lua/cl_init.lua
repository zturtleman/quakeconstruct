--require("cl_marks")
--require("cl_cgtab")
--self.VAriblae
--include("lua/cl_viewtest.lua")
include("lua/cl_menu2.lua")
include("lua/cl_testmenu2.lua")
include("lua/cl_turrets.lua")
include("lua/cl_explosion.lua")

local flare = LoadShader("flareShader")
local blood = LoadShader("bloodMark")
blood = LoadShader("viewBloodBlend")

local function rvel(a)
	return Vector(
	math.random(-a,a),
	math.random(-a,a),
	math.random(-a,a))
end

local function newParticle(pos,dir,freeze)
	--if(!flesh) then return end
	scale = scale or 1
	local r = RefEntity()
	r:SetColor(1,1,1,1)
	r:SetType(RT_SPRITE)
	r:SetRadius(math.random(5,10)*scale)
	r:SetRotation(math.random(360))
	r:SetShader(flare)
	r:SetPos(vAdd(vMul(rvel(2000),.01),pos))
	
	dir.x = dir.x + (math.random(-10,10)/30)
	dir.y = dir.y + (math.random(-10,10)/30)
	dir.z = dir.z + (math.random(-10,10)/30)
	
	dir = vMul(dir,math.random(60,120)/60)

	local le = LocalEntity()
	--le:SetTrType(TR_LINEAR)
	le:SetPos(vAdd(vMul(rvel(2000),.02),pos))
	le:SetVelocity(vMul(dir,60))
	le:SetRefEntity(r)
	le:SetStartTime(LevelTime())
	le:SetEndTime(LevelTime() + (800) + math.random(300,800))
	le:SetType(LE_FRAGMENT)
	le:SetColor(1,1,1,1)
	le:SetRadius(r:GetRadius())
	--[[le:SetCallback(LOCALENTITY_CALLBACK_THINK,function(le)
		le:SetNextThink(LevelTime() + 50 + math.random(50,100))
		local ref = le:GetRefEntity()
		ref:SetRadius(ref:GetRadius()*.7)
		le:SetRefEntity(ref)
		--le:SetVelocity(vMul(le:GetVelocity(),.9))
		
		--local normal = vSub(le:GetPos(),pos)
		--le:SetVelocity(vAdd(le:GetVelocity(),vMul(normal,-1)))
	end)]]
end

local function ItemPickup(class,pos,vel,itemid)
	for i=0, (50 + math.random(5)) do
		newParticle(pos,vMul(vel,math.random(-5,5)/1000),false)
	end
end

local function readVector()
	local vec = Vector()
	vec.x = message.ReadFloat()
	vec.y = message.ReadFloat()
	vec.z = message.ReadFloat()
	return vec
end

local function bool(i)
	if(i != 0) then 
		return true 
	else 
		return false 
	end
end

local function ParseDamage()
	local attacker = nil
	local pos = Vector()
	local dmg = message.ReadLong()
	local death = message.ReadShort()
	local id = message.ReadShort()
	local self = (id == LocalPlayer():EntIndex())
	local self2 = GetEntityByIndex(id)
	local suicide = false
	local hp = message.ReadShort()
	local pos = message.ReadVector()
	local atkid = message.ReadShort()
	local atkname = ""
	if(atkid != -1) then
		attacker = GetEntityByIndex(atkid)
		suicide = (atkid == LocalPlayer():EntIndex())
	end
	if(attacker != nil) then
		atkname = attacker:GetInfo().name
	end
	CallHook("Damaged",atkname,pos,dmg,death,self,suicide,hp-dmg)
	CallHook("PlayerDamaged",self2,atkname,pos,dmg,death,self,suicide,hp-dmg,id,pos)
	attacker = attacker or ""
	--print("Attacked: " .. dmg .. " " .. EnumToString(meansOfDeath_t,death) .. " " .. attacker .. "\n")
end

local function HandleMessage(msgid)
	if(msgid == "itempickup") then
		local class = message.ReadString()
		local pos = readVector()
		local vel = readVector()
		local itemid = message.ReadLong()
		
		ItemPickup(class,pos,vel,itemid)
	elseif(msgid == "playerdamage") then
		ParseDamage()
	elseif(msgid == "playerrespawn") then
		local id = message.ReadShort()
		local self = (id == LocalPlayer():EntIndex())
		local self2 = GetEntityByIndex(id)
		CallHook("PlayerRespawned",self2,id)
		print("^2RESPAWN!\n")
		if(self) then
			CallHook("Respawned")
		end
	end
end
hook.add("HandleMessage","cl_init",HandleMessage)

--[[
local poly = Poly(blood)

local len = 5
local min = -(len-2) * 20
local max = len*20

for x = 0, len do
	for y = 0, len do
		local v1 = Vector(x-1,y-1,0) * 10
		local v2 = Vector(x,y-1,0) * 10
		local v3 = Vector(x,y,0) * 10
		local v4 = Vector(x-1,y,0) * 10
	
		poly:AddVertex(v1,(v1.x-min/2)/max,(v1.y-min/2)/max,{1,1,1,1})
		poly:AddVertex(v2,(v2.x-min/2)/max,(v2.y-min/2)/max,{1,1,1,1})
		poly:AddVertex(v3,(v3.x-min/2)/max,(v3.y-min/2)/max,{1,1,1,1})
		poly:AddVertex(v4,(v4.x-min/2)/max,(v4.y-min/2)/max,{1,1,1,1})

		poly:Split()	
	end
end

poly:Fuse()

local off = Vector(672,1872,22)

local lr = {}
function LerpReach(id,v,t,thr,s,r)
	lr[id] = lr[id] or {}
	local l = lr[id]
	
	l.t = l.t or t
	l.v = l.v or v
	
	l.v = l.v + (l.t - l.v)*s
	
	if(math.abs(l.t-l.v) < thr) then
		pcall(r,l)
	end
	return l.v
end

local function lrtest(id,tab,i)
	tab[i] = LerpReach(id,tab[i],math.random(0,255),2,.05,function(lr)
		lr.t = math.random(0,255)
	end)
end

local function lrtest2(id,tab,i1,i2)
	tab[i1][i2] = LerpReach(id,tab[i1][i2],math.random(-100,100)/10,2,.05,function(lr)
		lr.t = math.random(-100,100)/10
	end)
end

local function lrtest3(id,tab,i1,i2)
	tab[i1][i2] = LerpReach(id,tab[i1][i2],tab[i1][i2] + math.random(-100,100)/1000,2,.05,function(lr)
		lr.t = lr.t + math.random(-100,100)/1000
	end)
end

local store = {}

local function project(off)
	local pos = _CG.viewOrigin
	local ang = _CG.refdef.forward
	local r = _CG.refdef.right
	local u = _CG.refdef.up
	
	pos = pos + (r * (off.x - max/5))
	pos = pos + (u * (off.y - max/5))
	
	local endpos = pos + (ang * 2000)
	local res = TraceLine(pos,endpos,nil,1)
	return res.endpos + res.normal*3
end

poly:SetOffset(Vector(0,0,0))

for k,v in pairs(poly:GetVerts()) do
	store[k] = store[k] or {}
	store[k].pos = store[k].pos or Vectorv(v[1])
end

local function used(t)
	if(t) then
		for k,v in pairs(poly:GetVerts()) do
			v[1] = project(store[k].pos)
		end
	end
end
hook.add("Use","cl_init",used)

local function d3d()
	poly:Render(true)
end
hook.add("Draw3D","cl_init",d3d)]]