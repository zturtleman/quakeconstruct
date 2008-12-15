if(!hook) then
	hook = {}
	hook.events = {}
	hook.debugflags = {}
	hook.locked = {}
end

function hook.sort(event)
	table.sort(hook.events[event],function(a,b) return a.priority > b.priority end)
end

function hook.replacehook(tab,event)
	if(hook.events[event] == nil) then return end
	for k,v in pairs(hook.events[event]) do
		if(v.name == tab.name) then 
			hook.events[event][k] = tab
			hook.sort(event)
			return true
		end
	end
	hook.sort(event)
	return false
end

function hook.remove(event,name)
	if(hook.events[event] == nil) then return end
	for k,v in pairs(hook.events[event]) do
		if(v.name == name) then 
			table.remove(hook.events[event],k)
		end
	end
	hook.sort(event)
end

function hook.add(event,name,func,priority)
	if(hook.locked[event]) then return end
	priority = priority or 0
	if(event != nil and name != nil and func != nil) then
		local tab = {func=func,name=name,priority=priority}
		hook.events[event] = hook.events[event] or {}
		if not (hook.replacehook(tab,event)) then
			table.insert(hook.events[event],tab)
		end
	else
		event = tostring(event) or "Unknown Event"
		error("Unable to add hook: " .. event .. ".\n")
	end
	hook.sort(event)
end
hook.Add = hook.add

function hook.lock(event)
	hook.locked[event] = true
end

function hook.debug(event,b)
	print("Debug Set: " .. event .. " | " .. tostring(b) .. "\n")
	hook.debugflags[event] = b
end

local function funcname(func)
	for k,v in pairs(_G) do
		if(v == func) then return k end
	end
	return ""
end

local ispost = false

local function printhooks()
	for k,_ in pairs(hook.events) do
		print(k .. "\n")
		if(type(hook.events[k]) == "table") then
			for _,v in pairs(hook.events[k]) do 
				print("  -" .. v.name .. "\n")
			end
		end
	end
end
if(SERVER) then concommand.Add("PrintHooks_SV",printhooks) end
if(CLIENT) then concommand.Add("PrintHooks_CL",printhooks) end

function CallHook(event,...)
	if(hook.events[event] == nil) then return end
	local retVal = nil
	for k,v in pairs(hook.events[event]) do
		local fname = v.name
		if (hook.debugflags[event] == true) then debugprint("Calling Function: " .. fname .. "\n") end
		
		local b,e = pcall(v.func,unpack(arg))
		if not b then
			print("^1HOOK ERROR[" .. event .. "]: " .. e .. "\n")
		else
			if not (e == nil) then
				if (hook.debugflags[event] == true) then 
					debugprint("Returned Value ")
					if(e == false) then
						debugprint("False.\n")
					elseif(e == true) then
						debugprint("True.\n")
					else
						debugprint(tostring(e) .. ".\n")
					end
				end
				retVal = e
			end
		end
	end
	if(retVal != nil) then return retVal end
end

debugprint("^3Hook code loaded.\n")