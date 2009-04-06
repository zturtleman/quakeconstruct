include("lua/cl_ginfo.lua")
include("lua/cl_menu2.lua")
include("lua/cl_testmenu2.lua")
--include("lua/cl_fonts.lua")
include("lua/cl_help.lua")
--include("lua/cl_emitters.lua")

local flare = LoadShader("flareShader")
local blood = LoadShader("bloodMark")
blood = LoadShader("viewBloodBlend")

local function rvel(a)
	return Vector(
	math.random(-a,a),
	math.random(-a,a),
	math.random(-a,a))
end

local ref = RefEntity()
	ref:SetColor(1,1,1,1)
	ref:SetType(RT_SPRITE)
	ref:SetShader(flare)

local function newParticle(pos,indir,freeze)
	scale = scale or 1
	
	ref:SetRotation(math.random(360))
	ref:SetPos((rvel(2000) * .01) + pos)

	local le = LocalEntity()
	le:SetPos(pos)
	le:SetRefEntity(ref)
	le:SetStartTime(LevelTime())
	le:SetType(LE_FRAGMENT)
	le:SetColor(1,1,1,1)
	le:SetEndColor(0,0,0,0)
	le:Emitter(LevelTime(), LevelTime() + 600, 1, 
	function(le2,frac)
		local dir = Vector(indir.x,indir.y,indir.z)
		dir.x = dir.x + (math.random(-10,10)/10)
		dir.y = dir.y + (math.random(-10,10)/10)
		dir.z = dir.z + (math.random(-10,10)/10)
				
		dir = dir * (math.random(100,200))	
		le2:SetVelocity(dir)
		le2:SetRadius(math.random(15,25) * (1-frac))
		le2:SetEndTime(LevelTime() + math.random(300,700) * math.random(1,4))
	end)
end

local function ItemPickup(class,pos,vel,itemid)
	newParticle(pos + Vector(0,0,5),(vel * .002) + Vector(0,0,1),false)
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
	local dmg = message.ReadShort()
	local death = message.ReadShort()
	local id = message.ReadShort()
	local self = (id == LocalPlayer():EntIndex())
	local self2 = GetEntityByIndex(id)
	local suicide = false
	local hp = message.ReadShort()
	local pos = message.ReadVector()
	local dir = ByteToDir(message.ReadShort())
	local atkid = message.ReadShort()
	local atkname = ""
	if(atkid != -1) then
		attacker = GetEntityByIndex(atkid)
		suicide = (atkid == LocalPlayer():EntIndex())
	end
	if(attacker != nil) then
		atkname = attacker:GetInfo().name
	end
	CallHook("Damaged",atkname,pos,dmg,death,self,suicide,hp)
	CallHook("PlayerDamaged",self2,atkname,pos,dmg,death,self,suicide,hp,id,pos,dir)
	CallHook("PlayerDamaged2",self2,dmg,death,pos,dir,hp)
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

local function makeShader(file)
	local data = [[{
	{
		map ]] .. file ..  [[
		blendFunc blend
		rgbGen vertex
		alphaGen vertex
	}
	}]]
	return CreateShader("f",data)
end

local t = LevelTime()
local shotTime = 1000
local sshader = nil
local sshot = 0
local function ss2d()

	if(sshader and t > LevelTime()) then
		local c = (t - LevelTime()) / shotTime
		draw.SetColor(1,1,1,c)
		draw.Rect(0,0,640,480,sshader)
	end

	if(sshot == 2) then
		sshader = makeShader("screenshots/lua/test.jpg")
		t = LevelTime() + shotTime
		sshot = 0
	end
	if(sshot == 1) then sshot = 2 end
end
hook.add("Draw2D","cl_init",ss2d)

local function shouldDraw(str)
	if(str == "HUD" and _CG.stats[STAT_HEALTH] <= 0) then return false end
	return (sshot == 0)
end
hook.add("ShouldDraw","cl_init",shouldDraw)

local function takeShot()
	util.ClearImage("screenshots/lua/test.jpg") --Clear the image from the renderer's cache
	util.Screenshot(0,0,640,480,"screenshots/lua/test.jpg")
	sshot = 1
end
concommand.add("jpegshot",takeShot)

hook.add("Respawned","cl_init",takeShot)