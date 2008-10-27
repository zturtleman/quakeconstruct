--require("cl_marks")
--require("cl_cgtab")
--self.VAriblae
include("lua/cl_menu2.lua")
include("lua/cl_testmenu2.lua")
include("lua/cl_turrets.lua")

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
local plmoved = Vector(0,0,0)
local lastplmoved = Vector(0,0,0)
local smoothvel = 0
local smoothfall = 0
local ddir = 0
local hp = 100

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
	elseif(msgid == 0) then
		local self = (message.ReadShort() == LocalPlayer():EntIndex())
		if(self) then
			print("^2RESPAWN!\n")
			CallHook("Respawned")
		end
	end
end
hook.add("HandleMessage","cl_init",HandleMessage)

local function maxvel(v)
	return math.min(math.max(v,-320),320)/320;
end

function _ViewCalc(pos,ang,fovx,fovy)
	if(!_CG) then print("^1NO CG!\n") return end
	local crd = _CG.refdef.right
	local vel = LocalPlayer():GetTrajectory():GetDelta()
	local lvel = VectorLength(vel)
	local cvel = Vectorv(vel)
	local nang = Vectorv(ang)
	local rvel = maxvel(DotProduct(vel,crd))
	cvel.z = 0
	plmoved = vAdd(plmoved,vAbs(cvel))
	
	nang.x = ang.x + (math.cos(VectorLength(plmoved)/2000)*1) * maxvel(lvel)
	pos.z = pos.z + (math.cos(VectorLength(plmoved)/1000)*1) * maxvel(lvel)
	
	nang.z = nang.z - smoothvel*5
	nang.x = nang.x + smoothfall
	
	if(hp <= 0) then nang.z = nang.z + (30*ddir) else ddir = (math.random(0,1)*2)-1 end
	
	ang = nang
	
	--pos = vAdd(pos,vMul(crd,-20))
	
	local f = (maxvel(vel.z/2)*2) * 2
	
	smoothvel = smoothvel + (rvel - smoothvel)*.2
	smoothfall = smoothfall + (f - smoothfall)*.2
	
	local def = {
		origin = vAdd(pos,Vector(0,0,0)),
		angles = ang,
	}
	render.SetRefDef(def)
	
	if(lastTarget != LocalPlayer()) then
		hp = 100
		lastTarget = LocalPlayer()
	end
	--print("Set Ref\n")
end

local function respawn()
	hp = 100
end

local function processDamage(attacker,pos,dmg,death,waslocal,wasme,health)
	if(waslocal) then
		hp = health
	end
end

local function rvec(amt)
	return Vector(math.random(-amt,amt),math.random(-amt,amt),math.random(-amt,amt))
end

local flare = LoadShader("flareShader")
local function d3d()
	local tab = GetEntitiesByClass("missile")
	for k,v in pairs(tab) do
		if(v != nil and v:GetWeapon() == WP_ROCKET_LAUNCHER) then
			v:CustomDraw(true)
			local s = RefEntity()
			s:SetType(RT_SPRITE)
			s:SetPos(v:GetPos())
			s:SetColor(1,1,1,1)
			s:SetRadius(12)
			s:SetShader(flare)
			s:Render()
		end
	end
end
hook.add("Draw3D","cl_init",d3d)

hook.add("Respawned","cl_init",respawn)
hook.add("Damaged","cl_init",processDamage)