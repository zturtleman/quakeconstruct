local META = {}
local ENTS = {}

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

function ExecuteEntity(v)
	ENT = {}
	
	setmetatable(ENT,META)
	META.__index = META
	
	Execute(v[1])
	
	ENT._classname = string.lower(v[2])
	
	ENTS[ENT._classname] = ENT
	table.insert(_CUSTOM,{data=ENT,type="entity"})
end

local function InheritEntities()
	local finished = false
	local nl = true
	local maxiter = 100
	local i = 0
	local lc = 0
	while(nl == true and i < maxiter) do
		nl = false
		for k,v in pairs(ENTS) do
			if(!v.__inherit) then
				local base = v.Base
				local name = v._classname
				--if(base == nil) then base = "panel" end
				if(type(base) == "string" and ENTS[base] and base != name) then
					if(ENTS[base].__inherit == true) then
						ENTS[name] = table.Inherit( ENTS[name], ENTS[base] )
						print("^3Entity Inherited: " .. name .. " -> " .. base .. "\n")
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
	print("Loaded " .. lc .. " entities with " .. i .. " iterations.\n")
end

local list = FindCustomFiles("lua/entities")
for k,v in pairs(list) do
	ExecuteEntity(v)
end
InheritEntities()

local function FindEntity(name)
	return ENTS[string.lower(name)]
end

local function metaCall(tab,func,...)
	if(tab[func] != nil) then
		local b,e = pcall(tab[func],tab,unpack(arg))
		if(!b) then
			print("^1Entity Error[" .. tab._classname .. "]: ^2" .. e .. "\n")
		else
			return true
		end
	end
	return false
end

local function SetCallbacks(ent,tab)
	if(SERVER) then
		ent:SetCallback(ENTITY_CALLBACK_THINK,function(ent) metaCall(tab,"Think") end)
		ent:SetCallback(ENTITY_CALLBACK_DIE,function(ent,a,b,take) metaCall(tab,"Die",a,b,take) end)
		ent:SetCallback(ENTITY_CALLBACK_PAIN,function(ent,a,b,take) metaCall(tab,"Pain",a,b,take) end)
		ent:SetCallback(ENTITY_CALLBACK_TOUCH,function(ent,other,trace) metaCall(tab,"Touch",other,trace) end)
		ent:SetCallback(ENTITY_CALLBACK_USE,function(ent,other) metaCall(tab,"Use",other) end)
		ent:SetCallback(ENTITY_CALLBACK_BLOCKED,function(ent,other) metaCall(tab,"Blocked",other) end)
		ent:SetCallback(ENTITY_CALLBACK_REACHED,function(ent,other) metaCall(tab,"Reached",other) end)
	end
end

local active = {}
local function LinkEntity(ent)
	if(ent == nil) then return end
	local name = ent:Classname()
	local found = FindEntity(name)

	if(found != nil) then
		local cent = {}--table.Copy(found)
		setmetatable(cent,found)
		found.__index = found
		
		local id = ent:EntIndex()
		cent.entity = ent
		cent.Entity = ent --Because I'm like that
		cent.net = CreateEntityNetworkedTable(ent:EntIndex() or -1)
		cent.net:Reset()
		function cent.net:VariableChanged(...)
			--active[id].net = CreateNetworkedTable(ent:EntIndex() or -1)
			metaCall(cent,"VariableChanged",unpack(arg))
		end
		if(SERVER) then metaCall(cent,"Initialized") end
		active[id] = cent
		SetCallbacks(ent,cent)
		
		
		--cent.__index = function(self,str) return active[self.Entity:EntIndex()][str] end
		--cent.__newindex = function(self,str,val) active[self.Entity:EntIndex()][str] = val end
	end
	
	--local str = "Entity Linked: " .. name .. "\n"
	--if(SERVER) then str = "SV: " .. str else str = "CL: " .. str end
	--print(str)
end
hook.add("EntityLinked","checkcustom",LinkEntity)

local function UnlinkEntity(ent)
	local id = ent:EntIndex()
	local cent = active[id]
	if(cent != nil) then
		metaCall(cent,"Removed")
	end
	active[id] = nil
	
	--local str = "Entity Unlinked: " .. ent:Classname() .. "\n"
	--if(SERVER) then str = "SV: " .. str else str = "CL: " .. str end
	--print(str)
end
hook.add("EntityUnlinked","checkcustom",UnlinkEntity)

if(SERVER) then
	local function messagetest(...)
		for k,v in pairs(active) do
			if(v != nil) then
				metaCall(active[k],"MessageReceived",unpack(arg))
			end
		end
	end
	hook.add("MessageReceived","checkcustom",messagetest)
	
	local function ClientReady(...)
		for k,v in pairs(active) do
			if(v != nil) then
				metaCall(active[k],"ClientReady",unpack(arg))
			end
		end
	end
	hook.add("ClientReady","checkcustom",ClientReady)
else
	local function DrawEntity(ent,name)
		local index = ent:EntIndex()
		if(active[index] != nil) then
			metaCall(active[index],"Draw")
		end
	end
	hook.add("DrawCustomEntity","checkcustom",DrawEntity)
	
	local function DrawRT()
		local rtc = 0
		for k,v in pairs(active) do
			if(v != nil) then
				if(metaCall(active[k],"DrawRT")) then
					rtc = rtc + 1
				end
			end
		end
		--print("RTCalls: " .. rtc .. "\n")
	end
	hook.add("DrawRT","checkcustom",DrawRT)
	
	local function UserCommand(...)
		for k,v in pairs(active) do
			if(v != nil) then
				metaCall(active[k],"UserCommand",unpack(arg))
			end
		end
	end
	hook.add("UserCommand","checkcustom",UserCommand)
	
	local function messagetest(...)
		for k,v in pairs(active) do
			if(v != nil) then
				metaCall(active[k],"MessageReceived",unpack(arg))
			end
		end
	end
	hook.add("MessageReceived","checkcustom",messagetest)
	
	local function dlhook(file)
		if(string.find(file,"/lua.entities.") and
		   (string.find(file,"shared.lua") or
		   string.find(file,"cl_init.lua"))) then
			local strt = string.len("lua/downloads/lua.entities.")
			local name = string.sub(file,strt+1,string.len(file))
			local ed = string.find(name,".",0,true)
			
			print(name .. " " .. ed .. "\n")
			if(!ed) then return false end
			name = string.sub(name,0,ed-1)
			print(name .. "\n")
			if(string.len(name) <= 0) then return false end
			
			ENT = {}
			if(ENTS[string.lower(name)] != nil) then
				print("^1" .. string.lower(name) .. " already loaded.\n")
				return true
			end
			
			setmetatable(ENT,META)
			META.__index = META
		
			pcall(include,file)
			
			ENT._classname = string.lower(name)
			
			ENTS[ENT._classname] = ENT
			table.insert(_CUSTOM,{data=ENT,type="entity"})
			print("Downloaded Entity '" .. file .. "'\n")
			InheritEntities()
			
			return true
		end
	end
	hook.add("FileDownloaded","checkcustom",dlhook)
end