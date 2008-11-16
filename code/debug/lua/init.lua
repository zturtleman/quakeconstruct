--SendScript("lua/cl_debugbar.lua")
--SendScript("lua/cl_marks.lua")
--includesimple("sctest")

--SendScript("lua/vampiric_cl.lua")
--SendScript("lua/includes/scriptmanager.lua")

require "turrets"

message.Precache("itempickup")
message.Precache("playerdamage")
message.Precache("playerrespawn")

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
		message.WriteLong(msg,self:GetInfo().health)	
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

hook.add("PlayerDamaged","init",PlayerDamaged)

local function PlayerSpawned(pl)
	for k,v in pairs(GetEntitiesByClass("player")) do
		local msg = Message(v,"playerrespawn")
		message.WriteShort(msg,pl:EntIndex())
		SendDataMessage(msg)
	end
end
hook.add("PlayerSpawned","init",PlayerSpawned)