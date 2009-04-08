game_entities = {}

local function addEnt(ent)
	for k,v in pairs(game_entities) do
		if(v:EntIndex() == ent:EntIndex()) then
			return false
		end
	end
	table.insert(game_entities,ent)
	return true
	--table.sort(game_entities,function(a,b) return a:Classname() < b:Classname() end)
end

local function removeEnt(ent)
	for k,v in pairs(game_entities) do
		if(v:EntIndex() == ent:EntIndex()) then
			table.remove(game_entities,k)
		end
	end
end
	
function GetAllEntities()
	return game_entities
end

function GetEntitiesByClass(class)
	local out = {}
	for k,v in pairs(GetAllEntities()) do
		if(type(v) == "userdata") then
			if(type(class) == "string") then
				if(v:Classname() == class) then
					table.insert(out,v)
				end
			elseif(type(class) == "table") then
				for _,cname in pairs(class) do
					if(v:Classname() == cname) then
						table.insert(out,v)
					end
				end
			end
		end
	end
	return out
end

function GetAllPlayers()
	return GetEntitiesByClass("player")
end

function GetOwner()
	for k,v in pairs(GetEntitiesByClass("player")) do
		if(v:IsAdmin()) then return v end
	end
	return nil
end

local function UnlinkEntity(ent)
	if(ent == nil) then return end
	if(string.find(ent:Classname(),"func_")) then return end
	if(string.find(ent:Classname(),"mover")) then return end
	local index = ent:EntIndex()
	if(ent:IsPlayer() == false) then
		removeEnt(ent)
		if(ent:Classname() != nil) then
			debugprint("^2QLUA Entity Unlinked: " .. index .. " | " .. ent:Classname() .. "\n")
		else
			debugprint("^2QLUA Entity Unlinked: " .. index .. "\n")
		end
	else
		if(ent:Classname() != nil) then
			debugprint("Entity Unlinked: " .. index .. " | " .. ent:Classname() .. "\n")
		else
			debugprint("Entity Unlinked: " .. index .. "\n")
		end
	end
	if(CLIENT) then
		removeEnt(ent)
	end
	debugprint("NumLinks: " .. #game_entities .. "\n")
end

local function UnlinkPlayer(ent)
	if(ent == nil) then return end
	local index = ent:EntIndex()
	if(ent:IsPlayer() == true) then
		removeEnt(ent)
		if(ent:Classname() != nil) then
			debugprint("^2QLUA Entity Unlinked: " .. index .. " | " .. ent:Classname() .. "\n")
		else
			debugprint("^2QLUA Entity Unlinked: " .. index .. "\n")
		end
	end
end

local function LinkEntity(ent)
	if(ent == nil) then return end
	if(string.find(ent:Classname(),"target_")) then return end
	if(string.find(ent:Classname(),"func_")) then return end
	if(string.find(ent:Classname(),"mover")) then return end
	local index = ent:EntIndex()
	if(!addEnt(ent)) then return end
	if(ent:Classname() != nil) then
		debugprint("^2QLUA Entity Linked: " .. index .. " | " .. ent:Classname() .. "\n")
	else
		debugprint("^2QLUA Entity Linked: " .. index .. "\n")
	end
	debugprint("NumLinks: " .. #game_entities .. "\n")
end

function GetEntityTable(ent)
	if(ent != nil) then
		--print("^3'GetEntityTable' is depricated. Use Entity:GetTable() instead.\n")
		return ent:GetTable()
	end
end


hook.add("EntityLinked","_LinkToLua",LinkEntity,999)
hook.add("EntityUnlinked","_UnlinkFromLua",UnlinkEntity,999)
hook.add("PlayerDisconnected","_UnlinkFromLua",UnlinkPlayer,999)
hook.add("PlayerJoined","_LinkToLua",function(ent) Timer(.2,LinkEntity,ent) end,999)
hook.add("PlayerSpawned","_LinkToLua",function(ent) Timer(.2,LinkEntity,ent) end,999)
--Delay player linking so that other entities can link up first

debugprint("^3Entity code loaded.\n")