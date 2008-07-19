local print = print
local table = table
local pairs = pairs
local type = type
local pcall = pcall

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
			local b, e = pcall(v,ent,cmd,args)
			if(!b) then
				print("^1CONCOMMAND ERROR: " .. e .. "\n")
			end
		end
		return true
	end
	return false
end

function Add(cmd,func)
	if(type(cmd) == "string" and type(func) == "function") then
		ccmds[cmd] = ccmds[cmd] or {}
		table.insert(ccmds[cmd],func)
	end
end