local print = print
local table = table
local pairs = pairs
local type = type
local pcall = pcall
local require = require
local tostring = tostring
local GetAllEntities = GetAllEntities
local runString = runString
local include = include
local SERVER = SERVER
local CH_TAB = "    "

function __concommand(ent,cmd)
	local args = {}
	
	local i = 0
	local arg = grabarg()
	while(arg != "") do
		table.insert(args,arg)
		arg = grabarg()
		i = i + 1
		if(i > 32) then break end --failsafe
	end
	local exist = concommand.Call(ent,cmd,args)
	return exist
end

module("concommand")

local ccmds = {}

function Call(ent,cmd,args)
	if(ccmds[cmd]) then
		for k,v in pairs(ccmds[cmd]) do
			if(ent:EntIndex() == 0 or adminonly != true) then
				local b, e = pcall(v.func,ent,cmd,args)
				if(!b) then
					if(SERVER) then
						print("^1CONCOMMAND ERROR: " .. e .. "\n")
					else
						print("^1CL_CONCOMMAND ERROR: " .. e .. "\n")
					end
				end
			else
				ent:SendMessage("Silly Goose, you aren't the owner of this server.\n")
			end
		end
		return true
	end
	return false
end

function Add(cmd,func,adminonly)
	if(type(cmd) == "string" and type(func) == "function") then
		--if(ccmds[cmd] == nil) then
		ccmds[cmd] = {}
		--end
		table.insert(ccmds[cmd],{func=func,adminonly=adminonly})
	end
end

function woo(ent,cmd,args)
	for k,v in pairs(GetAllEntities()) do
		if(v:IsPlayer()) then
			v:Damage(10000)
		end
	end
end
--Add("killall",woo)

function loadScript(ent,cmd,args)
	if(args[1]) then
		args[1] = "lua/" .. args[1] .. ".lua"
		include(args[1])
		print("^5Loaded Script: " .. args[1] .. "\n")
	else
		local ex = "cl_marks"
		if(SERVER) then ex = "knockback" end
		print(CH_TAB.."effect: Opens an lua script.\n")
		print(CH_TAB.."usage: /" .. cmd .. " <scriptname> ex: /" .. cmd .. " " .. ex .. "\n")
	end
end
if(SERVER) then
	Add("load",loadScript,true)
else
	Add("load_cl",loadScript,true)
end

function runlua(ent,cmd,args)
	if(args[1]) then
		runString(args[1])
		print("^5Success\n")
	else
		print(CH_TAB.."effect: Executes lua code.\n")
		print(CH_TAB.."usage: /" .. cmd .. " <code> ex: /" .. cmd .. " test=1\n")
	end
end
if(SERVER) then
	Add("lua",runlua,true)
else
	Add("lua_cl",runlua,true)
end