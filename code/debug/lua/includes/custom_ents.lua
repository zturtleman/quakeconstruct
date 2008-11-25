local META = {}
local ENTS = {}

function META:Think() end
function META:Initialized() end
function META:Removed() end

if(SERVER) then
	function META:Touch(other,trace) end
	function META:Pain(a,b,take) end
	function META:Die(a,b,take) end
	function META:Use(other) end
	function META:Blocked(other) end
	function META:Reached(other) end
else
	function META:Draw() end
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
		local cent = table.Copy(found)
		local id = ent:EntIndex()
		cent.entity = ent
		cent.Entity = ent --Because I'm like that
		if(SERVER) then cent:Initialized() end
		active[id] = cent
		SetCallbacks(ent,cent)
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
		cent:Removed()
	end
	active[id] = nil
	
	--local str = "Entity Unlinked: " .. ent:Classname() .. "\n"
	--if(SERVER) then str = "SV: " .. str else str = "CL: " .. str end
	--print(str)
end
hook.add("EntityUnlinked","checkcustom",UnlinkEntity)

if(SERVER) then

else
	local function DrawEntity(ent,name)
		local index = ent:EntIndex()
		if(active[index] != nil) then
			active[index]:Draw()
		end
	end
	hook.add("DrawCustomEntity","checkcustom",DrawEntity)
end