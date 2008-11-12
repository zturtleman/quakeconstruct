--require("cl_marks")
--require("cl_cgtab")
--self.VAriblae
include("lua/cl_viewtest.lua")
include("lua/cl_menu2.lua")
include("lua/cl_testmenu2.lua")
include("lua/cl_turrets.lua")

local flare = LoadShader("flareShader")

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
	local self = (message.ReadShort() == LocalPlayer():EntIndex())
	local suicide = false
	local hp = message.ReadLong()
	if(message.ReadShort() != 0) then
		attacker = message.ReadString()
		pos = readVector()
		suicide = (message.ReadShort() == LocalPlayer():EntIndex())
	end
	CallHook("Damaged",attacker,pos,dmg,death,self,suicide,hp-dmg)
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
		local self = (message.ReadShort() == LocalPlayer():EntIndex())
		if(self) then
			print("^2RESPAWN!\n")
			CallHook("Respawned")
		end
	end
end
hook.add("HandleMessage","cl_init",HandleMessage)

local poly = Poly(flare)
--[[poly:AddVertex(Vector(-100,-100,10),0,.2,{1,0,0,1})
poly:AddVertex(Vector(100,-100,10),1,.2,{0,1,0,1})
poly:AddVertex(Vector(0,100,10),.5,1,{0,0,1,1})]]

poly:AddVertex(Vector(-100,-100,10),0,0,{1,1,1,1})
poly:AddVertex(Vector(100,-100,10),1,0,{1,1,1,1})
poly:AddVertex(Vector(100,100,50),1,.5,{1,1,1,1})
poly:AddVertex(Vector(-100,100,50),0,.5,{1,1,1,1})

poly:Split()

poly:AddVertex(Vector(-100,100,50),0,.5,{1,1,1,1})
poly:AddVertex(Vector(100,100,50),1,.5,{1,1,1,1})
poly:AddVertex(Vector(100,100,100),1,.5,{1,1,1,1})
poly:AddVertex(Vector(-100,100,100),0,.5,{1,1,1,1})

poly:Split()

poly:AddVertex(Vector(-100,100,100),0,.5,{1,1,1,1})
poly:AddVertex(Vector(100,100,100),1,.5,{1,1,1,1})
poly:AddVertex(Vector(100,300,10),1,1,{1,1,1,1})
poly:AddVertex(Vector(-100,300,10),0,1,{1,1,1,1})

local off = Vector(672,1872,72)

local function d3d()
	poly:SetOffset(off)
	poly:Render(false)
end
hook.add("Draw3D","cl_init",d3d)