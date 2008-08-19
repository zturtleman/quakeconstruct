entity_tabs = {}
game_entities = {}

local function addEnt(ent)
	table.insert(game_entities,ent)
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

local function UnlinkEntity(ent)
	if(ent == nil) then return end
	local index = ent:EntIndex()
		if(ent:IsPlayer() == false) then
			if(entity_tabs[index+1] != nil) then
				entity_tabs[index+1] = nil
				removeEnt(ent)
			end
			if(ent:Classname() != nil) then
				debugprint("^2QLUA Entity Unlinked: " .. index .. " | " .. ent:Classname() .. "\n")
			else
				debugprint("^2QLUA Entity Unlinked: " .. index .. "\n")
			end
		else
			if(entity_tabs[index+1] != nil) then
				entity_tabs[index+1].wasUnlinked = true
			end
			if(ent:Classname() != nil) then
				debugprint("Entity Unlinked: " .. index .. " | " .. ent:Classname() .. "\n")
			else
				debugprint("Entity Unlinked: " .. index .. "\n")
			end
		end
end

local function UnlinkPlayer(ent)
	if(ent == nil) then return end
	local index = ent:EntIndex()
		if(ent:IsPlayer() == true) then
			if(entity_tabs[index+1] != nil) then
				entity_tabs[index+1] = nil
				removeEnt(ent)
			end
			if(ent:Classname() != nil) then
				debugprint("^2QLUA Entity Unlinked: " .. index .. " | " .. ent:Classname() .. "\n")
			else
				debugprint("^2QLUA Entity Unlinked: " .. index .. "\n")
			end
		end
end

local function LinkEntity(ent)
	if(ent == nil) then return end
	local index = ent:EntIndex()
		if(entity_tabs[index+1] == nil) then
			entity_tabs[index+1] = {}
			addEnt(ent)
			if(ent:Classname() != nil) then
				debugprint("^2QLUA Entity Linked: " .. index .. " | " .. ent:Classname() .. "\n")
			else
				debugprint("^2QLUA Entity Linked: " .. index .. "\n")
			end
		elseif(entity_tabs[index+1].wasUnlinked) then
			entity_tabs[index+1].wasUnlinked = false
			if(ent:Classname() != nil) then
				debugprint("Entity Linked: " .. index .. " | " .. ent:Classname() .. "\n")
			else
				debugprint("Entity Linked: " .. index .. "\n")
			end
		end
end

function GetEntityTable(ent)
	LinkEntity(ent)
	local index = ent:EntIndex()
	if(index != nil) then
		return entity_tabs[index+1]
	end
end


hook.add("EntityLinked","_LinkToLua",LinkEntity)
hook.add("EntityUnlinked","_UnlinkFromLua",UnlinkEntity)
hook.add("PlayerDisconnected","_UnlinkFromLua",UnlinkPlayer)
hook.add("PlayerJoined","_LinkToLua",LinkEntity)

print("^3Entity code loaded.\n")