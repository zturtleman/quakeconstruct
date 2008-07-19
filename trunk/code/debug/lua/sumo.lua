local function stopResetTimer(self,attacker)
	if(attacker != nil) then
		if(GetEntityTable(self).lastAttacker != nil) then
			if(GetEntityTable(self).lastAttacker != attacker) then
				return false
			end
		end
	end
	local rt = GetEntityTable(self).resettimer
	if(rt != nil) then
		StopTimer(rt)
	end
	return true
end

local function makeResetTimer(self,attacker)
	if(stopResetTimer(self,attacker)) then
		local function resetAttacker(ent)
			GetEntityTable(ent).lastAttacker = nil
		end	
		GetEntityTable(self).resettimer = Timer(4,resetAttacker,self)
		return true
	end
	return false
end

local function PlayerSpawned(cl)
	GetEntityTable(cl).velPeak = 0
	GetEntityTable(cl).lastAttacker = nil
	stopResetTimer(cl,nil)
end

local function vtable(v)
	local t = getmetatable(v)
	t.x = v:get("x")
	t.y = v:get("y")
	t.z = v:get("z")
end

local function vlen(v)
	return math.sqrt((v.x*v.x) + (v.y*v.y) + (v.z*v.z))
end

local function DamageCredit(self,inflictor,attacker,damage,meansOfDeath,dir,point)
	local la = GetEntityTable(self).lastAttacker
	if(attacker != nil && attacker:IsPlayer() && la == nil && attacker != self) then
		if(makeResetTimer(self,attacker)) then
			local p1 = self:GetInfo()["name"]
			local p2 = attacker:GetInfo()["name"]
			print(p1 .. " ^5Got New Attacker^7 " .. p2 .. "\n")
			GetEntityTable(self).lastAttacker = attacker
		end
	end
	if(la) then
		makeResetTimer(self,attacker)
		if(attacker == nil || attacker:IsPlayer() == false) then
			self:Damage(la,la,damage,MOD_SHOTGUN)
		end
		return 0
	end
	return damage
end

local function DamagePush(self,inflictor,attacker,damage,meansOfDeath,dir,point)
	if(dir) then
		local pvel = self:GetVelocity()
		vtable(pvel)
		vtable(dir)
		
		local dmg = damage
		if(dmg > 10) then dmg = 10 end
		
		local nvel = 40*dmg
		if(meansOfDeath == MOD_SHOTGUN) then
			nvel = nvel / 2
		end
		
		pvel:set("x",pvel:get("x") + dir.x*nvel)
		pvel:set("y",pvel:get("y") + dir.y*nvel)
		pvel:set("z",pvel:get("z") + dir.z*nvel)
		
		self:SetVelocity(pvel)
	end
	return damage
end

local function RealFallDamage(self,inflictor,attacker,damage,meansOfDeath,dir,point)
	if(meansOfDeath == MOD_FALLING) then
		local dpeak = math.abs(GetEntityTable(self).velPeak) / 100
		local rpeak = dpeak - 6
		
		if(rpeak < 1) then rpeak = 1 end
		
		damage = damage * math.floor(rpeak)
		
		GetEntityTable(self).velPeak = 0
		GetEntityTable(self).sentfallsound = false
		
		return damage
	end
	if(self:GetInfo()["health"] <= 0) then
		DamagePush(self,inflictor,attacker,damage,meansOfDeath,dir,point)
		return 0;
	end
	return 0
end

local function AuxDamage(self,inflictor,attacker,damage,meansOfDeath,dir,point)
	DamagePush(self,inflictor,attacker,damage,meansOfDeath,dir,point)
	DamageCredit(self,inflictor,attacker,damage,meansOfDeath,dir,point)
	return RealFallDamage(self,inflictor,attacker,damage,meansOfDeath,dir,point)
end

function velTest()
	for k,v in pairs(GetAllEntities()) do
		if(v:IsPlayer() and v:GetInfo()["health"] > 0) then
			local pvel = v:GetVelocity()
			vtable(pvel)
			local spd = pvel.z
			local tab = GetEntityTable(v)
			
			if(spd == 0) then
				tab.sentfallsound = false
				tab.velPeak = 0
			end
			if not (tab.velPeak) then
				tab.velPeak = 0
			end
			if(tab.velPeak > spd) then
				if(spd < -800) then
					if not (tab.sentfallsound) then
						--v:AddEvent(EV_TAUNT)
						v:PlaySound("*falling1.wav")
						tab.sentfallsound = true
					end
				end
				tab.velPeak = spd
			end
			local vp = tab.velPeak
			
			--print(spd .. " - " .. vp .. "\n")
		end
	end
end

hook.add("Think",velTest)
hook.add("PlayerSpawned",PlayerSpawned)
hook.add("PlayerDamaged",AuxDamage)