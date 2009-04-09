downloader.add("lua/configurator/cl_init.lua")

vars = vars or {
	{"wp_delay",100},
	{"wp_damage",100},
}

local function getValue(var)
	return vars[var]
end

local weapons = GetEnumSet(weapon_t,val)

for k,v in pairs(weapons) do
	print(v.name .. "\n")
end

local function message(str,pl)
	local args = string.Explode(" ",str)
	if(args[1] == "cnfvar") then
		local var = args[2]
		local val = tonumber(args[3])
		vars[var] = val
		
		for k,v in pairs(GetAllPlayers()) do
			v:SendMessage(var .. " = " .. val,true)
		end
	end
end
hook.add("MessageReceived","configurator",message)

local function weapFire(player,weapon,delay,pos,angle)
	return delay * (getValue("wp_delay")/100)
end
hook.add("FiredWeapon","configurator",weapFire)

local function PreDamage(self,inflictor,attacker,damage,dtype) 
	if(dtype <= MOD_BFG_SPLASH) then
		return damage * (getValue("wp_damage")/100)
	end
end
hook.add("PrePlayerDamaged","configurator",PreDamage)