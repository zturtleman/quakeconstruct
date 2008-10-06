--require("cl_marks")
--require("cl_cgtab")
--self.VAriblae
include("lua/cl_menu2.lua")
include("lua/cl_testmenu2.lua")

local gibs = {
	LoadModel("models/gibs/abdomen.md3"),
	LoadModel("models/gibs/arm.md3"),
	LoadModel("models/gibs/chest.md3"),
	LoadModel("models/gibs/fist.md3"),
	LoadModel("models/gibs/foot.md3"),
	LoadModel("models/gibs/forearm.md3"),
	LoadModel("models/gibs/intestine.md3"),
	LoadModel("models/gibs/leg.md3"),
	LoadModel("models/gibs/brain.md3"),
}

local explodeSound = LoadSound("sound/player/gibsplt1.wav")
local skull = LoadModel("models/gibs/skull.md3")
local flare = LoadShader("flareShader")
local blood1 = LoadShader("BloodMark") --viewBloodFilter_HQ
local i=0
local rpos = Vector(670,500,30)
local lastPos = Vector(0,0,0)
local bob = 0
local nxt = 0

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
	local vec = Vector(0,0,0)
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
	local pos = Vector(0,0,0)
	local dmg = message.ReadLong()
	local death = message.ReadLong()
	if(message.ReadShort() != 0) then
		attacker = message.ReadString()
		pos = readVector()
	end
	local localattacker = bool(message.ReadShort())
	local localself = bool(message.ReadShort())
	CallHook("Damaged",attacker,pos,dmg,death,localself,localattacker)
	attacker = attacker or ""
	print("Attacked: " .. dmg .. " " .. EnumToString(meansOfDeath_t,death) .. " " .. attacker .. "\n")
end

function HandleMessage()
	local msgid = message.ReadLong()
	if(msgid == 1) then
		local str = message.ReadString()
		local float = message.ReadFloat()
		local float2 = message.ReadFloat()
		local short = message.ReadShort()
		print("Got String: " .. base64.dec(str) .. "\n")
		print("Got Float: " .. float .. "\n")
		print("Got Float2: " .. float2 .. "\n")
		print("Got Short: " .. short .. "\n")
	elseif(msgid == 2) then
		local class = message.ReadString()
		local pos = readVector()
		local vel = readVector()
		local itemid = message.ReadLong()
		
		ItemPickup(class,pos,vel,itemid)
	elseif(msgid == 3) then
		ParseDamage()
	end
end
hook.add("HandleMessage","cl_init",HandleMessage)