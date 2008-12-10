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
}

local function removeWeapons()
	for k,v in pairs(GetAllEntities()) do
		if(string.find(v:Classname(),"weapon_")) then
			v:Remove()
		end
	end
end

local function setupPlayer(pl)
	pl:RemoveWeapons() --Remove all of the player's weapons
	pl:GiveWeapon(WP_RAILGUN) --Give the player a railgun
	pl:SetAmmo(WP_RAILGUN,-1) -- -1 will make the ammo numbers go away :)
	pl:SetWeapon(WP_RAILGUN) --Set the railgun as the active weapon
	if(pl:IsBot()) then pl:SetAmmo(WP_RAILGUN,999) end --Bots need full ammo or they won't shoot
end
hook.add("PlayerSpawned","instagib",setupPlayer)

local function PreDamage(self,inflictor,attacker,damage,dtype)
	if(attacker) then
		if(attacker:GetInfo().weapon == WP_RAILGUN) then
			--If the player was hit with a railgun
			return 10000 --Just gib the player
		end
	end
	if(let[dtype] == nil) then
		return 0 --If we don't have an exception (aka hazard) then don't damage the player
	end
end
hook.add("PrePlayerDamaged","instagib",PreDamage)

local function FiredWeapon(player,weapon,delay,pos,angle)
	if(weapon == WP_RAILGUN) then
		return delay/2 --Twice the fire rate
	end
end
hook.add("FiredWeapon","instagib",FiredWeapon)
hook.add("ShouldDropItem","instagib",function() return false end) --Don't drop items (like railguns)

--Remove weapon pickups and outfit players
removeWeapons()
for k,v in pairs(GetAllPlayers()) do
	setupPlayer(v)
end