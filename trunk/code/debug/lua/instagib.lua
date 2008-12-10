IG_RELOADTIME = 2000

STAT_SHOTS = 1
STAT_HITS = 2
STAT_DEATHS = 4

local let = {
	[MOD_UNKNOWN] = 1,
	[MOD_WATER] = 1,
	[MOD_SLIME] = 1,
	[MOD_LAVA] = 1,
	[MOD_CRUSH] = 1,
	[MOD_TELEFRAG] = 1,
	[MOD_SUICIDE] = 1,
	[MOD_TARGET_LASER] = 1,
	[MOD_TRIGGER_HURT] = 1,
	--Hazards respawn the player
}

message.Precache("igrailfire")
message.Precache("igstat")

local function pickspawn()
	local tab = GetEntitiesByClass("info_player_start")
	table.Add(tab,GetEntitiesByClass("info_player_deathmatch"))
	local point = tab[math.random(1,#tab)]
	if(point != nil) then
		return point
	end
	return nil
end

local function fullHealth(self) 
	--Simple function set's player's health to full and set's a timer to do so after damage
	self:SetHealth(100)
	Timer(.001,self.SetHealth,self,100)
end

local function removePickups()
	for k,v in pairs(GetAllEntities()) do --Loop through all the entities
		if(string.find(v:Classname(),"weapon")) then
			v:Remove() --If an entity's name contains 'weapon', remove it
		end
		if(string.find(v:Classname(),"ammo")) then
			v:Remove() --If an entity's name contains 'ammo', remove it
		end
		if(string.find(v:Classname(),"armor")) then
			v:Remove() --If an entity's name contains 'armor', then remove it
		end
		if(string.find(v:Classname(),"health")) then
			v:Remove() --If an entity's name contains 'health', then remove it
		end
		if(string.find(v:Classname(),"item")) then
			v:Remove() --If an entity's name contains 'item', then remove it
		end
	end
end

local function sendStat(pl,s)
	local msg = Message()
	message.WriteShort(msg,s)
	message.WriteShort(msg,pl:GetTable().stats[s])
	SendDataMessage(msg,pl,"igstat")
end

local function setStat(pl,s,i)
	pl:GetTable().stats = pl:GetTable().stats or {}
	pl:GetTable().stats[s] = i
	sendStat(pl,s)
end

local function addStat(pl,s,i)
	pl:GetTable().stats = pl:GetTable().stats or {}
	pl:GetTable().stats[s] = pl:GetTable().stats[s] or 0
	pl:GetTable().stats[s] = pl:GetTable().stats[s] + i
	sendStat(pl,s)
end

local function setupPlayer(pl)
	fullHealth(pl)
	pl:RemoveWeapons() --Remove all of the player's weapons
	local function go()
		pl:GiveWeapon(WP_RAILGUN) --Give the player a railgun
		pl:SetAmmo(WP_RAILGUN,-1) -- -1 will make the ammo numbers go away :)
		pl:SetWeapon(WP_RAILGUN) --Set the railgun as the active weapon
	end
	pl:SetSpeed(1.5)
	if(pl:IsBot()) then pl:SetAmmo(WP_RAILGUN,999) end --Bots need full ammo or they won't shoot
	pl:SetPowerup(PW_INVIS,3000)
	pl:GetTable().gi_invistime = LevelTime() + 3000
	Timer(2.5,go)
end

local function spawnPlayer(self)
	local spawn = pickspawn()
	if(spawn) then
		self:SetVelocity(Vector())
		self:SetPos(spawn:GetPos())
		CreateTempEntity(vAdd(self:GetPos(),Vector(0,0,10)),EV_PLAYER_TELEPORT_IN)
		local angles = spawn:GetAngles()
		if(angles) then
			self:SetAngles(angles)
		end
		--setupPlayer(self)
	end
end

local function PreDamage(self,inflictor,attacker,damage,dtype) 
	--PreDamage is called BEFORE the player is damaged, and the returned value is the amount of damage the player will take
	self:GetTable().gi_invistime = self:GetTable().gi_invistime or 0
	if(attacker) then
		if(attacker:GetInfo().weapon == WP_RAILGUN) then
			if(self:GetTable().gi_invistime > LevelTime()) then
				fullHealth(self)
				return 0; --No damage to invisibles
			end
			--If the player was hit with a railgun
			addStat(attacker,STAT_HITS,1)
			addStat(self,STAT_DEATHS,1)
			return 200 --Just gib the player (loads of damage)
		end
	end
	if(let[dtype] == nil) then
		fullHealth(self)
		return 0 --If we don't have an exception (aka hazard) then don't damage the player
		--This makes it so that the player doesn't take falling damage
	else
		--Respawn the player when he touches a hazard
		spawnPlayer(self)
		fullHealth(self)
		return 0
	end
end

local function FiredWeapon(player,weapon,delay,pos,angle)
	if(weapon == WP_RAILGUN and player != nil) then
		local rt = IG_RELOADTIME
		local maxv = 800
		local rv = maxv - VectorLength(player:GetVelocity())
		if(rv < 0) then rv = 0 end
		rv = rv + 800
		--rv = rv / 4
		--if(VectorLength(player:GetVelocity()) > 200) then rt = rt / 2 end
		local msg = Message()
		message.WriteLong(msg,LevelTime())
		message.WriteLong(msg,LevelTime() + rv)
		SendDataMessage(msg,player,"igrailfire")
		addStat(player,STAT_SHOTS,1)
		return rv --fire rate
	end
end
hook.add("PlayerSpawned","instagib",setupPlayer)
hook.add("PrePlayerDamaged","instagib",PreDamage)
hook.add("FiredWeapon","instagib",FiredWeapon)
hook.add("ShouldDropItem","instagib",function() return false end) --Don't drop items (like railguns)
hook.add("PlayerKilled","instagib",function(p)  end)
--Timer(1.5,spawnPlayer,p)
--Remove pickups and outfit players
removePickups()
for k,v in pairs(GetAllPlayers()) do
	setupPlayer(v)
	setStat(v,STAT_SHOTS,0)
	setStat(v,STAT_HITS,0)
end

SendScript("lua/cl_instagib.lua")


local function reloadTime(p,c,a)
	if(a[1] == nil) then return end
	local n = tonumber(a[1])
	if(n != nil) then IG_RELOADTIME = n end
end
concommand.Add("ReloadTime",reloadTime,true)