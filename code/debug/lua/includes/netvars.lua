_N = {}

local network_meta = {}
setmetatable(_N,network_meta)

local types = {number = 1,string = 1}
local n_msgid = "_netvariable"

if(SERVER) then
	local _previous = {}
	local _protected = {}
	local _ids = {}
	local wait = 0
	local id = 0

	message.Precache(n_msgid)

	local function isFloat(n)
		return (math.floor(n) != n)
	end

	local function sendVariable(var,val,new,pl)
		local msg = Message(n_msgid)
		if(new) then
			message.WriteShort(msg,1)
			message.WriteString(msg,tostring(var))
		else
			message.WriteShort(msg,2)
		end
		
		message.WriteShort(msg,_ids[var] or -1)
		
		if(type(val) == "number") then
			if(isFloat(val)) then
				message.WriteFloat(msg,val)
			else
				if(val < 32767 and val > -32768) then
					message.WriteShort(msg,val)
				else
					message.WriteLong(msg,val)
				end
			end
		elseif(type(val) == "string") then
			message.WriteString(msg,val)
		end
		if(pl == nil) then
			for k,v in pairs(GetAllPlayers()) do
				SendDataMessage(msg,v)
			end
		else
			SendDataMessage(msg,pl)
		end
	end
	
	local function variableChanged(last,var,val)
		if(last != nil) then
			if(last != val) then
				debugprint("Varable Changed: " .. var .. " " .. last .. " -> " .. val .. "\n")
				sendVariable(var,val,false)
			end
		else
			debugprint("New Variable[" .. id .. "]: " .. var .. " = " .. val .. "\n")
			_ids[var] = id
			sendVariable(var,val,true)
			id = id + 1
		end
	end
	
	function network_meta.__index(self,var)
		return _protected[var]
	end
	
	function network_meta.__newindex(self,var,val)
		if(types[type(val)] == 1) then
			if(_previous[var] == nil or type(_previous[var]) == type(val)) then
				variableChanged(_previous[var],var,val)
				_protected[var] = val
				_previous[var] = val
			else
				error("\n    Invalid Data Type[^7" .. var .. "^1]:\n" .. 
					  "       Last data type was ^7\"" .. type(_previous[var]) .. "\"^1\n" ..
					  "       Given data type was ^7\"" .. type(val) .. "\"^1")
			end
		else
			error("Invalid Data Type[^7" .. var .. "^1]!")
		end
	end
	
	local function SendVars(pl)
		debugprint("Sending Vars To " .. pl:GetInfo().name .. "\n")
		for k,v in pairs(_protected) do
			debugprint("Sent: " .. tostring(k) .. "\n")
			sendVariable(k,v,true,pl)
		end	
	end
	
	local function PlayerJoined(pl)
		--if(!pl:IsBot()) then pl:GetTable()._mconnected = true end
		Timer(.05,SendVars,pl) --Wait a sec
	end
	hook.add("ClientReady","netvars",PlayerJoined)
else
	local vars = {}
	local function NetVar(msgid)
		if(msgid == n_msgid) then
			local action = message.ReadShort()
			if(action == 1) then
				debugprint("Got New Variable\n")
				local var = message.ReadString()
				local id = message.ReadShort()
				local value = message.ReadRaw()
				vars[id] = var
				debugprint(var .. "[" .. id .. "]: " .. tostring(value) .. "\n")
				_N[var] = value
			elseif(action == 2) then
				debugprint("Variable Changed\n")
				local id = message.ReadShort()
				local var = tostring(vars[id])
				local value = message.ReadRaw()
				debugprint(var .. "[" .. id .. "]: " .. tostring(value) .. "\n")
				_N[var] = value
			end
		end
	end
	hook.add("HandleMessage","netvars",NetVar)
end