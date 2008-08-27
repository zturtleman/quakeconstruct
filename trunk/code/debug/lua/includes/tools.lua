QLUA_DEBUG = false;

function killGaps(line)
	line = string.Replace(line," ","")
	line = string.Replace(line,"\t","")
	return line
end

function fixcolorstring(s)
	while true do
		local pos = string.find(s, '^', 0, true)

		if (pos == nil) then
			break
		end	
		
		local left = string.sub(s, 1, pos-1)
		local right = string.sub(s, pos + 2)
		s = left .. right
	end
	return s
end

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

function hexFormat(k)
	return string.gsub(k, ".", function (c)
	return string.format("%02x", string.byte(c))
	end)
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

print("^3Tools loaded.\n")