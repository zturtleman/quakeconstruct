local timers = {}

local function getTimerId()
	local id = 0
	for k,v in pairs(timers) do
		if(v.id == id) then
			id = id + 1
		end
	end
	return id
end

function Timer(delay,func,...)
	local t = {}
	t.time = CurTime() + delay
	t.func = func
	t.args = arg
	t.id = getTimerId()
	t.istimer = true
	table.insert(timers,t)
	return t
end

function StopTimer(t)
	if(type(t) == "table" && t.istimer) then
		for k,v in pairs(timers) do
			if(v.id == t.id) then
				table.remove(timers,k)
			end
		end
	end
end

function CheckTimers()
	for k,v in pairs(timers) do
		if(v.time < CurTime()) then
			local b, e = pcall(v.func,unpack(v.args))
			if(!b) then
				print("^1TIMER ERROR: " .. e .. "\n")
			end
			table.remove(timers,k)
		end
	end
end
hook.add("Think","Timers",CheckTimers)

debugprint("^3Timer code loaded.\n")