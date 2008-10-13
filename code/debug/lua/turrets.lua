MAX_TURRET_DIST = 500

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
	
	return res.entity
end

function sendTurretMsg(ent,val)
	for k,v in pairs(GetEntitiesByClass("player")) do
		local msg = Message(v)
		message.WriteLong(msg,4)
		message.WriteLong(msg,val)
		message.WriteLong(msg,ent:EntIndex())
		SendDataMessage(msg)
	end
end

function sendTurretFire(ent,dir)
	for k,v in pairs(GetEntitiesByClass("player")) do
		local msg = Message(v)
		message.WriteLong(msg,4)
		message.WriteLong(msg,2)
		message.WriteLong(msg,ent:EntIndex())
		message.WriteFloat(msg,dir.x)
		message.WriteFloat(msg,dir.y)
		message.WriteLong(msg,MAX_TURRET_DIST)
		SendDataMessage(msg)
	end
end

function fireTurret(ent)
	local tab = ent:GetTable()
	local dir = Vector(0,0,0)
	dir.x = math.random(-60,60)
	dir.y = math.random(-60,60)
	sendTurretFire(ent,dir)
	local pl = traceit(ent,dir.x,dir.y)
	if(pl != nil) then
		pl:Damage(ent,ent:GetTable().owner,math.random(5,10),MOD_MACHINEGUN)
	end
	tab.shots = tab.shots - 1
	if(tab.shots < 1) then
		tab.done = 1
	end
end

function aimTurretAt(ent,pos)
	--Use DotProduct so we don't waste ammo
	local entang = ent:GetAngles()
	local aim = VectorNormalize(vSub(pos,ent:GetPos()))
	local aim = vectoangles(aim)
	local ang = vAdd(entang,vMul(getDeltaAngle3(aim,entang),.2))
	local vf1 = VectorRight(entang)
	local vf2 = VectorRight(aim)
	local dp = DotProduct(vf2,vf1)--VectorLength(vMul(vSub(vf2,vf1),100))/100
	ent:SetAngles(ang)
	print(dp .. "\n")
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
		if(v != owner and v:GetInfo().health > 0) then
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
	end
	
	if(LevelTime() > tab.expiration) then
		--tab.done = 1
	end
	return false
end

function etest(ent)
	if(ent == nil or ent:IsPlayer() == false) then return end
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
	local test = CreateEntity("testent")
	test:SetVelocity(vAdd(vMul(forward,300),ent:GetVelocity()))
	test:SetPos(res.endpos)
	test:SetAngles(ang)
	test:GetTable().owner = ent
	
	local callback = function(ent,other,trace)
		local tab = ent:GetTable()
		if(!tab.notouch) then
			print("Flag_raw: " .. trace.contents .. "\n")
			print("Flag: " .. bitAnd(trace.contents,-2147483648) .. "\n")
			if(trace.contents != 1) then
				print("^1Invalid Surface\n")
				ent:Remove()
			end
			if(trace.normal.x == 0 and trace.normal.y == 0 and trace.normal.z == 1) then
				
			else
				ent:Remove()
			end
			tab.shots = 100
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
				sendTurretMsg(ent,3)
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
			sendTurretMsg(ent,1)
			tab.ready = true
			ent:SetNextThink(LevelTime() + 100)
		else
			if(aimTurret(ent)) then
				if(tab.nextShot < LevelTime()) then
					fireTurret(ent)
					tab.nextShot = LevelTime() + 50
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