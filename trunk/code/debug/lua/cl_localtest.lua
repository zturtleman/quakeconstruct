local flare = LoadShader("flareShader")
local points = {}
local blood1 = LoadShader("BloodMark")

local bloodtex = {}
for i=1,5 do
	table.insert(bloodtex,LoadShader("BloodMarkN" .. i))
end

local function rvel(a)
	return Vector(
	math.random(-a,a),
	math.random(-a,a),
	math.random(-a,a))
end

local function blood(pl,pos,t,big,sizex)
	local ref = RefEntity()
	ref:SetColor(1,1,1,1)
	ref:SetAngles(ref:GetAngles())
	ref:Scale(Vector(scale,scale,scale))
	ref:SetRotation(math.random(360))
	ref:SetType(RT_SPRITE)
	ref:SetShader(blood1)
	ref:SetRadius((5 + math.random(0,3)) * t)
	ref:SetPos(pos)
	local le2 = LocalEntity()
	le2:SetVelocity(rvel(50*t))
	if(big) then
		local v = rvel(sizex*(t))
		v.z = v.z + 30
		v.z = v.z * 2
		v = v + pl:GetTrajectory():GetDelta()*.8
		le2:SetVelocity(v)
	end
	le2:SetPos(pos)
	le2:SetRadius((5 + math.random(0,3)) * t)
	le2:SetRefEntity(ref)
	le2:SetStartTime(LevelTime())
	le2:SetEndTime(LevelTime() + 1400)
	--le2:SetType(LE_FADE_RGB) --LE_FRAGMENT
	le2:SetColor(.8,math.random(0,3)/10,0,.4)
	le2:SetTrType(TR_GRAVITY)
	le2:SetType(LE_FRAGMENT)
	
	le2:SetCallback(LOCALENTITY_CALLBACK_TOUCH,function(le,tr)
		if(VectorLength(le:GetVelocity()) < 10 or math.random(0,6) == 1) then
			if(big) then
				util.CreateMark(bloodtex[math.random(1,#bloodtex)],tr.endpos,tr.normal,math.random(360),1,1,1,1,math.random(10,25),true,math.random(700,1000))
			else
				util.CreateMark(bloodtex[math.random(1,#bloodtex)],tr.endpos,tr.normal,math.random(360),1,1,1,1,math.random(6,20),true,math.random(400,2000))
			end
			le2:SetEndTime(-1)
		else
			le2:SetEndTime(-1)
		end
	end)
end

local function offsetVector(ent,off,func)
	local pos = ent:GetPos()
	local b,ang = pcall(func or ent.GetAngles, ent)
	if(ang == nil) then return nil end
	local f,r,u = AngleVectors(ang)
	pos = pos + off
	--pos = pos - (r*off.x)
	--pos = pos - (f*off.y)
	--pos = pos - (u*off.z)
	
	return pos
end

local function worldToLocal(ent,pos,func)
	local off = ent:GetPos() - pos
	return offsetVector(ent,off,func)
end

local function rpoint(pos)
	local s = RefEntity()
	s:SetType(RT_SPRITE)
	s:SetPos(pos)
	s:SetColor(1,1,1,1)
	s:SetRadius(2)
	s:SetShader(flare)
	return s
end

local function pldamage(self2,attacker,pos,dmg,death,self,suicide,hp,id,pos)
	if(self2 != nil and self2:IsPlayer()) then
		local off = pos*-10
		off.z = (off.z * -12) + 18
		if(off.z > 32) then off.z = 32 end
		if(dmg > 50) then dmg = 50 end
		if(self) then
			off.z = off.z * -.3
		end
		print(tostring(off) .. "\n")
		table.insert(points,{off=off,pl=self2,t = LevelTime(),dmg=dmg})
		--newParticle(pos,vMul(entity:GetByteDir(),.2),gibs[5])
	end
end
hook.add("PlayerDamaged","cl_localtest",pldamage)

local function d3d()
	--[[local pos = Vector(652,1872,34)
	local players = GetAllPlayers()
	table.insert(players,LocalPlayer())
	for k,v in pairs(players) do
		local pos2 = worldToLocal(v,pos,v.GetLerpAngles)
		pos2.z = v:GetPos().z
		local p = rpoint(pos2)
		p:Render()
	end]]
	for k,v in pairs(points) do
		local t = v.t
		local dt = 1 - ((LevelTime() - v.t) / 1500)
		if(v.pl:GetInfo().health <= 0) then
				dt = .4
		end
		if(dt < 0) then
			dt = 0
		else
			local pos2 = offsetVector(v.pl,v.off,v.pl.GetLerpAngles)
			if(pos2 != nil) then
				local add = (v.pl:GetInfo().health/2)
				if(v.pl:GetInfo().health <= 0) then
					pos2.z = v.pl:GetPos().z - 10
					add = 100
				end
				v.btime = v.btime or LevelTime()
				if(v.btime < LevelTime()) then
					blood(v.pl,pos2 + (rvel(2)/3),dt,(dt > .9),160)
					if(dt > .9) then
						for i=0, math.ceil(v.dmg/2)+2 do
						blood(v.pl,pos2 + (rvel(2)/3),dt,true,math.random(v.dmg,v.dmg*2))
						end
					end
					v.btime = LevelTime() + ((1-dt)*100) + add
				end
			end
		end
		--local p = rpoint(pos2)
		--p:Render()
	end
	if(points[1]) then
		local v = points[1]
		local dt = 1 - ((LevelTime() - v.t) / 1500)
		if(v.pl:GetInfo().health <= 0) then
				dt = 1
		end
		if(dt < 0) then
			table.remove(points,1)
		end
	end
	if(#points > 100) then
		table.remove(points,1)
	end
end
hook.add("Draw3D","cl_localtest",d3d)