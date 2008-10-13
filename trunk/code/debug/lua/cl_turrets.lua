local blueflag = LoadModel("models/flags/b_flag.md3")
local mach = LoadModel("models/weapons2/machinegun/machinegun.md3")
local barrel = LoadModel("models/weapons2/machinegun/machinegun_barrel.md3")
local mach_flash = LoadModel("models/weapons2/machinegun/machinegun_flash.md3")
local fx = LoadShader("railCore")
local mark = LoadShader("gfx/damage/bullet_mrk")
local fire = {
	LoadSound("sound/weapons/machinegun/machgf1b.wav"),
	LoadSound("sound/weapons/machinegun/machgf2b.wav"),
	LoadSound("sound/weapons/machinegun/machgf3b.wav"),
	LoadSound("sound/weapons/machinegun/machgf4b.wav"),
}

local beam = RefEntity()

local function traceit(ent,dx,dy,dist)
	local ang = ent:GetAngles()
	local forward,right,up = AngleVectors(ang)
	local startpos = ent:GetPos()
	local ignore = ent
	local flags = 1
	flags = bitOr(flags,33554432)
	flags = bitOr(flags,67108864)
	
	local endpos = vAdd(startpos,vMul(forward,8192*16))
	
	endpos = vAdd(endpos,vMul(right,dx*100))
	endpos = vAdd(endpos,vMul(up,dy*100))
	
	local res = TraceLine(startpos,endpos,ignore,flags)
	util.CreateMark(mark,res.endpos,res.normal,math.random(360),1,1,1,1,5,true)
	
	return res.endpos or ent:GetPos()
end

local function fireFX(ent,dx,dy,dist)
	local ang = VectorForward(ent:GetAngles())
	beam:SetPos(vAdd(ent:GetPos(),vMul(ang,26)))
	beam:SetPos2(traceit(ent,dx,dy,dist))
	beam:SetType(RT_RAIL_CORE)
	beam:SetColor(1,1,1,1)
	beam:SetRadius(2)
	beam:SetShader(fx)
	local le = LocalEntity()
	le:SetRefEntity(beam)
	le:SetStartTime(LevelTime())
	le:SetEndTime(LevelTime() + 100)
	le:SetType(LE_FADE_RGB)
	le:SetRadius(beam:GetRadius())
	le:SetTrType(TR_STATIONARY)
	le:SetColor(1,1,1,1)
	ent:GetTable().rotspeed = 20
	ent:GetTable().flash = 4
end

local function HandleMessage()
	local msgid = message.ReadLong()
	if(msgid == 4) then
		local cmd = message.ReadLong()
		local turret = GetEntityByIndex(message.ReadLong())
		if(turret != nil) then
			if(cmd == 1) then
				turret:GetTable().rot = 0
				turret:GetTable().rotspeed = 0
				turret:GetTable().active = true
				print("Activated\n")
			elseif(cmd == 2) then
				local dx = message.ReadFloat()
				local dy = message.ReadFloat()
				local dist = message.ReadLong()
				fireFX(turret,dx,dy,dist)
				PlaySound(turret:GetPos(),fire[math.random(1,#fire)])
			elseif(cmd == 3) then
				turret:GetTable().active = false
			end
		end
	end
end
hook.add("HandleMessage","cl_turrets",HandleMessage)

local err = false
local lt = LevelTime()
function RenderEnt(ent,name)
	if(err) then return 0 end
	local wave = Vector(0,0,math.sin(LevelTime()/300))
	local ang = ent:GetAngles()
	ang.x = ang.x + math.cos(LevelTime()/500)*4
	local gun = RefEntity()
	gun:SetModel(mach)
	gun:SetPos(vAdd(ent:GetPos(),wave))
	gun:SetAngles(ang)
	gun:Render()
	local bar = RefEntity()
	bar:SetModel(barrel)
	local tab = ent:GetTable()
	if(tab) then
		if(tab.rot) then
			bar:SetAngles(Vector(0,0,tab.rot))
			tab.rot = tab.rot + tab.rotspeed
			if(tab.rotspeed > 0) then
				tab.rotspeed = tab.rotspeed - 0.2
			else
				tab.rotspeed = 0
			end
		end
		if(tab.flash and tab.flash > 0) then
			local flash = RefEntity()
			flash:SetAngles(Vector(0,0,math.random(-10,10)))
			flash:SetPos(ent:GetPos())
			flash:SetModel(mach_flash)
			flash:PositionOnTag(gun,"tag_flash")
			flash:Render()
			tab.flash = tab.flash - 1
		end
	else
		print("ERROR\n")
		err = true
	end
	bar:PositionOnTag(gun,"tag_barrel")
	bar:Render()
end
hook.add("DrawCustomEntity","cl_turrets",RenderEnt)

print("^3Loaded CL_Turrets\n")