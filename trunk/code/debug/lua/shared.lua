print("^1SHARED\n")

include("lua/states.lua")

AddItem(0,
"ammo_laserblazer",
IT_AMMO,
WP_RESERVED0,
"icons/iconw_grapple",
"Laser Blazer Ammo",
"sound/misc/am_pkup.wav",
15,
"models/weapons2/rocketl/rocketl.md3")

AddItem(1,
"weapon_laserblazer",
IT_WEAPON,
WP_RESERVED0,
"icons/iconw_grapple",
"Laser Blazer",
"sound/misc/w_pkup.wav",
10,
"models/weapons2/rocketl/rocketl.md3")

if(SERVER) then
	local function wfired(cl,wp,delay,muzzle,angles)
		if(wp == WP_RESERVED0) then
			local player = GetAllPlayers()[cl+1]
			local f,r,u = AngleVectors(angles)
			player:SetVelocity(f*-800)
			
			local tr = TraceLine(muzzle,muzzle + f*1000)
			local e = CreateTempEntity(tr.endpos,EV_RAILTRAIL)
			e:SetPos2(muzzle)
		end
	end
	hook.add("SVFiredWeapon","shared",wfired)
else
	local function register(wp)
		if(wp ~= WP_RESERVED0) then return end
		print("^1Registered: " .. wp .. "\n")
		local t =  {}
		t["flashSound"] = LoadSound("sound/world/jumppad.wav")
		return t
	end
	hook.add("RegisterWeapon","shared",register)
end

if(RESTARTED) then
	if(SERVER) then
		print("^2SV_RESTARTED\n")
	else
		print("^2CL_RESTARTED\n")
	end
end