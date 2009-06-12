_NetTables = _NetTables or {}
local network_meta = {}

local n_msgid = "_ntbvar"
local types = {}
types["number"] = 1
types["string"] = 1
types["nil"] = 1

local blacklist = {
	"_previous",
	"_protected",
	"_ids",
	"_vars",
	"id",
	"tindex",
	"Init",
	"Reset",
	"VariableChanged",
	"SendVars",
}

local function isBlackListed(var)
	for i=1, #blacklist do
		if(blacklist[i] == var) then return true end
	end
	return false
end

if(SERVER) then
	local function isFloat(n)
		return (math.floor(n) != n)
	end
	
	message.Precache(n_msgid)

	local function sendVariable(self,var,val,new,pl)
		local msg = Message(n_msgid)

		message.WriteShort(msg,self.tindex)
		
		if(val == nil) then
			if(new == true) then msg = nil return end
			message.WriteShort(msg,3)
			message.WriteShort(msg,self._ids[var] or -1)
		else
			if(new) then
				message.WriteShort(msg,1)
				message.WriteString(msg,tostring(var))
			else
				message.WriteShort(msg,2)
			end
			
			message.WriteShort(msg,self._ids[var] or -1)
			
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
		end
		if(pl == nil) then
			for k,v in pairs(GetAllPlayers()) do
				SendDataMessage(msg,v)
			end
		else
			SendDataMessage(msg,pl)
		end
	end
	
	local function variableChanged(self,last,var,val)
		if(last != nil) then
			if(last != val) then
				debugprint("Varable Changed: " .. var .. " " .. tostring(last) .. " -> " .. tostring(val) .. "\n")
				sendVariable(self,var,val,false)
			end
		else
			debugprint("New Variable[" .. self.id .. "]: " .. var .. " = " .. tostring(val) .. "\n")
			self._ids[var] = self.id
			sendVariable(self,var,val,true)
			self.id = self.id + 1
		end
		if(self.VariableChanged != nil) then
			pcall(self.VariableChanged,self,var,val,last)
		end
	end

	function network_meta:SendVars(pl)
		debugprint("Sending Vars To " .. pl:GetInfo().name .. "\n")
		for k,v in pairs(self._protected) do
			debugprint("Sent: " .. tostring(k) .. "\n")
			sendVariable(self,k,v,true,pl)
		end	
	end
	
	function network_meta:Reset()
		self.__mt._previous = {}
		self.__mt._protected = {}
		self.__mt._ids = {}
		self.__mt.id = 0
	end

	function network_meta:Init()
		self:Reset()
	end
	
	function network_meta.__index(self,var)
		local mt = rawget(self,"__mt")
		if(isBlackListed(var) == true) then
			return rawget(mt,var)
		end
		return mt._protected[var]
	end
	
	function network_meta.__newindex(self,var,val)
		local tab = self --rawget(self,"__mt")
		if(isBlackListed(var) == true) then
			rawset(self,var,val)
			return
		end
		if(types[type(val)] == 1) then
			if(val == nil and tab._previous[var] != nil) then
				variableChanged(tab,tab._previous[var],var,nil)
				tab._previous[var] = nil
				return
			end
			if(tab._previous[var] == nil or type(tab._previous[var]) == type(val)) then
				variableChanged(tab,tab._previous[var],var,val)
				tab._protected[var] = val
				tab._previous[var] = val
			else
				error("\n    Invalid Data Type[^7" .. var .. "^1]:\n" .. 
					  "       Last data type was ^7\"" .. type(tab._previous[var]) .. "\"^1\n" ..
					  "       Given data type was ^7\"" .. type(val) .. "\"^1")
			end
		else
			error("Invalid Data Type[^7" .. var .. "^1]!")
		end
	end
	
	local function PlayerJoined(pl)
		local add = 0
		for k,v in pairs(_NetTables) do
			if(v != nil) then
				Timer(.05+add,v.SendVars,v,pl)
				add = add + .05
			end
		end
	end
	hook.add("ClientReady","netvars2",PlayerJoined)
else
	function network_meta:Reset()
		self.__mt._vars = {}
		self.__mt._ids = {}
	end
	
	function network_meta:Init()
		self:Reset()
	end
	
	function network_meta.__index(self,var)
		local mt = rawget(self,"__mt")
		if(isBlackListed(var) == true) then
			return rawget(mt,var)
		end
		return mt._vars[var]
	end
	
	function network_meta.__newindex(self,var,val)
		if(isBlackListed(var) == true) then
			return
		end
		local mt = rawget(self,"__mt")
		mt._vars[var] = val
	end

	local function NetVar(msgid)
		if(msgid == n_msgid) then
			local tindex = message.ReadShort()
			local action = message.ReadShort()

			if(_NetTables[tindex] == nil) then
				_NetTables[tindex] = {}
				setmetatable(_NetTables[tindex],network_meta)
				rawset(_NetTables[tindex],"__mt",table.Copy(network_meta))
				
				_NetTables[tindex].tindex = tindex
				_NetTables[tindex]:Init()
				nt = _NetTables[tindex]
				print("^3Server Forced Client Networked Table: " .. tindex .. "\n")
			end
			
			local mtab = _NetTables[tindex].__mt
			if(action == 1) then
				debugprint("Got New Variable\n")
				local var = message.ReadString()
				local id = message.ReadShort()
				local value = message.ReadRaw()
				var = tonumber(var) or var
				mtab._ids[id] = var
				debugprint(var .. "[" .. id .. "]: " .. tostring(value) .. "\n")

				mtab._vars[var] = value
				local self = _NetTables[tindex]
				if(self.VariableChanged != nil) then
					pcall(self.VariableChanged,self,var,value,nil)
				end
			elseif(action == 2) then
				debugprint("Variable Changed\n")
				local id = message.ReadShort()
				local var = tostring(mtab._ids[id])
				var = tonumber(var) or var
				local value = message.ReadRaw()
				debugprint(var .. "[" .. id .. "]: " .. tostring(value) .. "\n")

				local self = _NetTables[tindex]
				if(self.VariableChanged != nil) then
					pcall(self.VariableChanged,self,var,value,mtab._vars[var])
				end
				mtab._vars[var] = value
			elseif(action == 3) then
				debugprint("Variable Cleared\n")
				local id = message.ReadShort()
				local var = tostring(mtab._ids[id])				
				var = tonumber(var) or var

				local self = _NetTables[tindex]
				if(self.VariableChanged != nil) then
					pcall(self.VariableChanged,self,var,nil,mtab._vars[var])
				end
				mtab._vars[var] = value
			end
		end
	end
	hook.add("HandleMessage","netvars2",NetVar)
end

local function Internal_CreateNetworkedTable(index)
	local nt = _NetTables[index]
	if(nt == nil) then
		_NetTables[index] = {}
		setmetatable(_NetTables[index],network_meta)
		rawset(_NetTables[index],"__mt",table.Copy(network_meta))
		
		_NetTables[index].tindex = index
		_NetTables[index]:Init()
		nt = _NetTables[index]
		if(SERVER) then
			print("Server Created Networked Table: " .. index .. "\n")
		else
			print("Client Created Networked Table: " .. index .. "\n")
		end
	end
	return nt
end

function NetworkTableInUse(index)
	return (_NetTables[index] != nil)
end

function CreateEntityNetworkedTable(index)
	if(index > 0) then
		return Internal_CreateNetworkedTable(index + 1024)
	else
		error("Bad networked table index: " .. index .. "\n")
	end
end

function CreateNetworkedTable(index)
	if(index <= 1024 and index > 0) then
		return Internal_CreateNetworkedTable(index)
	else
		error("Bad networked table index: " .. index .. "\n")
	end
end