hook = {}
hook.events = {}

function hook.hashook(func,event)
	for k,v in pairs(hook.events[event]) do
		if(v == func) then return true end
	end
	return false
end

function hook.add(event,func)
	hook.events[event] = hook.events[event] or {}
	if not (hook.hashook(func,event)) then
		table.insert(hook.events[event],func)
	end
end

function CallHook(event,...)
	if(hook.events[event] == nil) then return end
	if(QLUA_DEBUG) then
		if not (event == "Think") then print("Hook Called: " .. event .. "\n") end
	end
	for k,v in pairs(hook.events[event]) do
		local b,e = pcall(v,unpack(arg))
		if not b then
			print("^1HOOK ERROR[" .. event .. "]: " .. e .. "\n")
		else
			if not (e == nil) then
				if(QLUA_DEBUG) then
					print("Returned Value ")
					if(e == false) then
						print("False.\n")
					elseif(e == true) then
						print("True.\n")
					else
						print(tostring(e) .. ".\n")
					end
				end
				return e
			end
		end
	end
end

print("^3Hook code loaded.\n")