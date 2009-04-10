downloader.add("lua/configurator/cl_init.lua")

configurator_vars = configurator_vars or {}
local vars = configurator_vars

local function getValue(var,def)
	if(vars[var] == nil) then vars[var] = def end
	return vars[var]
end

local weapons = GetEnumSet(weapon_t,val)

for k,v in pairs(weapons) do
	print(v.name .. "\n")
end

local function message(str,pl)
	local args = string.Explode(" ",str)
	if(args[1] == "cnfvar") then
		local var = ""
		if(string.sub(args[2],0,1) != "-") then
			var = args[2]
			val = tonumber(args[3])
			vars[var] = val
			print("var " .. var .. "\n")
			if(var == "g_maxhp") then for k,v in pairs(GetAllPlayers()) do v:SetMaxHealth(val) end end
		else
			var = string.sub(args[2],2,string.len(args[2]))
			val = args[3]
			SetCvar(var,val)
			print("cvar " .. var .. "\n")
			if(var == "g_speed") then for k,v in pairs(GetAllPlayers()) do v:SetSpeed(1) end end
		end
		
		for k,v in pairs(GetAllPlayers()) do
			v:SendMessage(var .. " = " .. val,true)
		end
	elseif(args[1] == "gcnfvar") then
		if(string.sub(args[2],0,1) != "-") then
			var = args[2]
			local val = tostring(vars[var]) or ""
			if(val == "") then return end
			pl:SendString("rcnfvar " .. args[2] .. " " .. val)
		else
			var = string.sub(args[2],2,string.len(args[2]))
			pl:SendString("rcnfvar " .. args[2] .. " " .. GetCvar(var))
		end		
	end
end
hook.add("MessageReceived","configurator",message)

local function PlayerSpawned(player)
	player:SetHealth(getValue("g_starthp",125))
	player:SetMaxHealth(getValue("g_maxhp",100))
end
hook.add("PlayerSpawned","configurator",PlayerSpawned)

local function getVPercent(var)
	local v = getValue(var,100)
	if(v > 0) then
		v = v / 100
	else
		v = 0
	end
	return v
end

local function weapFire(player,wp,delay,pos,angle)
	local ndelay = delay * getVPercent("wp_delay")
	ndelay = ndelay * getVPercent("wp_cw" .. wp .. "_delay")
	return ndelay
end
hook.add("FiredWeapon","configurator",weapFire)

local dmg_str = "hz_damage_"
local damagestrings = {
	"water",
	"slime",
	"lava",
	"crush",
	"telefrag",
	"falling",
}

local function ClientThink(item,player,quantity,itype,itag)
	itype = EnumToString(itemType_t,itype)
	itype = string.sub(itype,string.len("IT_")+1,string.len(itype))
	itype = string.lower(itype)
	local old = quantity
	local new = old
	local v = getValue("pk_multiplier",1) * getValue("pk_mult_" .. itype,1)
	if(v != 1) then
		new = math.ceil(quantity * v)
		if(new < 1) then new = 1 end
	end
	
	print("Item Quantity " .. itype .. " - " .. old .. " => " .. new .. "\n")
	
	return new
end
hook.add("ItemPickupQuantity","configurator",ClientThink)

local function PreDamage(self,inflictor,attacker,damage,dtype) 
	if(dtype <= MOD_BFG_SPLASH) then
		local wp = MethodOfDeathToWeapon(dtype)
		local ndamage = damage * getVPercent("wp_damage")
		ndamage = ndamage * getVPercent("wp_cw" .. wp .. "_damage")
		return ndamage 
	end
	local dt2 = (dtype - MOD_BFG_SPLASH)
	if(dt2 > 0 and dt2 <= #damagestrings) then
		damage = damage * getVPercent(dmg_str .. damagestrings[dt2])
		return damage
	end
end
hook.add("PrePlayerDamaged","configurator",PreDamage)

concommand.add("configreset",function() 
	configurator_vars = {}; 
	vars = {};
	print("^2Reset Configurator Variables\n")
end,true)