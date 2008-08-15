QLUA_DEBUG = false;

function includesimple(s)
	include("lua/" .. s .. ".lua")
end

function CurTime()
	return LevelTime()/1000
end

function debugprint(msg)
	if(QLUA_DEBUG) then
		print(msg)
	end
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

POWERUP_FOREVER = 10000*10000