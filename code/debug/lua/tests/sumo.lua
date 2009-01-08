local weapMods = {
	[WP_GAUNTLET] = MOD_GAUNTLET,
	[WP_MACHINEGUN] = MOD_MACHINEGUN,
	[WP_SHOTGUN] = MOD_SHOTGUN,
	[WP_GRENADE_LAUNCHER] = MOD_GRENADE,
	[WP_ROCKET_LAUNCHER] = MOD_ROCKET,
	[WP_LIGHTNING] = MOD_LIGHTNING,
	[WP_RAILGUN] = MOD_RAILGUN,
	[WP_PLASMAGUN] = MOD_PLASMA,
	[WP_BFG] = MOD_BFG,
}

local function stopResetTimer(self,attacker)
	if(attacker != nil) then
		if(self:GetTable().lastAttacker != nil) then
			if(self:GetTable().lastAttacker != attacker) then
				return false
			end
		end
	end
	local rt = self:GetTable().resettimer
	if(rt != nil) then
		StopTimer(rt)
	end
	return true
end

local function makeResetTimer(self,attacker)
	if(stopResetTimer(self,attacker)) then
		local function resetAttacker(ent)
			if(ent:GetTable().lastAttacker != nil) then
				local atk = ent:GetTable().lastAttacker:GetInfo().name
				print(ent:GetInfo().name .. " ^5Reset Attacker^7 " .. atk .. "\n")
				ent:GetTable().lastAttacker = nil
			end
		end	
		self:GetTable().resettimer = Timer(4,resetAttacker,self)
		return true
	end
	return false
end

local function modFromWeapon(weap)
	return weapMods[weap] or MOD_GAUNTLET;
end

local function PlayerSpawned(cl)
	cl:GetTable().velPeak = 0
	cl:GetTable().lastAttacker = nil
	stopResetTimer(cl,nil)
end

local function vlen(v)
	return math.sqrt((v.x*v.x) + (v.y*v.y) + (v.z*v.z))
end

local function trDown(pl)
	local pos = pl:GetPos()
	local endpos = vAdd(pos,Vector(0,0,-100))
	local res = TraceLine(pos,endpos,pl,1)
	return (res.fraction != 1)
end

local function DamageCredit(self,inflictor,attacker,damage,meansOfDeath,dir,point)
	local la = self:GetTable().lastAttacker
	if(attacker != nil && attacker:IsPlayer() && la == nil && attacker != self and trDown(self)) then
		if(makeResetTimer(self,attacker)) then
			local p1 = self:GetInfo()["name"]
			local p2 = attacker:GetInfo()["name"]
			print(p1 .. " ^5Got New Attacker^7 " .. p2 .. "\n")
			self:GetTable().lastAttacker = attacker
			self:GetTable().lastWeapon = attacker:GetInfo().weapon
		end
	end
	if(la) then
		makeResetTimer(self,attacker)
		if(attacker == nil || attacker:IsPlayer() == false) then
			la:GetTable().mondo = true
			self:Damage(la,la,damage*2,modFromWeapon(self:GetTable().lastWeapon))
			la:GetTable().mondo = false
		end
		return 0
	end
end

local function DamagePush(self,inflictor,attacker,damage,meansOfDeath,dir,point)
	if(dir) then
		local pvel = self:GetVelocity()
		
		local dmg = damage
		if(dmg > 10) then dmg = 10 end
		
		local nvel = 40*dmg
		if(meansOfDeath == MOD_SHOTGUN) then
			nvel = nvel / 2
		end
		
		if(meansOfDeath == MOD_GAUNTLET) then
			nvel = nvel * 4
		end
		
		if(meansOfDeath == MOD_ROCKET) then
			nvel = nvel * 4
		end
		
		if(meansOfDeath == MOD_ROCKET_SPLASH) then
			nvel = nvel * 2
		end
		
		if(meansOfDeath == MOD_RAILGUN) then
			nvel = nvel * 6
		end
		
		pvel = vAdd(pvel,vMul(dir,nvel))
		
		self:SetVelocity(pvel)
	end
	return damage
end

local function RealFallDamage(self,inflictor,attacker,damage,meansOfDeath,dir,point)
	local la = self:GetTable().lastAttacker
	if(attacker and attacker:GetTable().mondo == true) then
		print("FULL\n")
		return damage
	end
	if(meansOfDeath == MOD_FALLING) then
		local dpeak = math.abs(self:GetTable().velPeak) / 100
		local rpeak = dpeak - 6
		
		if(rpeak < 1) then rpeak = 1 end
		
		damage = damage * math.floor(rpeak)
		
		self:GetTable().velPeak = 0
		self:GetTable().sentfallsound = false
		
		return damage
	end
	if(self:GetInfo()["health"] <= 0) then
		DamagePush(self,inflictor,attacker,damage,meansOfDeath,dir,point)
		return 0;
	end
	if(meansOfDeath == MOD_TRIGGER_HURT) then
		if(la) then
			la:GetTable().mondo = true
			self:Damage(la,la,9999,modFromWeapon(self:GetTable().lastWeapon))
			la:GetTable().mondo = false
			return 0
		end
		return damage
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
			local spd = pvel.z
			local tab = v:GetTable()
			
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

hook.add("Think","Sumo",velTest)
hook.add("PlayerSpawned","Sumo",PlayerSpawned)
hook.add("PrePlayerDamaged","Sumo",AuxDamage)