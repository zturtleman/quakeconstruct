--SendScript("lua/cl_debugbar.lua")
--SendScript("lua/cl_marks.lua")
--includesimple("sctest")

--SendScript("lua/vampiric_cl.lua")
--SendScript("lua/includes/scriptmanager.lua")

require "turrets"
require "explosion"

message.Precache("itempickup")
message.Precache("playerdamage")
message.Precache("playerrespawn")

function plspawn(v)
	if(v:GetHealth() > 0 and v:GetTeam() != TEAM_SPECTATOR) then
		v:AddEvent(EV_TAUNT)
		v:SetAnim(TORSO_GESTURE,ANIM_TORSO,2500)
		v:SetAnim(LEGS_JUMP,ANIM_LEGS,0)
		v:SetVelocity(Vector(0,0,350))
	end
end
hook.add("PlayerSpawned","animtest",plspawn)

local function rdeath()
	local a = math.random(1,3)
	print(a .. "\n")
	if(a == 1) then return BOTH_DEATH1 end
	if(a == 2) then return BOTH_DEATH2 end
	if(a == 3) then return BOTH_DEATH3 end
	return BOTH_DEATH1
end

local function Killed(pl)
	--if(pl:IsBot()) then return end
	if(true) then return end
	local team = pl:GetTeam()
	local aim = pl:GetAimAngles()
	pl:GetTable().dpos = pl:GetPos()
	Timer(1,function()
		local pos = pl:GetTable().dpos
		pl:GetTable().spawnlock = true
		pl:SetTeam(TEAM_SPECTATOR)
		pl:GetTable().body = pl:Respawn()
		pl:SetPos(pos)
		pl:SetAimAngles(aim)
		--pl:SetAnim(BOTH_DEATH1,ANIM_LEGS,6000)
		--pl:SetAnim(BOTH_DEATH1,ANIM_TORSO,6000)
	end)
	Timer(4,function()
		local aimx = pl:GetAimAngles()
		local pos = pl:GetPos()
		local body = pl:GetTable().body
		if(body != nil) then
			CreateTempEntity(vAdd(body:GetPos(),Vector(0,0,-5)),EV_PLAYER_TELEPORT_OUT)
			body:Remove()
			--pos = pl:GetTable().body:GetPos()
		end
		if(pl:GetSpectatorType() == SPECTATOR_FOLLOW) then
			pl:SetSpectatorType(SPECTATOR_FREE)
			pos = nil
		end
		pl:GetTable().spawnlock = false
		pl:SetTeam(team)
		pl:Respawn()
		pl:SetAimAngles(aimx)
		if(pos != nil) then
			pl:SetPos(pos + Vector(0,0,25))
		end
		CreateTempEntity(vAdd(pl:GetPos(),Vector(0,0,-5)),EV_PLAYER_TELEPORT_IN)
	end)
end
hook.add("PlayerKilled","teamtest",Killed)

local function deny(pl,team)
	if(team == TEAM_SPECTATOR) then
		return true
	elseif(pl:GetTable().spawnlock) then
		pl:SendMessage("You gotta wait man.",true)
		return false
	end
end
hook.add("PlayerTeamChanged","init",deny)

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
		message.WriteLong(msg,self:GetHealth())	
		if(attacker) then
			message.WriteShort(msg,1)
			message.WriteString(msg,attacker:GetInfo().name or "")
			writeVector(msg,pos or attacker:GetPos())
			message.WriteShort(msg,attacker:EntIndex())
		else
			message.WriteShort(msg,0)
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