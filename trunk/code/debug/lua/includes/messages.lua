D_SHORT = 1 --At first this was 0 but now I realize that 'tostring' truncates 0's
D_LONG = 2
D_STRING = 3
D_FLOAT = 4
D_BYTE = 5

local msgIDs = {}
local strings = {}
strings[D_SHORT] = "Short"
strings[D_LONG] = "Long"
strings[D_STRING] = "String"
strings[D_FLOAT] = "Float"
strings[D_BYTE] = "Byte"

local types = {}
types[D_SHORT] = "number"
types[D_LONG] = "number"
types[D_STRING] = "string"
types[D_FLOAT] = "number"
types[D_BYTE] = "number"

local defaults = {}
defaults[D_SHORT] = 0
defaults[D_LONG] = 0
defaults[D_STRING] = ""
defaults[D_FLOAT] = 0
defaults[D_BYTE] = 0

local connections = {}

message = {}

if(SERVER) then
	local nextid = 1
	local funcs = {}
	funcs[D_SHORT] = _message.WriteShort
	funcs[D_LONG] = _message.WriteLong
	funcs[D_STRING] = _message.WriteString
	funcs[D_FLOAT] = _message.WriteFloat
	funcs[D_BYTE] = _message.WriteByte

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
		if(t < D_SHORT or t > D_BYTE) then return false end
		if(type(v) != types[t]) then reportDataType(v,t,m) return false end
		return true
	end
	
	local function addData(m,v,t)
		m.argcount = m.argcount + 1
		if(!checkData(v,t,m)) then 
			v = defaults[t]
		end
		if(check(m)) then 
			--debugprint("AddToStack: " .. strings[t] .. "\n")
			table.insert(m,{v,t})
		end
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
		tab.WriteByte = message.WriteByte
		tab.WriteShort = message.WriteShort
		tab.WriteLong = message.WriteLong
		tab.WriteString = message.WriteString
		tab.WriteFloat = message.WriteFloat
		tab.WriteVector = message.WriteVector
		return tab
	end

	function message.WriteByte(m,s)
		addData(m,s,D_BYTE)
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
	
	function message.WriteEntity(m,e)
		message.WriteShort(m,e:EntIndex())
	end
	
	local d_Message = _Message
	local d_Send = _SendDataMessage
	
	local function MessageID(pl,id)
		if(msgIDs[id] == nil) then
			msgIDs[id] = nextid
			nextid = nextid + 1
		end
		if(pl != nil and connections[pl:EntIndex()]) then
			local tab = pl:GetTable()
			tab.msglist = tab.msglist or {}
			if(tab.msglist[id] != true) then
				local msg = d_Message(pl,LUA_MESSAGE_INDEX)
				_message.WriteByte(msg,msgIDs[id])
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
		local msg = d_Message(pl,LUA_MESSAGE_CACHE)
		_message.WriteLong(msg,ts)
		for i=1, ts do
			local v = send[i]
			debugprint("Send: " .. v[1] .. "->" .. v[2] .. "\n")
			_message.WriteByte(msg,v[1])
			_message.WriteString(msg,v[2])
		end
		d_Send(msg)
	end
	
	--pl:GetTable()._mconnected
	
	function message.Precache(str)
		if(str != nil and type(str) == "string") then
			str = string.lower(str)
			if(msgIDs[str] == nil) then
				msgIDs[str] = nextid
				nextid = nextid + 1
				
				debugprint("Message Precache[" .. str .. "]:\n")
				for k,v in pairs(GetAllPlayers()) do
					if(connections[v:EntIndex()]) then
						SendCache(v)
					end
				end
			end
		else
			error("^5MESSAGE ERROR[E]: Failure to precache message (Use String)\n")
		end
	end
	
	local function printPl(pl)
		local name = pl:GetInfo().name or "Unknown"
		local ping = pl:GetInfo().ping or "999"
		return "[" .. pl:EntIndex() .. "]: " .. name .. " " .. ping .. "ms\n"
	end
	
	local function L_SendDataMessage(m,pl,msgid)
		--print("Sending Data Message...\n")
		if(check(m)) then
			local start = ticks() / 1000
			pl = pl or m.pl
			msgid = msgid or m.msgid
			if(pl:IsBot()) then return end
			if(pl == nil) then error("^5MESSAGE ERROR[F-1]: Nil Player\n") end
			if(pl:GetTable() == nil) then error("^5MESSAGE ERROR[F-2]: Nil Player Table\n" .. printPl(pl)) end
			if(connections[pl:EntIndex()] == false) then error("^5MESSAGE ERROR[F-3]: Nil Player Not Connected\n" .. printPl(pl)) end
			if(msgid == nil) then error("^5MESSAGE ERROR[G]: Nil Message Id\n") end
			msgid = string.lower(msgid)
			local prev = msgid
			local msgid = MessageID(pl,tostring(msgid))
			if(msgid == nil) then print("^5Forced Message Precache[" .. prev .. "]\nUse message.Precache(name)\n") return end
			
			local msg = d_Message(pl,LUA_MESSAGE_MSG)
			local contents = ""
			for i=1, #m do
				local v = m[i]
				if(type(v) == "table") then
					local dtype = v[2]
					if(dtype != nil) then
						contents = contents .. tostring(dtype)
					end
				end
			end
			
			if(contents == "") then contents = "9" end
			debugprint("Sent Contents: " .. contents .. "\n")
			_message.WriteLong(msg,tonumber(contents))
			_message.WriteByte(msg,msgid)
			for i=1, #m do
				local v = m[i]
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
	
	local MessageQueue = {}
	
	function QueueMessage(m,player,msgid)
		local expires = LevelTime() + 100
		table.insert(MessageQueue,{m,player,msgid,expires})
	end
	
	function SendDataMessage(m,pl,msgid)
		pl = pl or m.pl
		msgid = msgid or m.msgid
		if(connections[pl:EntIndex()]) then
			QueueMessage(m,pl,msgid)
		end
	end
	
	function SendDataMessageToAll(m,msgid)
		msgid = msgid or m.msgid
		--print("Message To All!\n")
		for k,v in pairs(GetAllPlayers()) do
			if(connections[v:EntIndex()]) then
				SendDataMessage(m,v,msgid)
			end
		end	
	end
	
	local function Think()
		for i=1, 3 do --try and do 3 messages
			if(#MessageQueue == 0) then return end
			--print("Queue: " .. #MessageQueue .. "\n")
			local ltime = LevelTime()
			local focus = MessageQueue[1]
			local m = focus[1]
			local player = focus[2]
			local msgid = focus[3]
			local expires = focus[4]
			
			if(player == nil) then
				table.remove(MessageQueue,1)	
			else
				if(connections[player:EntIndex()]) then
					L_SendDataMessage(m,player,msgid)
					table.remove(MessageQueue,1)
				else
					if(expires < ltime) then
						table.remove(MessageQueue,1)
						print("^6Message Expired: " .. msgid .. "\n")
					end
				end
			end
		end
	end
	hook.add("Think","messages",Think)
	
	local function PlayerJoined(pl)
		if(pl == nil) then return end
		if(!pl:IsBot()) then connections[pl:EntIndex()] = true end
		debugprint("ClientReadyHook:\n")
		SendCache(pl,true)
	end
	hook.add("ClientReady","messages",PlayerJoined,9999)
	
	local function PlayerStop(pl)
		if(pl == nil) then return end
		if(!pl:IsBot()) then connections[pl:EntIndex()] = false end
		debugprint("ClientStopHook:\n")
	end
	hook.add("ClientShutdownLua","messages",PlayerStop,9999)
	
	local function DemoSend(pl)
		if(pl == nil) then return end
		Timer(.7,function()
			debugprint("ClientDemoHook:\n")
			SendCache(pl,true)
			print("^5Demo Recording Started, Sending Message ID's\n")
		end)
	end
	hook.add("DemoStarted","messages",DemoSend,9999)
end

if(CLIENT) then
	local stack = {}
	local funcs = {}
	local lastInStack = -1
	funcs[D_BYTE] = _message.ReadByte
	funcs[D_SHORT] = _message.ReadShort
	funcs[D_LONG] = _message.ReadLong
	funcs[D_STRING] = _message.ReadString
	funcs[D_FLOAT] = _message.ReadFloat
	
	local function readData(t)
		local d = stack[1]
		
		if(d == nil) then
			if(lastInStack == -1) then
				print("^5MESSAGE ERROR[I]: Empty DataMessage\n")
			else
				print("^5MESSAGE ERROR[J]: Overread Data After " .. strings[lastInStack] .. "\n")
			end
			return
		end
		
		local data = d[1]
		local dtype = d[2]
		table.remove(stack,1)
		
		lastInStack = dtype
		
		if(dtype == t or t == nil) then return data end
		
		print("^5MESSAGE ERROR[K]: Invalid Data[" .. #stack+2 .. "] (Skipped?)\n" .. 
		      "Attempted to read " .. strings[t] .. " got " .. strings[dtype] .. "\n")
		
		if(t == D_STRING) then return "" end
		if(t == nil) then return nil end
		return 0
	end
	
	function message.StackSize()
		return #stack
	end
	
	function message.ReadByte()
		return readData(D_BYTE)
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
	
	function message.ReadEntity()
		return GetEntityByIndex(readData(D_SHORT))
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
		if(msgid == LUA_MESSAGE_MSG) then
			stack = {}
			local contents = tostring(_message.ReadLong())
			local strid = _message.ReadByte()
			if(msgIDs[strid] == nil) then
				print("^5MESSAGE ERROR[L]: Invalid Message ID: " .. strid .. "\n")
			end
			--print("Message Contents: " .. contents .. "\n")
			if(contents != "9") then
				contents = string.ToTable(contents)
				lastInStack = -1
				for k,v in pairs(contents) do
					v = tonumber(v)
					--print("Content: " .. k .. " " .. v .. "\n")
					if(v != nil and funcs[v] != nil) then
						local b,e = pcall(funcs[v])
						if(!b) then
							error("^5MESSAGE ERROR[M]: " .. e .. "\n")
						else
							if(e != nil) then
								table.insert(stack,{e,v})
							end
						end
					end
				end
			else
				contents = {}
				stack = {}
			end
			local tstack = table.Copy(stack)
			onHookCall = function(event,...)
				stack = {}
				table.Add( stack, tstack )
			end
			CallHook("HandleMessage",msgIDs[strid],contents)
			onHookCall = function() end
			tstack = {}
			stack = {}
		elseif(msgid == LUA_MESSAGE_INDEX) then
			local id = _message.ReadByte()
			local str = _message.ReadString()
			msgIDs[id] = str
			debugprint("Got messageID: " .. id .. "->" .. str .. "\n")
		elseif(msgid == LUA_MESSAGE_CACHE) then
			local count = _message.ReadLong()
			for i=1, count do
				local id = _message.ReadByte()
				local str = _message.ReadString()
				msgIDs[id] = str
				debugprint("Got messageID: " .. id .. "->" .. str .. "\n")
			end
		end
	end
	hook.add("_HandleMessage","messages",handle)
	
	local function report(msgid,contents)
		debugprint("Message Received: " .. msgid .. "\nContents:\n")
		for k,v in pairs(contents) do
			v = tonumber(v)
			if(v != 9) then
				debugprint(strings[v] .. ",")
			end
		end
		debugprint("EOM\n")
	end
	hook.add("HandleMessage","messages",report)
end