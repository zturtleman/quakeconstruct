--[[for k,v in pairs(_G) do
	print(k .. "\n")
end]]

local function includex(s)
	local b,e = pcall(include,"lua/includes/" .. s .. ".lua")
	if(!b) then
		print("^1Failure To Load \"" .. s .. "\":\n" .. e .. "\n")
	else
		print("^2Loaded: " .. s .. "\n")
	end
end

--[[includex("tools")
includex("extensions/init")
includex("vector")
includex("angles")
includex("hooks")
if(CLIENT) then includex("input") end
if(CLIENT) then includex("view") end

_qlimit()
]]
--if(true) then return end

local toadd = {}

concommand = {}
concommand.Add = function(strcmd,func) table.insert(toadd,{strcmd,func}) end

includex("tools")
includex("extensions/init")
includex("base64")
includex("file")
includex("hooks")
includex("entities")
includex("timer")
includex("enum")
includex("vector")
includex("spring")
includex("matrix")
includex("angles")
includex("messages")
includex("netvars")
--includex("scriptmanager")
includex("downloader")
includex("commands")
if(CLIENT) then includex("sound") end
if(CLIENT) then includex("shader") end
if(CLIENT) then includex("sequence") end
if(CLIENT) then includex("animation") end
if(CLIENT) then includex("model") end
if(CLIENT) then includex("sprite") end
if(CLIENT) then includex("poly") end
if(CLIENT) then includex("input") end
if(CLIENT) then includex("view") end
if(CLIENT) then includex("qml") end
includex("packs")
includex("custom")
--require "includes/functiondump"

for k,v in pairs(toadd) do
	concommand.Add(v[1],v[2])
end

ENTITYNUM_NONE = 1023
ENTITYNUM_WORLD	= 1022
ENTITYNUM_MAX_NORMAL = 1022

CONTENTS_SOLID = 1
CONTENTS_LAVA = 8
CONTENTS_SLIME = 16
CONTENTS_WATER = 32
CONTENTS_FOG = 64

if(SERVER) then
	local function message(str,pl)
		if(str == "_clientready") then
			CallHook("ClientReady",pl)
			--Timer(3.8,CallHook,"ClientReady",pl)
			if(pl:IsAdmin()) then
				Timer(2,pl.SendString,pl,"_admin")
			end
		elseif(str == "_demostarted") then
			CallHook("DemoStarted",pl)
		end
	end
	hook.add("MessageReceived","includes",message)
else
	hook.add("InitialSnapshot","includes",function() Timer(.6,SendString,"_clientready") end)
	
	local called = false
	
	local function demo()
		SendString("_demostarted")
	end
	hook.add("DemoStarted","includes",demo)	
	
	local ADMIN = false
	local function message(str,pl)
		if(str == "_admin") then
			print("Admin Verified!\n")
			ADMIN = true
			CallHook("ClientReady")
			CLIENT_READY = true
			called = true
		end
	end
	hook.add("MessageReceived","includes",message)
	
	Timer(10,function() if(!called) then 
		CallHook("ClientReady")
		CLIENT_READY = true
	end end)
	
	function IsAdmin()
		return ADMIN
	end
end