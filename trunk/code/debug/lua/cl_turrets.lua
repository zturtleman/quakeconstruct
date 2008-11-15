local blueflag = LoadModel("models/flags/b_flag.md3")
local mach = LoadModel("models/weapons2/machinegun/machinegun.md3")
local barrel = LoadModel("models/weapons2/machinegun/machinegun_barrel.md3")
local mach_flash = LoadModel("models/weapons2/machinegun/machinegun_flash.md3")
local fx = LoadShader("railCore")
local mark = LoadShader("gfx/damage/bullet_mrk")
local red = LoadShader("models/weapons2/machinegun/machinegun_r")
local blue = LoadShader("models/weapons2/machinegun/machinegun_b")
local fire = {
	LoadSound("sound/weapons/machinegun/machgf1b.wav"),
	LoadSound("sound/weapons/machinegun/machgf2b.wav"),
	LoadSound("sound/weapons/machinegun/machgf3b.wav"),
	LoadSound("sound/weapons/machinegun/machgf4b.wav"),
}
local empty = LoadSound("sound/weapons/noammo.wav")

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
	local col = ent:GetTable().color
	local ang = VectorForward(ent:GetAngles())
	beam:SetPos(vAdd(ent:GetPos(),vMul(ang,26)))
	beam:SetPos2(traceit(ent,dx,dy,dist))
	beam:SetType(RT_RAIL_CORE)
	beam:SetColor(col[1],col[2],col[3],col[4])
	beam:SetRadius(2)
	beam:SetShader(fx)
	local le = LocalEntity()
	le:SetRefEntity(beam)
	le:SetStartTime(LevelTime())
	le:SetEndTime(LevelTime() + 100)
	le:SetType(LE_FADE_RGB)
	le:SetRadius(beam:GetRadius())
	le:SetTrType(TR_STATIONARY)
	le:SetColor(col[1],col[2],col[3],col[4])
	ent:GetTable().rotspeed = 20
	ent:GetTable().flash = 4
end

local function HandleMessage(msgid)
	if(msgid == "turretaction") then
		local cmd = message.ReadLong()
		local turret = GetEntityByIndex(message.ReadLong())
		if(turret != nil) then
			local tab = turret:GetTable()
			if(cmd == 1) then
				turret:GetTable().rot = 0
				turret:GetTable().rotspeed = 0
				turret:GetTable().active = true
				local team = message.ReadLong()
				if(team == TEAM_RED) then
					tab.color = {1,0,0,1}
				elseif(team == TEAM_BLUE) then
					tab.color = {0,0,1,1}
				else
					tab.color = {1,1,1,1}
				end
				tab.team = team
				print("Activated\n")
			elseif(cmd == 2) then
				local dx = message.ReadFloat()
				local dy = message.ReadFloat()
				local dist = message.ReadLong()
				if(turret:GetTable().stats[2] > 0) then
					fireFX(turret,dx,dy,dist)
					PlaySound(turret,fire[math.random(1,#fire)])
				else
					PlaySound(turret,empty)
				end
			elseif(cmd == 3) then
				turret:GetTable().active = false
			elseif(cmd == 4) then
				local stat = message.ReadLong()
				local amt = message.ReadFloat()
				if(tab) then
					tab.stats[stat] = amt
				end
			end
		end
	end
end
hook.add("HandleMessage","cl_turrets",HandleMessage)

function RenderStat(ent,wave,stat,off,r,g,b)
	local st1 = RefEntity()
	st1:SetType(RT_RAIL_CORE)
	st1:SetPos(vAdd(ent:GetPos(),Vector(off.x,off.y,off.z + 6+wave.z)))
	st1:SetPos2(vAdd(ent:GetPos(),Vector(off.x,off.y,off.z + 6+wave.z+(30*stat))))
	--st1:SetAngles(Vector(-90,0,0))
	st1:SetColor(r,g,b,1)
	st1:SetRadius(4)
	st1:SetShader(fx)
	st1:Render()
end

local err = false
local lt = LevelTime()
function RenderEnt(ent,name)
	if(name != "turret") then return false end
	if(err) then return false end
	local tab = ent:GetTable()
	local wave = Vector(0,0,math.sin(LevelTime()/300))
	local ang = ent:GetAngles()
	local ang2 = ent:GetAngles()
	local col = ent:GetTable().color
	ang.x = ang.x + math.cos(LevelTime()/500)*4
	local gun = RefEntity()
	gun:SetModel(mach)
	gun:SetPos(vAdd(ent:GetPos(),wave))
	gun:SetAngles(ang)
	if(col != nil) then
		gun:SetColor(col[1],col[2],col[3],col[4])
	end
	if(tab.team == TEAM_RED) then
		gun:SetShader(red)
	elseif(tab.team == TEAM_BLUE) then
		gun:SetShader(blue)
	end
	gun:Render()
	local bar = RefEntity()
	bar:SetModel(barrel)
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
	
	tab.stats = tab.stats or {}
	tab.stats[1] = tab.stats[1] or 1
	tab.stats[2] = tab.stats[2] or 1

	local f,r,u = AngleVectors(ang2)
	
	RenderStat(ent,wave,tab.stats[1],vMul(r,-4),1,0,0)
	RenderStat(ent,wave,tab.stats[2],vMul(r,4),1,1,0)
	
	return true
end
hook.add("DrawCustomEntity","cl_turrets",RenderEnt)

print("^3Loaded CL_Turrets\n")