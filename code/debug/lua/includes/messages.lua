D_SHORT = 1 --At first this was 0 but now I realize that 'tostring' truncates 0's
D_LONG = 2
D_STRING = 3
D_FLOAT = 4

local msgIDs = {}
local strings = {}
strings[D_SHORT] = "Short"
strings[D_LONG] = "Long"
strings[D_STRING] = "String"
strings[D_FLOAT] = "Float"

local types = {}
types[D_SHORT] = "number"
types[D_LONG] = "number"
types[D_STRING] = "string"
types[D_FLOAT] = "number"

local defaults = {}
defaults[D_SHORT] = 0
defaults[D_LONG] = 0
defaults[D_STRING] = ""
defaults[D_FLOAT] = 0

message = {}

if(SERVER) then
	local nextid = 1
	local funcs = {}
	funcs[D_SHORT] = _message.WriteShort
	funcs[D_LONG] = _message.WriteLong
	funcs[D_STRING] = _message.WriteString
	funcs[D_FLOAT] = _message.WriteFloat

	local function check(m)
		if(m != nil and m.ismessage) then
			return true
		end
		return false
	end
	
	local function reportDataType(v,t,m)
		local cnt = -1
		local vtype = type(v)
		if(vtype == nil) then vtype = "" end
		if(m != nil) then cnt = m.argcount or -1 end
		print("^3Message Warning[A](arg " .. cnt .. "): Expected " .. types[t] ..
		" got " .. vtype .. ".\nUsing Default: " .. defaults[t] .. "\n")
	end
	
	local function checkData(v,t,m)
		if(t == nil) then
			error("^5MESSAGE ERROR[B]: Data type was nil (this error should never happen!)\n")
			return false
		end
		if(t < D_SHORT or t > D_FLOAT) then return false end
		if(type(v) != types[t]) then reportDataType(v,t,m) return false end
		return true
	end
	
	local function addData(m,v,t)
		m.argcount = m.argcount + 1
		if(!checkData(v,t,m)) then 
			v = defaults[t]
		end
		if(check(m)) then table.insert(m,{v,t})end
	end

	function Message(pl,msgid)
		local tab = {}
		if(type(pl) == "string") then 
			msgid = pl 
			pl = nil
		end
		tab.ismessage = true
		tab.pl = pl
		tab.msgid = msgid
		tab.argcount = 0
		return tab
	end
	
	function message.WriteShort(m,s)
		addData(m,s,D_SHORT)
	end
	
	function message.WriteLong(m,s)
		addData(m,s,D_LONG)
	end
	
	function message.WriteString(m,s)
		addData(m,s,D_STRING)
	end
	
	function message.WriteFloat(m,s)
		addData(m,s,D_FLOAT)
	end
	
	function message.WriteVector(m,v)
		message.WriteFloat(m,v.x)
		message.WriteFloat(m,v.y)
		message.WriteFloat(m,v.z)
	end
	
	local d_Message = _Message
	local d_Send = _SendDataMessage
	
	local function MessageID(pl,id)
		if(msgIDs[id] == nil) then
			msgIDs[id] = nextid
			nextid = nextid + 1
		end
		if(pl != nil and pl:GetTable()._mconnected) then
			local tab = pl:GetTable()
			tab.msglist = tab.msglist or {}
			if(tab.msglist[id] != true) then
				local msg = d_Message(pl,2)
				_message.WriteShort(msg,msgIDs[id])
				_message.WriteString(msg,id)
				d_Send(msg)
				tab.msglist[id] = true
				return nil
			end
		else
			error("^5MESSAGE ERROR[C]: Unable to send message ID to player (player was not connected)\n")
			return nil
		end
		return msgIDs[id]
	end
	
	local function SendCache(pl,force)
		if(pl == nil) then error("^5MESSAGE ERROR[D]: Unable to send cache to player (player was nil)\n") return end
		if(pl:IsBot()) then return end
		local tab = pl:GetTable()
		tab.msglist = tab.msglist or {}
		
		local send = {}
		for k,v in pairs(msgIDs) do
			if(tab.msglist[k] != true or force) then
				debugprint(k .. " - " .. v .. "\n")
				if(k != nil and v != nil) then
					table.insert(send, {v,k})
				end
				tab.msglist[k] = true
			end
		end
		local ts = #send
		local msg = d_Message(pl,3)
		_message.WriteLong(msg,ts)
		for i=1, ts do
			local v = send[i]
			debugprint("Send: " .. v[1] .. "->" .. v[2] .. "\n")
			_message.WriteShort(msg,v[1])
			_message.WriteString(msg,v[2])
		end
		d_Send(msg)
	end
	
	function message.Precache(str)
		if(str != nil and type(str) == "string") then
			str = string.lower(str)
			if(msgIDs[str] == nil) then
				msgIDs[str] = nextid
				nextid = nextid + 1
				
				debugprint("Message Precache[" .. str .. "]:\n")
				for k,v in pairs(GetAllPlayers()) do
					if(v:GetTable()._mconnected) then
						SendCache(v)
					end
				end
			end
		else
			error("^5MESSAGE ERROR[E]: Failure to precache message (Use String)\n")
		end
	end
	
	function SendDataMessage(m,pl,msgid)
		--print("Sending Data Message...\n")
		if(check(m)) then
			local start = ticks() / 1000
			pl = pl or m.pl
			msgid = msgid or m.msgid
			if(pl:IsBot()) then return end
			if(pl == nil) then error("^5MESSAGE ERROR[F]: Nil Player\n") end
			if(msgid == nil) then error("^5MESSAGE ERROR[G]: Nil Message Id\n") end
			msgid = string.lower(msgid)
			local prev = msgid
			local msgid = MessageID(pl,tostring(msgid))
			if(msgid == nil) then print("^5Forced Message Precache[" .. prev .. "]\nUse message.Precache(name)\n") return end
			
			local msg = d_Message(pl,1)
			local contents = ""
			for k,v in pairs(m) do
				if(type(v) == "table") then
					local dtype = v[2]
					if(dtype != nil) then
						contents = contents .. tostring(dtype)
					end
				end
			end
			--print("Sent Contents: " .. contents .. "\n")
			_message.WriteLong(msg,tonumber(contents))
			_message.WriteShort(msg,msgid)
			for k,v in pairs(m) do
				if(type(v) == "table") then
					local data = v[1]
					local dtype = v[2]
					--if(!checkData(v,t)) then print("^5MESSAGE ERROR: Invalid Data\n") return end
					local b,e = pcall(funcs[dtype],msg,data)
					if(!b) then
						error("^5MESSAGE ERROR[H]: " .. e .. "\n")
					end
				end
			end
			d_Send(msg)
			--print("Done!\n")
			--print("Message Time: " .. (ticks() / 1000) - start .. "\n")
		end
	end
	
	function SendDataMessageToAll(m,msgid)
		msgid = msgid or m.msgid
		--print("Message To All!\n")
		for k,v in pairs(GetAllPlayers()) do
			if(v:GetTable()._mconnected) then
				SendDataMessage(m,v,msgid)
			end
		end	
	end
	
	local function PlayerJoined(pl)
		if(!pl:IsBot()) then pl:GetTable()._mconnected = true end
		if(pl == nil) then return end
		debugprint("ClientReadyHook:\n")
		SendCache(pl,true)
	end
	hook.add("ClientReady","messages",PlayerJoined,9999)
	
	local function DemoSend(pl)
		if(pl == nil) then return end
		debugprint("ClientDemoHook:\n")
		SendCache(pl,true)
		print("^5Demo Recording Started, Sending Message ID's\n")
	end
	hook.add("DemoStarted","messages",DemoSend,9999)
end

if(CLIENT) then
	local stack = {}
	local funcs = {}
	local lastInStack = -1
	funcs[D_SHORT] = _message.ReadShort
	funcs[D_LONG] = _message.ReadLong
	funcs[D_STRING] = _message.ReadString
	funcs[D_FLOAT] = _message.ReadFloat
	
	local function readData(t)
		local d = stack[1]
		
		if(d == nil) then
			if(lastInStack == -1) then
				error("^5MESSAGE ERROR[I]: Empty DataMessage\n")
			else
				error("^5MESSAGE ERROR[J]: Overread Data After " .. strings[lastInStack] .. "\n")
			end
			return
		end
		
		local data = d[1]
		local dtype = d[2]
		table.remove(stack,1)
		
		lastInStack = dtype
		
		if(dtype == t or t == nil) then return data end
		
		error("^5MESSAGE ERROR[K]: Invalid Data[" .. #stack+2 .. "] (Skipped?)\n" .. 
		      "Attempted to read " .. strings[t] .. " got " .. strings[dtype] .. "\n")
		
		if(t == D_STRING) then return "" end
		if(t == nil) then return nil end
		return 0
	end
	
	function message.ReadShort()
		return readData(D_SHORT)
	end
	
	function message.ReadLong()
		return readData(D_LONG)
	end
	
	function message.ReadString()
		return readData(D_STRING)
	end
	
	function message.ReadFloat()
		return readData(D_FLOAT)
	end
	
	function message.ReadRaw()
		return readData(nil)
	end
	
	function message.ReadVector()
		local x = message.ReadFloat()
		local y = message.ReadFloat()
		local z = message.ReadFloat()
		return Vector(x,y,z)
	end
	
	local function handle(msgid)
		if(msgid == 1) then
			local contents = tostring(_message.ReadLong())
			local strid = _message.ReadShort()
			if(msgIDs[strid] == nil) then
				print("^5MESSAGE ERROR[L]: Invalid Message ID: " .. strid .. "\n")
			end
			--print("Message Contents: " .. contents .. "\n")
			contents = string.ToTable(contents)
			lastInStack = -1
			for k,v in pairs(contents) do
				v = tonumber(v)
				--print("Content: " .. k .. " " .. v .. "\n")
				local b,e = pcall(funcs[v])
				if(!b) then
					error("^5MESSAGE ERROR[M]: " .. e .. "\n")
				else
					if(e != nil) then
						table.insert(stack,{e,v})
					end
				end
			end
			CallHook("HandleMessage",msgIDs[strid],contents)
			stack = {}
		elseif(msgid == 2) then
			local id = _message.ReadShort()
			local str = _message.ReadString()
			msgIDs[id] = str
			debugprint("Got messageID: " .. id .. "->" .. str .. "\n")
		elseif(msgid == 3) then
			local count = _message.ReadLong()
			for i=1, count do
				local id = _message.ReadShort()
				local str = _message.ReadString()
				msgIDs[id] = str
				debugprint("Got messageID: " .. id .. "->" .. str .. "\n")
			end
		else
			error("^5MESSAGE ERROR[N]: Invalid Internal Message ID\n")
		end
	end
	hook.add("_HandleMessage","messages",handle)
	hook.lock("_HandleMessage")
	
	local function report(msgid,contents)
		debugprint("Message Received: " .. msgid .. "\nContents:\n")
		for k,v in pairs(contents) do
			v = tonumber(v)
			debugprint(strings[v] .. ",")
		end
		debugprint("EOM\n")
	end
	hook.add("HandleMessage","messages",report)
end

_SendDataMessage = nil
_Message = nil