D_SHORT = 0
D_LONG = 1
D_STRING = 2
D_FLOAT = 3

local strings = {}
strings[D_SHORT] = "Short"
strings[D_LONG] = "Long"
strings[D_STRING] = "String"
strings[D_FLOAT] = "Float"

message = {}

if(SERVER) then
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
	
	local function checkData(v,t)
		if(t == nil) then return false end
		if(t < D_SHORT or t > D_FLOAT) then return false end
		if(t == D_STRING and type(v) != "string") then return false end
		if(t == D_SHORT and type(v) != "number") then return false end
		if(t == D_LONG and type(v) != "number") then return false end
		if(t == D_FLOAT and type(v) != "number") then return false end
		return true
	end
	
	local function addData(m,v,t)
		if(!checkData(v,t)) then return end
		if(check(m)) then table.insert(m,{v,t})end
	end

	function Message(pl,msgid)
		local tab = {}
		tab.ismessage = true
		tab.pl = pl
		tab.msgid = msgid
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
	
	local d_Message = _Message
	local d_Send = _SendDataMessage
	
	function SendDataMessage(m,pl,msgid)
		if(check(m)) then
			pl = pl or m.pl
			msgid = msgid or m.msgid
			if(pl == nil) then print("^1MESSAGE ERROR: Nil Player\n") end
			if(msgid == nil) then print("^1MESSAGE ERROR: Nil Message Id\n") end
			local msg = d_Message(pl,msgid)
			local contents = ""
			for k,v in pairs(m) do
				if(type(v) == "table") then
					local dtype = v[2]
					if(dtype != nil) then
						contents = contents .. tostring(dtype)
					end
				end
			end
			_message.WriteLong(msg,tonumber(contents))
			for k,v in pairs(m) do
				if(type(v) == "table") then
					local data = v[1]
					local dtype = v[2]
					if(checkData(v,t)) then print("^1MESSAGE ERROR: Ivalid Data\n") return end
					local b,e = pcall(funcs[dtype],msg,data)
					if(!b) then
						print("^1MESSAGE ERROR: " .. e .. "\n")
					end
				end
			end
			d_Send(msg)
		end
	end
end

if(CLIENT) then
	local stack = {}
	local funcs = {}
	funcs[D_SHORT] = _message.ReadShort
	funcs[D_LONG] = _message.ReadLong
	funcs[D_STRING] = _message.ReadString
	funcs[D_FLOAT] = _message.ReadFloat
	
	local function readData(t)
		local d = stack[1]
		local data = d[1]
		local dtype = d[2]
		table.remove(stack,1)
		
		if(dtype == t) then return data end
		
		print("^1MESSAGE ERROR: Invalid Data (Skipped?)\n")
		
		if(t == D_STRING) then return "" end
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
	
	local function handle(msgid)
		local contents = tostring(_message.ReadLong())
		contents = string.ToTable(contents)
		for k,v in pairs(contents) do
			v = tonumber(v)
			local b,e = pcall(funcs[v])
			if(!b) then
				print("^1MESSAGE ERROR: " .. e .. "\n")
			else
				if(e != nil) then
					table.insert(stack,{e,v})
				end
			end
		end
		CallHook("HandleMessage",msgid)
		stack = {}
	end
	hook.add("_HandleMessage","messages",handle)
	hook.lock("_HandleMessage")
end

_SendDataMessage = nil
_Message = nil