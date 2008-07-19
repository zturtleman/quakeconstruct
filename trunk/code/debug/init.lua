print("^4This ^2is ^6a ^1test!\n")

local players = {}

local entsToCount = {
	"weapon_gauntlet",
	"weapon_machinegun",
	"weapon_shotgun",
	"weapon_grenadelauncher",
	"weapon_rocketlauncher",
	"weapon_lightning",
	"weapon_railgun",
	"weapon_plasmagun",
	"weapon_bfg"
}

local weaps = {
	"WP_GAUNTLET",
	"WP_MACHINEGUN",
	"WP_SHOTGUN",
	"WP_GRENADE_LAUNCHER",
	"WP_ROCKET_LAUNCHER",
	"WP_LIGHTNING",
	"WP_RAILGUN",
	"WP_PLASMAGUN",
	"WP_BFG",
}--"WP_GRAPPLING_HOOK",
for k,v in pairs(weaps) do _G[v] = k end

function CurTime()
	return LevelTime()/1000
end
nexths = CurTime() + 1

function Think()
	local tab = GetAllEntities()
	for k,v in pairs(tab) do
		if(IsPlayer(v)) then
			local weap = GetPlayerInfo(v)["weapon"]
			--pcall(PlayerSetAmmo,v,weap,100) --No Errors Please.
			
			if(nexths < CurTime()) then
				nexths = CurTime() + 1
				if(GetPlayerInfo(v)["health"] > -20) then
					--SetPlayerInfo(v,PLAYERINFO_HEALTH,GetPlayerInfo(v)["health"]-10)
				end
			end
		end
	end
end

function RemoveStuff()
	local tab = GetAllEntities()
	for k,v in pairs(tab) do
		local class = GetClassname(v)
		if(string.find(class,"weapon") or string.find(class,"ammo") or string.find(class,"item_armor")) then
			RemoveEntity(v)
		end
	end
end
RemoveStuff()

function GetPlayerTable(cl)
	for k,v in pairs(players) do
		if(v.client == cl) then
			return v.vars
		end
	end
end

function CreatePlayerTable(cl)
	table.insert(players,{client=cl,vars={}})
end

function RemovePlayerTable(cl)
	for k,v in pairs(players) do
		if(v.client == cl) then
			table.remove(players,k)
		end
	end
end

function SetNextWeap(cl)
	if not (GetPlayerInfo(cl)["weapon"] == WP_BFG) then
		GetPlayerTable(cl).nextWeap = GetPlayerInfo(cl)["weapon"]+1
	end
end

function ApplyNextWeap(cl)
	print("^5Next Weap\n")
	local tab = GetPlayerTable(cl)
	print("^5Next Weapon: " .. tab.nextWeap .. "\n")
	PlayerRemoveWeapons(cl)
	
	PlayerGiveWeapon(cl,WP_GAUNTLET)
	PlayerSetAmmo(cl,WP_GAUNTLET,-1)
	
	PlayerGiveWeapon(cl,tab.nextWeap)
	PlayerSetWeapon(cl,tab.nextWeap)
	PlayerSetAmmo(cl,tab.nextWeap,-1)
	SetNextWeap(cl)
end

function PlayerSpawned(cl)
	--local mx = math.random(1,5)
	--for i=1,mx do
	
	--local randomweap = math.random(1,#weaps)
	--PlayerGiveWeapon(cl,randomweap)
	--PlayerSetAmmo(cl,randomweap,math.random(1,9)*25)
	--PlayerSetWeapon(cl,randomweap)
	--end
	
	GetPlayerTable(cl).nextWeap = 2
	ApplyNextWeap(cl)
	SetPlayerInfo(cl,PLAYERINFO_HEALTH,100)
end

function PlayerJoined(cl)
	print("A Player Has Joined\n")
	print("The Player's Name Is: " .. GetPlayerInfo(cl)["name"] .. "\n")
	print("He Has " .. GetPlayerInfo(cl)["health"] .. " health.\n")
	CreatePlayerTable(cl)
end

function DamageInfo(self,inflictor,attacker,damage,meansOfDeath,killed)
	local m = "Damaged"
	if(killed) then m = "Killed" end
	print("A Player Was " .. m .. "\n")
	print("INFLICTOR: " .. GetClassname(inflictor) .. "\n")
	
	if(GetClassname(attacker) == "player") then
		print("ATTACKER: " .. GetPlayerInfo(attacker)["name"] .. "\n")
	else
		print("ATTACKER: " .. GetClassname(attacker) .. "\n")
	end
	
	print("DAMAGE: " .. damage .. "\n")
	print("MOD: " .. meansOfDeath .. "\n")
	print("The Target's Name Is: " .. GetPlayerInfo(self)["name"] .. "\n")
end

function PlayerKilled(self,inflictor,attacker,damage,meansOfDeath)
	--DamageInfo(self,inflictor,attacker,damage,meansOfDeath,true)
	local weap = GetPlayerInfo(attacker)["weapon"]
	if(IsPlayer(attacker)) then ApplyNextWeap(attacker) end
	--PlayerSpawned(attacker)
end

function PlayerDamaged(self,inflictor,attacker,damage,meansOfDeath)
	--DamageInfo(self,inflictor,attacker,damage,meansOfDeath,false)
	--SetPlayerInfo(self,PLAYERINFO_HEALTH,GetPlayerInfo(self)["health"]+damage)
	--DamagePlayer(self,inflictor,attacker,damage*5,meansOfDeath)
	print(meansOfDeath .. "\n")
	return damage
end

function PlayerDisconnected(cl)
	RemovePlayerTable(cl)
	print("Player Disconnect.\n")
end

sendToAll("Why Hello Thar!\n")