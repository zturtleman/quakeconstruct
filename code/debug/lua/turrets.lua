MAX_TURRET_DIST = 750
TURRET_HEALTH = 500
TURRET_SHOTS = 200

message.Precache("turretaction")

local weapons = {
	WP_MACHINEGUN,
	WP_GRENADE_LAUNCHER,
	WP_SHOTGUN,
	WP_ROCKET_LAUNCHER,
	WP_LIGHTNING,
	WP_RAILGUN,
	WP_PLASMAGUN,
	WP_BFG,
}

function vectoangles(v)
	local out = Vector(0,0,0)

	local yaw = ( (math.atan2 ( v.y, v.x ) * 180) / math.pi );
	local forward = math.sqrt ( v.x*v.x + v.y*v.y );
	local pitch = ( (math.atan2(v.z, forward) * 180) / math.pi );
	local roll = 0
	
	out.x = pitch * -1
	out.y = yaw
	out.z = roll
	return out
end

local function traceit(ent,dx,dy)
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
	
	--print(VectorLength(vSub(res.endpos,startpos)) .. "\n")
	
	return res.entity,res.endpos
end

function sendTurretStart(ent,team)
	local msg = Message()
	message.WriteLong(msg,1)
	message.WriteLong(msg,ent:EntIndex())
	message.WriteLong(msg,team)
	for k,v in pairs(GetEntitiesByClass("player")) do
		SendDataMessage(msg,v,"turretaction")
	end
end

function sendTurretStat(ent,stat,val)
	local msg = Message()
	message.WriteLong(msg,4)
	message.WriteLong(msg,ent:EntIndex())
	message.WriteLong(msg,stat)
	message.WriteFloat(msg,val)
	for k,v in pairs(GetEntitiesByClass("player")) do
		SendDataMessage(msg,v,"turretaction")
	end
end

function sendTurretFire(ent,dir)
	local msg = Message()
	message.WriteLong(msg,2)
	message.WriteLong(msg,ent:EntIndex())
	message.WriteFloat(msg,dir.x)
	message.WriteFloat(msg,dir.y)
	message.WriteLong(msg,MAX_TURRET_DIST)
	for k,v in pairs(GetEntitiesByClass("player")) do
		SendDataMessage(msg,v,"turretaction")
	end
end

function fireTurret(ent)
	local tab = ent:GetTable()
	if(tab.shots > 0) then
		local dir = Vector(0,0,0)
		dir.x = math.random(-60,60)
		dir.y = math.random(-60,60)
		sendTurretFire(ent,dir)
		local pl,endpos = traceit(ent,dir.x,dir.y)
		local forward = VectorForward(ent:GetAngles())
		if(pl != nil) then
			pl:Damage(ent,ent:GetTable().owner,math.random(5,10),MOD_MACHINEGUN,forward,endpos)
		end
		tab.shots = tab.shots - 1
		sendTurretStat(ent,2,tab.shots/TURRET_SHOTS)
	else
		tab.shots = 0
		sendTurretFire(ent,Vector(0,0,0))
	end
end

function aimTurretAt(ent,pos)
	--Use DotProduct so we don't waste ammo
	local tpos = vAdd(pos,Vector(0,0,math.random(10,20)))
	local entang = ent:GetAngles()
	local aim = VectorNormalize(vSub(tpos,ent:GetPos()))
	local aim = vectoangles(aim)
	local ang = vAdd(entang,vMul(getDeltaAngle3(aim,entang),.2))
	local vf1 = VectorRight(entang)
	local vf2 = VectorRight(aim)
	local dp = DotProduct(vf2,vf1)--VectorLength(vMul(vSub(vf2,vf1),100))/100
	ent:SetAngles(ang)
	if(dp > .9) then
		--print(dp .. "\n")
		return true
	end
	return false
end

local function qdist(a,b)
	return VectorLength(vSub(b,a))
end

local function vEq(v1,v2)
	if(v1.x == v2.x and v1.y == v2.y and v1.z == v2.z) then return true end
	return false
end

function checkteam(targ,owner)
	local t1 = owner:GetInfo().team
	local t2 = targ:GetInfo().team
	if(t2 == TEAM_FREE) then return true end
	if(t1 != t2) then return true end
	return false
end

function aimTurret(ent)
	local tab = ent:GetTable()
	local owner = tab.owner
	
	local function plsort(a,b)
		local adist = qdist(a:GetPos(),ent:GetPos())
		local bdist = qdist(b:GetPos(),ent:GetPos())
		return adist < bdist
	end
	
	local players = table.Copy(GetAllPlayers())
	table.sort(players,plsort)
	
	for k,v in pairs(players) do
		--if(v != owner and v:GetInfo().health > 0 and checkteam(v,owner)) then
			if(v:GetInfo().health > 0) then
				local pos = v:GetPos()
				if(pos.z > ent:GetPos().z) then
					pos.z = pos.z + 4
				end
				local dist = VectorLength(vSub(ent:GetPos(),pos))
				if(dist < MAX_TURRET_DIST) then
					local flags = 1
					flags = bitOr(flags,33554432)
					flags = bitOr(flags,67108864)
					local res = TraceLine(ent:GetPos(),pos,ent,flags)
					if(res.entity == v or vEq(pos,res.endpos)) then
						if(aimTurretAt(ent,pos)) then
							return true
						end
					end
				end
			end
		--end
	end
	
	if(LevelTime() > tab.expiration) then
		--tab.done = 1
	end
	return false
end

function refill(turret,pl,ammo)
	local tab = turret:GetTable()
	tab.nextrefill = tab.nextrefill or 0
	if(tab.nextrefill < LevelTime()) then
		local needed = TURRET_SHOTS - tab.shots
		local plhas = pl:GetAmmo(weapons[ammo])
		needed = math.min(plhas,needed)
		needed = math.min(needed,5)
		if(needed <= 0) then 
			needed = 0
			if(ammo < #weapons) then
				if(refill(turret,pl,ammo + 1) == false) then
					--pl:PlaySound("sound/weapons/noammo.wav")
				end
			else
				tab.nextrefill = LevelTime() + 500
				return false
			end
		else
			pl:SetAmmo(weapons[ammo],plhas - needed)
			tab.shots = tab.shots + math.ceil(needed*6)
			sendTurretStat(turret,2,tab.shots/TURRET_SHOTS)
			--pl:PlaySound("sound/misc/am_pkup.wav")
			tab.nextrefill = LevelTime() + 500
			return true
		end
	end
end

function setupCollision(turret)
	turret:SetTakeDamage(true)
	turret:SetMins(Vector(-5,-5,-5))
	turret:SetMaxs(Vector(5,5,5))
	turret:SetClip(1)
	turret:SetHealth(TURRET_HEALTH)
	
	local pain = function(ent,a,b,take)
		sendTurretStat(ent,1,ent:GetHealth()/TURRET_HEALTH)
	end
	turret:SetCallback(ENTITY_CALLBACK_PAIN,pain)
	
	local death = function(ent,a,b,take)
		if(ent:GetTable().done == 0) then
			ent:GetTable().done = 1
			ent:SetNextThink(LevelTime() + 1)
			sendTurretStat(ent,1,0)
			sendTurretStat(ent,2,0)
			print("TURRET_DEATH")
		end
	end
	turret:SetCallback(ENTITY_CALLBACK_DIE,death)
end

function bounce(ent,trace)
	local tr = ent:GetTrajectory()
	local hitTime = LastTime() + ( LevelTime() - LastTime() ) * trace.fraction;
	local vel = tr:EvaluateDelta(hitTime)
	local dot = DotProduct( vel, trace.normal );
	local delta = vAdd(vel,vMul(trace.normal,-2*dot))
	delta = vMul(delta,.5)

	tr:SetBase(ent:GetPos())
	tr:SetDelta(delta)
	ent:SetTrajectory(tr)
	
	ent:SetPos(vAdd(ent:GetPos(),trace.normal))
end

function etest(ent)
	if(ent == nil or ent:IsPlayer() == false) then return end
	if(ent:GetInfo().team == TEAM_SPECTATOR) then return end
	local forward = VectorForward(ent:GetAimVector())
	local startpos = vAdd(ent:GetMuzzlePos(),vMul(forward,12))
	local ignore = ent
	local mask = 1
	
	local endpos = vAdd(startpos,vMul(forward,16))
	local res = TraceLine(startpos,endpos,ignore,mask)

	if(res.hit) then
		print("Hit\n")
	else
		print("No Hit\n")
	end

	local ang = vectoangles(forward)
	local ang2 = vMul(forward,360)
	local test = CreateEntity("turret")
	test:SetVelocity(vAdd(vMul(forward,300),ent:GetVelocity()))
	test:SetPos(res.endpos)
	test:SetAngles(ang)
	test:GetTable().owner = ent
	test:GetTable().team = ent:GetInfo().team
	
	setupCollision(test)
	
	local callback = function(ent,other,trace)
		local tab = ent:GetTable()
		if(!tab.notouch) then
			print("Flag_raw: " .. trace.contents .. "\n")
			print("Flag: " .. bitAnd(trace.contents,-2147483648) .. "\n")
			if(trace.contents != 1) then
				print("^1Invalid Surface\n")
				ent:Remove()
			end
			if(DotProduct(trace.normal,Vector(0,0,1)) > 0.2) then
				local vel = ent:GetVelocity()
				vel.z = 0
				if(VectorLength(vel) > 200) then
					bounce(ent,trace)
					return
				end
			else
				bounce(ent,trace)
				return
			end
			tab.shots = TURRET_SHOTS
			tab.expiration = LevelTime() + 10000
			ent:SetPos(vAdd(trace.endpos,Vector(0,0,2)))
			ent:SetTrType(TR_LINEAR)
			ent:SetVelocity(vMul(Vector(0,0,1),60))
			ent:SetNextThink(LevelTime() + 500)
			local ang1 = ent:GetAngles()
			local ang2 = vectoangles(trace.normal)
			ang2.x = ang2.x + 90
			ang2.y = ang1.y
			ent:SetAngles(ang2)
			print("Touch\n")
			tab.notouch = true
			tab.done = 0
			tab.nextShot = LevelTime() + 50
		else
			if(other == tab.owner) then
				refill(ent,other,1)
			end
		end
	end
	test:SetCallback(ENTITY_CALLBACK_TOUCH,callback)
	
	local callback2 = function(ent)
		local tab = ent:GetTable()
		if(tab.done != 0) then
			if(tab.done == 1) then
				ent:SetNextThink(LevelTime() + 1000)
				tab.done = 2
				print("Finish\n")
			elseif(tab.done == 2) then
				--sendTurretMsg(ent,3)
				ent:SetPos(ent:GetPos())
				ent:SetTrType(TR_LINEAR)
				ent:SetVelocity(vMul(Vector(0,0,1),-60))
				ent:SetNextThink(LevelTime() + 800)
				--print("Sink\n")
				tab.done = 3
			else
				--print("Removed\n")
				ent:Remove()
			end
			return;
		end
		if(!ent:GetTable().ready) then
			ent:SetPos(ent:GetPos())
			ent:SetTrType(TR_STATIONARY)
			sendTurretStart(ent,tab.team)
			tab.ready = true
			ent:SetNextThink(LevelTime() + 100)
		else
			if(tab.owner:GetInfo().team != tab.team) then
				tab.done = 1
			end
			if(tab.shots <= 1) then
				ent:SetHealth(ent:GetHealth() - 1)
				sendTurretStat(ent,1,ent:GetHealth()/TURRET_HEALTH)
				if(ent:GetHealth() <= 0) then
					ent:GetTable().done = 1
				end
			end
			if(aimTurret(ent)) then
				if(tab.nextShot < LevelTime()) then
					fireTurret(ent)
					tab.nextShot = LevelTime() + 50
					if(tab.shots <= 1) then
						tab.nextShot = LevelTime() + 250
					end
				end
			else
				if(ent:GetHealth() < TURRET_HEALTH and tab.shots > 1) then
					ent:SetHealth(ent:GetHealth() + 1)
					sendTurretStat(ent,1,ent:GetHealth()/TURRET_HEALTH)
				end
			end
			ent:SetNextThink(LevelTime() + 20)
		end
		--ent:SetNextThink(LevelTime())
	end
	test:SetCallback(ENTITY_CALLBACK_THINK,callback2)

	--Timer(5,function() if(test != nil) then test:Remove() end end)
end
concommand.Add("etest",etest)

print("^3Loaded Turrets\n")