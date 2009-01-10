--includesimple("sctest")

--SendScript("lua/vampiric_cl.lua")
--SendScript("lua/includes/scriptmanager.lua")

require "turrets"
require "explosion"

message.Precache("itempickup")
message.Precache("playerdamage")
message.Precache("playerrespawn")

--downloader.add("lua/cl_lerptest.lua",true)
--downloader.add("lua/tests/cl_small.lua",true)
--downloader.add("lua/tests/cl_small2.lua",true)
--downloader.add("lua/tests/cl_small3.lua",true)
--[[
local function Fuse(v)
	if(v == nil) then return end
	if(v:Classname() != "grenade") then return end
	v:SetNextThink(LevelTime() + 500)
end
hook.add("EntityLinked","super",Fuse)
]]
--downloader.add("lua/sh_notify.lua")
--downloader.add("lua/tests/cl_gibchooser.lua")
--downloader.add("lua/tests/cl_newgibs.lua")
--downloader.add("lua/cl_lerptest.lua")

local function writeVector(msg,v)
	message.WriteFloat(msg,v.x)
	message.WriteFloat(msg,v.y)
	message.WriteFloat(msg,v.z)
end

local function ItemPickup(item, other, trace, itemid)
	if(item and other and itemid) then
		local vec = item:GetPos()
		local vec2 = other:GetVelocity()
		
		local msg = Message()
		message.WriteString(msg,item:Classname())
		writeVector(msg,vec)
		writeVector(msg,vec2)
		message.WriteLong(msg,itemid)
		
		for k,v in pairs(GetEntitiesByClass("player")) do
			SendDataMessage(msg,v,"itempickup")
		end
	end
	--return false
end
hook.add("ItemPickup","init",ItemPickup)

local function PlayerDamaged(self,inflictor,attacker,damage,meansOfDeath,dir,pos)
	for k,v in pairs(GetEntitiesByClass("player")) do
		local msg = Message(v,"playerdamage")
		message.WriteLong(msg,damage)
		message.WriteShort(msg,meansOfDeath)
		message.WriteShort(msg,self:EntIndex())
		message.WriteShort(msg,self:GetHealth())
		message.WriteVector(msg,pos or Vector(0,0,0))
		print("Sent HP: " .. self:GetHealth() .. "\n")
		if(attacker) then
			message.WriteShort(msg,attacker:EntIndex() or -1)
		else
			message.WriteShort(msg,-1)
		end
		SendDataMessage(msg)
	end
end

hook.add("PostPlayerDamaged","init",PlayerDamaged)
hook.remove("PlayerDamaged","init")

local function PlayerSpawned(pl)
	for k,v in pairs(GetEntitiesByClass("player")) do
		local msg = Message(v,"playerrespawn")
		message.WriteShort(msg,pl:EntIndex())
		SendDataMessage(msg)
	end
end
hook.add("PlayerSpawned","init",PlayerSpawned)
--[[
local tests = {}
local ent = CreateEntity("testentity")
local pos = Vector(532,1872,100)
pos = Vector(30,80,100)
ent:SetPos(pos)
--ent:SetTrType(TR_STATIONARY)
table.insert(tests,ent)

local ent2 = CreateEntity("item_quad")
ent2:SetPos(pos + Vector(160,0,150))
ent2:SetTrType(TR_STATIONARY)
ent2:SetWait(1)
ent2:SetSpawnFlags(1)
table.insert(tests,ent2)

for x=0,4 do
	local class = "item_armor_body"
	if(x==0) then
		class = "item_health_mega"
	end
	if(x==1) then
		class = "weapon_railgun"
	end
	if(x==2) then
		class = "weapon_bfg"
	end
	if(x==3) then
		class = "weapon_shotgun"
	end
	local lp = pos + Vector(x*80,0,100)
	local ent = CreateEntity(class)
	ent:SetPos(lp)
	ent:SetTrType(TR_STATIONARY)
	ent:SetWait(1)
	ent:SetSpawnFlags(1)
	table.insert(tests,ent)
end

local function removeTests()
	for k,v in pairs(tests) do
		v:Remove()
	end
end
concommand.Add("RemoveTests",removeTests,true)]]