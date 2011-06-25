--[[for k,v in pairs(_G) do
	print(k .. "\n")
end]]

local function includex(s)
	local ext = "lua"
	local path = "lua/includes"
	if(COMPILED) then
		ext = "luc"
		path = "lua/includes/compiled"
	end
	local b,e = pcall(include,path .. "/" .. s .. "." .. ext)
	if(!b) then
		print("^1Failure To Load \"" .. s .. "\":\n" .. e .. "\n")
	else
		if(COMPILED) then
			--print("^2Loaded[compiled]: " .. s .. "\n")
		else
			--print("^2Loaded: " .. s .. "\n")
		end
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

includex("linkedlist")
includex("tools")
includex("extensions/init")
includex("base64")
includex("file")
includex("hooks")
includex("treeparser")
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
includex("downloader2")
includex("commands")
if(CLIENT) then includex("sound") end
if(CLIENT) then includex("shader") end
if(CLIENT) then includex("sequence") end
if(CLIENT) then includex("animation") end
if(CLIENT) then includex("model") end
if(CLIENT) then includex("sprite") end
if(CLIENT) then includex("poly") end
if(CLIENT) then includex("fonts") end
if(CLIENT) then includex("view") end
if(CLIENT) then includex("qml") end
if(CLIENT) then includex("particletools") end
includex("input")
includex("packs")
includex("custom")
includex("persistance")
--require "includes/functiondump"

for k,v in pairs(toadd) do
	concommand.Add(v[1],v[2])
end

ENTITYNUM_NONE = 1023
ENTITYNUM_WORLD	= 1022
ENTITYNUM_MAX_NORMAL = 1022

if(SERVER) then
	local readies = {}
	local function message(str,pl)
		if(str == "_clientready") then
			if not (readies[pl:EntIndex()]) then
				CallHook("ClientReady",pl)
				--Timer(3.8,CallHook,"ClientReady",pl)
				if(pl:IsAdmin()) then
					Timer(1,pl.SendString,pl,"_admin")
				else
					Timer(1,pl.SendString,pl,"_verify")
				end
				readies[pl:EntIndex()] = true
			end
		elseif(str == "_demostarted") then
			CallHook("DemoStarted",pl)
		elseif(str == "_clientfinished") then
			CallHook("ClientShutdownLua",pl)
		end
	end
	hook.add("MessageReceived","includes",message)
else
	local timers = {}
	hook.add("InitialSnapshot","includes",function() 
		--Keep trying to tell the server that we're ready
		for i=1, 20 do
			local t = Timer(i/2,SendString,"_clientready") 
			table.insert(timers,t)
		end
	end)
	
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
			for k,v in pairs(timers) do StopTimer(v) end
		elseif(str == "_verify") then
			for k,v in pairs(timers) do StopTimer(v) end
		end
	end
	hook.add("MessageReceived","includes",message)
	
	local function finish()
		SendString("_clientfinished")
	end
	hook.add("Shutdown","includes",finish)
	
	
	Timer(10,function() if(!called) then 
		CallHook("ClientReady")
		CLIENT_READY = true
	end end)
	
	function IsAdmin()
		return ADMIN
	end
end

hook.reserve("includes")

_GBASELINE = table.Copy(_G)