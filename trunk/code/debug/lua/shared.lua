<<<<<<< .mine
AddItem(
"item_test",
IT_AMMO,
WP_GRAPPLING_HOOK,
"icons/iconw_grapple",
"Test Item",
"sound/misc/w_pkup.wav",
100,
"models/powerups/health/medium_cross.md3")

AddItem(
"item_test2",
IT_AMMO,
WP_GRAPPLING_HOOK,
"icons/iconw_grapple",
"Test Item2",
"sound/misc/w_pkup.wav",
100,
"models/powerups/health/medium_cross.md3")=======
print("^1SHARED\n")

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
end>>>>>>> .r413
