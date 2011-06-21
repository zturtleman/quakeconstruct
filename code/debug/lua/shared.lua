print("^1SHARED\n")

include("lua/weapons.lua")
include("lua/states.lua")

AddItem(0,false,
"ammo_laserblazer",
IT_AMMO,
WP_RESERVED0,
"icons/iconw_grapple",
"Laser Blazer Ammo",
"sound/misc/am_pkup.wav",
15,
"models/weapons2/rocketl/rocketl.md3")

AddItem(1,false,
"weapon_laserblazer",
IT_WEAPON,
WP_RESERVED0,
"icons/iconw_grapple",
"Laser Blazer",
"sound/misc/w_pkup.wav",
10,
"models/weapons2/rocketl/rocketl.md3")

--FindItemByClassname
local function ReplaceItem(item,...)
	local it = FindItemByClassname(item)
	if(it ~= -1) then
		AddItem(it,true,unpack(arg))
		print("Replaced Item: " .. it .. "\n")
	end
end

ReplaceItem("weapon_machinegun",
"weapon_machinegun",
IT_WEAPON,
WP_MACHINEGUN,
"icons/iconw_grapple",
"Desert Eagle",
"sound/weapons/deagle/deploy.wav",
18,
"models/weapons2/deagle/deagle.md3")

ReplaceItem("ammo_bullets",
"ammo_bullets",
IT_AMMO,
WP_MACHINEGUN,
"icons/iconw_grapple",
"Bullets",
"sound/weapons/deagle/deploy.wav",
18,
"models/weapons2/deagle/deagle.md3")


if(SERVER) then
	local function wfired(cl,wp,delay,muzzle,angles,weaponent)
		if(wp == WP_RESERVED0) then
			local player = GetAllPlayers()[cl+1]
			local f,r,u = AngleVectors(angles)
			player:SetVelocity(f*-800)
			
			local tr = TraceLine(muzzle,muzzle + f*1000)
			local e = CreateTempEntity(tr.endpos,EV_RAILTRAIL)
			e:SetPos2(muzzle)
		end
		if(wp == WP_MACHINEGUN) then
			G_FireBullet(weaponent,300,30)
			return true
		end
	end
	hook.add("SVFiredWeapon","shared",wfired)
	
	hook.add("PlayerSpawned","shared",function(pl) pl:SetAmmo(WP_MACHINEGUN,18) end)
else
	local function register(wp)
		if(wp == WP_MACHINEGUN) then
		local t =  {}
			t.flashSound0 = LoadSound("sound/weapons/deagle/fire.wav")
			t.flashSound1 = t.flashSound0
			t.flashSound2 = t.flashSound0
			t.flashSound3 = t.flashSound0
			return t
		end
	
		if(wp ~= WP_RESERVED0) then return end
			print("^1Registered: " .. wp .. "\n")
			local t =  {}
			t.flashSound0 = LoadSound("sound/world/jumppad.wav")
		return t
	end
	hook.add("RegisterWeapon","shared",register)
end

local function wfired(cl,wp,delay,angles)
	if(wp == WP_MACHINEGUN) then
		return 320
	end
end
hook.add("FiredWeapon","shared",wfired)

if(RESTARTED) then
	if(SERVER) then
		print("^2SV_RESTARTED\n")
	else
		print("^2CL_RESTARTED\n")
	end
end