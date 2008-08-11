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
					print("^1CONCOMMAND ERROR: " .. e .. "\n")
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
		ccmds[cmd] = ccmds[cmd] or {}
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
		print("usage: /load <scriptname> ex: /load knockback\n")
	end
end
Add("load",loadScript,true)

function runlua(ent,cmd,args)
	if(args[1]) then
		runString(args[1])
		print("^5Success\n")
	else
		print("usage: /lua <code> ex: /lua test=1\n")
	end
end
Add("lua",runlua,true)