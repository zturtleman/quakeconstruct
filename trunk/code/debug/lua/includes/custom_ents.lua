local META = {}
local ENTS = {}

function META:Think() end
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
end

function ExecuteEntity(v)
	ENT = {}
	
	setmetatable(ENT,META)
	META.__index = META
	
	Execute(v[1])
	
	ENT._classname = string.lower(v[2])
	
	ENTS[ENT._classname] = ENT
	table.insert(_CUSTOM,{data=ENT,type="entity"})
end

local list = FindCustomFiles("lua/entities")
for k,v in pairs(list) do
	ExecuteEntity(v)
end

local function FindEntity(name)
	return ENTS[string.lower(name)]
end

local function SetCallbacks(ent,tab)
	if(SERVER) then
		ent:SetCallback(ENTITY_CALLBACK_THINK,function(ent) tab:Think() end)
		ent:SetCallback(ENTITY_CALLBACK_DIE,function(ent,a,b,take) tab:Die(a,b,take) end)
		ent:SetCallback(ENTITY_CALLBACK_PAIN,function(ent,a,b,take) tab:Pain(a,b,take) end)
		ent:SetCallback(ENTITY_CALLBACK_TOUCH,function(ent,other,trace) tab:Touch(other,trace) end)
		ent:SetCallback(ENTITY_CALLBACK_USE,function(ent,other) tab:Use(other) end)
		ent:SetCallback(ENTITY_CALLBACK_BLOCKED,function(ent,other) tab:Blocked(other) end)
		ent:SetCallback(ENTITY_CALLBACK_REACHED,function(ent,other) tab:Reached(other) end)
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
			pcall(cent.VariableChanged,cent,unpack(arg))
		end
		if(SERVER) then cent:Initialized() end
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
		if(cent.Removed) then
			cent:Removed()
		end
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
				pcall(active[k].MessageReceived,active[k],unpack(arg))
			end
		end
	end
	hook.add("MessageReceived","checkcustom",messagetest)
	
	local function ClientReady(...)
		for k,v in pairs(active) do
			if(v != nil) then
				pcall(active[k].ClientReady,active[k],unpack(arg))
			end
		end
	end
	hook.add("ClientReady","checkcustom",ClientReady)
else
	local function DrawEntity(ent,name)
		local index = ent:EntIndex()
		if(active[index] != nil) then
			pcall(active[index].Draw,active[index])
		end
	end
	hook.add("DrawCustomEntity","checkcustom",DrawEntity)
	
	local function UserCommand(...)
		for k,v in pairs(active) do
			if(v != nil) then
				pcall(active[k].UserCommand,active[k],unpack(arg))
			end
		end
	end
	hook.add("UserCommand","checkcustom",UserCommand)
	
	local function messagetest(...)
		for k,v in pairs(active) do
			if(v != nil) then
				pcall(active[k].MessageReceived,active[k],unpack(arg))
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
			
			setmetatable(ENT,META)
			META.__index = META
		
			pcall(include,file)
			
			ENT._classname = string.lower(name)
			
			ENTS[ENT._classname] = ENT
			table.insert(_CUSTOM,{data=ENT,type="entity"})
			print("Downloaded Entity '" .. file .. "'\n")	
			
			return true
		end
	end
	hook.add("FileDownloaded","checkcustom",dlhook)
end