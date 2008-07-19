print("^4This ^2is ^6a ^1test!\n") --First Line Of QLUA I've Written (and worked), So It Stays Here.

require "guidedrockets"
--require "accention"
--require "sumo"

local function RemoveStuff()
	local tab = GetAllEntities()
	for k,v in ipairs(table.Copy(tab)) do
		local class = v:Classname()
		if(string.find(class,"rocket") or string.find(class,"bfg") or string.find(class,"grenade")) then
			print("Removed: " .. class .. "\n")
			v:Remove()
		end
	end
end
RemoveStuff()

local function ClientThink(cl)

end
hook.add("ClientThink",ClientThink)

local function PlayerSpawned(cl)
	print("Player Spawn.\n")
	cl:SetInfo(PLAYERINFO_HEALTH,100)
	if(!cl:IsBot()) then
		cl:GiveWeapon(WP_ROCKET_LAUNCHER)
		cl:SetWeapon(WP_ROCKET_LAUNCHER)
		cl:SetAmmo(WP_ROCKET_LAUNCHER,-1)

		cl:GiveWeapon(WP_GRENADE_LAUNCHER)
		cl:SetWeapon(WP_GRENADE_LAUNCHER)
		cl:SetAmmo(WP_GRENADE_LAUNCHER,-1)
		
		cl:GiveWeapon(WP_PLASMAGUN)
		cl:SetWeapon(WP_PLASMAGUN)
		cl:SetAmmo(WP_PLASMAGUN,-1)
	end
	
	local touch = function(ent,other,trace)
		if(ent and other) then
			local entName = ent:Classname()
			local otherName = other:Classname()
			if(entName == "player") then entName = ent:GetInfo()["name"] end
			if(otherName == "player") then otherName = ent:GetInfo()["name"] end
			
			print("Entities Touching: ")
			print(entName .. "^7->" .. otherName .. "\n")
			
			if(trace.endpos) then
				local traceto = vAdd(ent:GetPos(),{x=0,y=0,z=30})
				local res = TraceLine(ent:GetPos(),traceto,ent)
				print(res.fraction .. "\n")
				ent:AddEvent(EV_MISSILE_HIT,0)
				--CreateTempEntity(res.endpos,EV_DEATH1)
			end
		end
	end
	cl:SetCallback(ENTITY_CALLBACK_TOUCH, touch)
end

local function JetPak()
	for k,v in pairs(GetAllEntities()) do
		if(v:IsPlayer() and v:GetInfo()["health"] > 0 and v:IsBot() == false) then
			local tab = GetEntityTable(v)
			if(tab.fly) then
				local vec = VectorForward(v:GetAimVector())
				
				local pvel = v:GetVelocity()
				
				local normal = VectorNormalize(pvel)
				normal = vAdd(normal,vMul(vSub(vec,normal),0.6))
				
				pvel = vMul(normal,440)
				
				v:SetVelocity(pvel)
			end
		end
	end
end

local function FlyTime()
	for k,v in pairs(GetAllPlayers()) do
		if(v:IsPlayer() and v:GetInfo()["health"] > 0 and v:IsBot() == false) then
			local bits = v:GetInfo()["buttons"];
			local tab = GetEntityTable(v)
			
			local filter = bitAnd(bits,16)
			if(filter != 0) then 
				if(tab.wasup) then
					if(tab.fly == nil) then tab.fly = false end
					tab.fly = !tab.fly
					tab.wasup = false
				end
			else
				tab.wasup = true
			end
			
			if(tab.fly) then
				v:SetPowerup(PW_FLIGHT,POWERUP_FOREVER)
			else
				v:SetPowerup(PW_FLIGHT,-1)
			end
		end
	end
end

local weaponKnockback = {
	[WP_GAUNTLET] = 0,
	[WP_MACHINEGUN] = 100,
	[WP_SHOTGUN] = 400,
	[WP_GRENADE_LAUNCHER] = 500,
	[WP_ROCKET_LAUNCHER] = 600,
	[WP_LIGHTNING] = 60,
	[WP_RAILGUN] = 800,
	[WP_PLASMAGUN] = 80,
	[WP_BFG] = 700,
}

local function FiredWeapon(player,weapon,delay,pos,angle)
	if(!player:IsBot()) then
		local angle = VectorForward(angle)
		local wname = EnumToString(weapon_t,weapon)
		--print(wname .. "\n")
		--print(angle.x .. "," .. angle.y .. "," .. angle.z .. "\n")
		
		local vec = player:GetVelocity()
		local vx = vec.x
		local vy = vec.y
		local vz = vec.z
		
		local knock = weaponKnockback[weapon]
		
		if(knock) then
			vx = vx + angle.x*-knock
			vy = vy + angle.y*-knock
			vz = vz + angle.z*-knock
		end
		
		--player:SetVelocity({x=vx,y=vy,z=vz})
		
		return delay/4--delay/4
	end
end
hook.add("FiredWeapon",FiredWeapon)

function woo(ent,cmd,args)
	for k,v in pairs(GetAllEntities()) do
		if(v:IsPlayer()) then
			v:Damage(10000)
		end
	end
end
concommand.Add("killall",woo)

local function pickspawn()
	local tab = GetEntitiesByClass("info_player_start")
	table.Add(tab,GetEntitiesByClass("info_player_deathmatch"))
	print("# of spawns: " .. #tab .. "\n")
	local point = tab[math.random(1,#tab)]
	if(point != nil) then
		return point
	end
	return nil
end

local function NoFallDamage(self,inflictor,attacker,damage,meansOfDeath)
	if(meansOfDeath == MOD_FALLING) then
		return 0
	end
	
	--[[if(attacker != nil and self != nil) then
		if(attacker:IsPlayer() and self:IsPlayer()) then
			if(!attacker:IsBot() and self:IsBot()) then
				return damage
			else
				return 0
			end
		end
	end]]

	if(self) then
		if(meansOfDeath == MOD_TRIGGER_HURT) then
			local spawn = pickspawn()
			if(spawn) then
				self:SetVelocity({x=0,y=0,z=0})
				self:SetPos(spawn:GetPos())
				CreateTempEntity(vAdd(self:GetPos(),{x=0,y=0,z=10}),EV_PLAYER_TELEPORT_IN)
				return 0
			end
		end
	end
end

hook.add("PlayerDamaged",NoFallDamage)

function button11(ent,cmd,args)
	print("PRESSED: " .. cmd .. "!\n")
end
concommand.Add("button16",button11)

--hook.add("Think",JetPak)
hook.add("Think",FlyTime)
hook.add("PlayerSpawned",PlayerSpawned)