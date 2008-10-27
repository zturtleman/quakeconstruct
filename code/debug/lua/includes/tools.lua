QLUA_DEBUG = false;

function killGaps(line)
	line = string.Replace(line," ","")
	line = string.Replace(line,"\t","")
	return line
end

function ProfileFunction(func,...)
	local tps = ticksPerSecond()
	local s = ticks() / 1000
	pcall(func,arg)
	local e = ticks() / 1000
	return e - s
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
		if(SERVER) then
			print("SV: " .. msg)
		else
			print("CL: " .. msg)
		end
	end
end

function hexFormat(k)
	return string.gsub(k, ".", function (c)
	return string.format("%02x", string.byte(c))
	end)
end

if(CLIENT) then
function drawNSBox(x,y,w,h,v,shader,nocenter)
	local d = 1/3
	draw.Rect(x,y,v,v,shader,0,0,d,d)
	draw.Rect(x+v,y,v+(w-v*3),v,shader,d,0,d*2,d)
	draw.Rect(x+(w-v),y,v,v,shader,d*2,0,d*3,d)
	
	draw.Rect(x,y+v,v,v+(h-v*3),shader,0,d,d,d*2)
	if(!nocenter) then draw.Rect(x+v,y+v,v+(w-v*3),v+(h-(v*3)),shader,d,d,d*2,d*2) end
	draw.Rect(x+(w-v),y+v,v,v+(h-(v*3)),shader,d*2,d,d*3,d*2)
	
	draw.Rect(x,y+(h-v),v,v,shader,0,d*2,d,d*3)
	draw.Rect(x+v,y+(h-v),v+(w-v*3),v,shader,d,d*2,d*2,d*3)
	draw.Rect(x+(w-v),y+(h-v),v,v,shader,d*2,d*2,d*3,d*3)
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

print("^3Tools loaded.\n")