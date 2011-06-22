local META = {}
local WEAPONS = {}
local active = {}
local FCF = FindCustomFiles
local WEAPON_CLASSES = {}

--[[function META:Think() end
function META:Initialized() end
function META:Removed() end
function META:MessageReceived() end
function META:VariableChanged() end

if(SERVER) then
	function META:Touch(other,trace) end
	function META:Pain(a,b,take) end
	function META:Die(a,b,take) end
	function META:Use(other) end
	function META:Blocked(other) end
	function META:Reached(other) end
	function META:ClientReady(ent) end
else
	function META:Draw() end
	function META:UserCommand() end
end]]

local function WriteWeaponFunctions(WEAPON)

end

local function metaCall(tab,func,...)
	if(tab[func] != nil) then
		local b,e = pcall(tab[func],tab,unpack(arg))
		if(!b) then
			print("^1Weapon Error[" .. tab._classname .. "]: ^2" .. e .. "\n")
		else
			return true,e
		end
	end
	return false
end

function ExecuteWeapon(v)
	WEAPON = {}
	
	setmetatable(WEAPON,META)
	META.__index = META
	
	Execute(v[1])
	
	WEAPON._classname = string.lower(v[2])
	if(!WEAPON.Base) then
		WriteWeaponFunctions(WEAPON)
	end
	
	WEAPONS[WEAPON._classname] = WEAPON
	table.insert(_CUSTOM,{data=WEAPON,type="weapon"})
	table.insert(WEAPON_CLASSES,WEAPON._classname)
	metaCall(WEAPON,"Init")
end

function ExecuteWeaponSub(v)
	print("^1EXECUTE WEAPON SUB! [" .. v[2] .. "]\n")
	local class = string.lower(v[2])
	local current = WEAPONS[class]
	if(current != nil) then
		WEAPON = {}
		Execute(v[1])
		
		--ENTS[class] = table.Inherit( ENT, ENTS[class] )
		table.Update(WEAPONS[class],WEAPON)
		metaCall(WEAPON,"Init")
		
		--[[for k,v in pairs(active) do
			if(active[k]._classname == class) then
				table.Update(active[k],ENT)
				metaCall(active[k],"ReInitialize")
			end
		end]]
	else
		ExecuteWeapon(v)
	end
end

local function InheritWeapons()
	local finished = false
	local nl = true
	local maxiter = 100
	local i = 0
	local lc = 0
	while(nl == true and i < maxiter) do
		nl = false
		for k,v in pairs(WEAPONS) do
			if(!v.__inherit) then
				local base = v.Base
				local name = v._classname
				--if(base == nil) then base = "panel" end
				if(type(base) == "string" and WEAPONS[base] and base != name) then
					if(WEAPONS[base].__inherit == true) then
						WEAPONS[name] = table.Inherit( WEAPONS[name], WEAPONS[base] )
						--print("^3Entity Inherited: " .. name .. " -> " .. base .. "\n")
						lc = lc + 1
						v.__inherit = true
					else
						nl = true
					end
				else
					lc = lc + 1
					v.__inherit = true
				end
			end
		end
		i = i + 1
	end
	print("Loaded " .. lc .. " weapons with " .. i .. " iterations.\n")
end

local list = FindCustomFiles("lua/weapons")
for k,v in pairs(list) do
	ExecuteWeapon(v)
end
InheritWeapons()
print("Loading custom weapons\n")

local function FindWeapon(name)
	return WEAPONS[string.lower(name)]
end

local function reloadWeapons()
	--ENTS
	local list = FCF("lua/weapons")
	for k,v in pairs(list) do
		ExecuteWeaponSub(v)
	end
	InheritWeapons()
end
if(SERVER) then
	concommand.add("reloadWeapons",reloadWeapons)
else
	concommand.add("reloadWeapons_cl",reloadWeapons)
end

if(CLIENT) then
	local function dlhook(file)
		if(string.find(file,"/lua.weapons.") and
		   (string.find(file,"shared.lua") or
		   string.find(file,"cl_init.lua"))) then
			local strt = string.len("lua/downloads/lua.weapons.")
			local name = string.sub(file,strt+1,string.len(file))
			local ed = string.find(name,".",0,true)
			
			--print(name .. " " .. ed .. "\n")
			if(!ed) then return false end
			name = string.sub(name,0,ed-1)
			--print(name .. "\n")
			if(string.len(name) <= 0) then return false end
			
			local class = string.lower(name)
			local current = WEAPONS[class]
			if(current != nil) then
				WEAPON = {}
				local b,e = pcall(include,file)
				if not (b) then
					print("^1Error loading entity file: " .. e .. "\n")
				end
				
				--ENT
				
				table.Update(WEAPONS[class], WEAPON)
			else
				WEAPON = {}
				
				setmetatable(WEAPON,META)
				META.__index = META
			
				pcall(include,file)
				
				WEAPON._classname = string.lower(name)
				if(!WEAPON.Base) then
					WriteWeaponFunctions(WEAPON)
				end
				
				WEAPONS[WEAPON._classname] = WEAPON
				table.insert(_CUSTOM,{data=WEAPON,type="weapon"})
				table.insert(WEAPON_CLASSES,WEAPON._classname)
				metaCall(WEAPON,"Init")
				InheritWeapons()
			end
			--print("Downloaded Entity '" .. file .. "'\n")
			
			return true
		end
	end
	hook.add("FileDownloaded","checkweapons",dlhook)
end




local PLAYER_INVENTORY = {}

local GetPredictedClient
local GetClient
local UpdatePlayerInventory

if(SERVER) then
	message.Precache("_winv")

	GetPredictedClient = function(pl)
		return GetPlayerByIndex(pl:GetPredicted())
	end

	GetClient = function(n)
		return GetPlayerByIndex(n)
	end

	UpdatePlayerInventory = function(pl,w,n)
		pl = GetPredictedClient(GetClient(pl))
		if(pl == nil) then print("^1No Predicted Client") return end
		
		local msg = Message(pl,"_winv")
		message.WriteByte(msg,w)
		message.WriteShort(msg,n)
		SendDataMessage(msg)
	end
end

function CheckPlayer(i)
	PLAYER_INVENTORY[i] = PLAYER_INVENTORY[i] or {}
	PLAYER_INVENTORY[i].ammo = PLAYER_INVENTORY[i].ammo or {}
	PLAYER_INVENTORY[i].weapons = PLAYER_INVENTORY[i].weapons or {}
	PLAYER_INVENTORY[i].index = i
	if(SERVER) then
		--PLAYER_INVENTORY[i].ammo[3] = PLAYER_INVENTORY[i].ammo[3] or 15
	end
	return PLAYER_INVENTORY[i]
end

function GetWeaponClass(weapon)
	local class = WEAPON_CLASSES[weapon]
	if(class ~= nil) then
		return FindWeapon(class)
	end
end

function WeaponMeta(weapon,func,...)
	local class = GetWeaponClass(weapon)
	if(class == nil) then return end
	return metaCall(class,func,unpack(arg))
end

function __GetAmmo(client,weapon)
	local inv = CheckPlayer(client)
	return inv.ammo[weapon] or 0
end

function __SetAmmo(client,weapon,ammo)
	if(SERVER) then
		UpdatePlayerInventory(client,weapon,ammo)
	end
	local inv = CheckPlayer(client)
	inv.ammo[weapon] = ammo
end

function __ConsumeAmmo(client,weapon,n)
	if(SERVER) then
		local ammo = __GetAmmo(client,weapon)
		__SetAmmo(client,weapon,ammo-n)
	end
end

function __FindBestWeapon(client)
	for i=1, 255 do
		local ammo = __GetAmmo(client,256-i)
		if(ammo > 0) then return 256-i end
	end
	return 0
end

function __WeaponEmpty(client,weapon)
	GetClient(client):SetWeapon(__FindBestWeapon(client))
end

function __CanFire(client,weapon,weapontime,addtime,angles,ws)
	--ws = WEAPON_FIRING
	local class = GetWeaponClass(weapon)
	if(class ~= nil) then
		addtime = class.Firerate
	end
	
	local n = weapontime + addtime
	if(SERVER) then print("AMMO: " .. weapon .. " | " .. __GetAmmo(client,weapon) .. "\n") end
	if(__GetAmmo(client,weapon) == 0) then __WeaponEmpty(client,weapon) return true,WEAPON_READY,n end
	if(__GetAmmo(client,weapon) ~= -1) then __ConsumeAmmo(client,weapon,1) end
	
	return false,ws,n
end

function __HasWeapon(client,weapon)
	local a = __GetAmmo(client,weapon)
	return a > 0 or a == -1
end

if(SERVER) then

	function __WeaponFired(player,iweapon,muzzle,angles) 
		print("FIRE: " .. iweapon .. "\n")
		if not (WeaponMeta(iweapon,"Fire",player,muzzle,angles)) then
			__FireDefault(player,iweapon)
		end
	end

	function __DropWeapon(player,iweapon) print("Player Drop Weapon\n") 
		WeaponMeta(iweapon,"Drop",player)
	end

	hook.add("SVFiredWeapon","weapons",function(a,iweapon,b,muzzle,angles,player)
		__WeaponFired(player,iweapon,muzzle,angles)
	end)

	function PlayerSpawned(pl)
		__SetAmmo(pl:EntIndex(),1,-1)
		pl:SetWeapon(1)
	end
	hook.add("ClientReady","weapons",PlayerSpawned)
	hook.add("PlayerSpawned","weapons",PlayerSpawned)
	
else
	
	function client()
		return LocalPlayer():EntIndex()
	end

	function LocalInventory()
		return CheckPlayer(client())
	end
	
	function __SetSelection(i) 
		WeaponMeta(i,"Deploy")
		util.SetWeaponSelect(i)
	end
	
	function __SelectWeapon(i) __SetSelection(i) end
	function __PrevWeapon(i) print("Prev Weapon: " .. i .. "\n") end
	function __NextWeapon(i) print("Next Weapon: " .. i .. "\n") end
	function __DrawWeaponSelector(t) end
	function __OutOfAmmo() end
	
	function __AddPlayerWeapon(parent,entity,team,iweapon,renderfx)
		WeaponMeta(iweapon,"Draw",parent,entity,team,renderfx)
	end
	
	function __WeaponFired(player,iweapon,angles)
		local muzzle = player:GetPos()
		WeaponMeta(iweapon,"Fire",player,muzzle,angles)
	end
	
	local defaultHand = LoadModel("models/weapons2/shotgun/shotgun_hand.md3")	
	function __GetHandModel(iweapon)
		if not (WeaponMeta(iweapon,"GetHandModel")) then
			return defaultHand
		end
	end
	
	local defaultAmmo = LoadModel("models/weapons2/grapple/grapple.md3")
	function __GetAmmoModel(iweapon)
		if not (WeaponMeta(iweapon,"GetAmmoModel")) then
			return defaultAmmo
		end	
	end
	
	local defaultAmmoIcon = LoadShader("icons/iconw_grapple")
	function __GetAmmoIcon(iweapon)
		if not (WeaponMeta(iweapon,"GetAmmoIcon")) then
			return defaultAmmoIcon
		end	
	end
	
	function __AmmoWarning(prev) 
		return 2
	end
	
	function __RegisterWeapon(i)
		WeaponMeta(i,"Register")
	end
	
	local function HandleMessage(msgid)
		if(msgid == "_winv") then
			local index = message.ReadByte()
			local value = message.ReadShort()
			
			local inv = LocalInventory()
			__SetAmmo(inv.index,index,value)
		end
	end
	hook.add("HandleMessage","weapons",HandleMessage)

	__RegisterWeapon(1)
end