local NULL = "null"
local parser = {}
parser.keys = {}
parser.codebuffer = {}
parser.nodes = {}
parser.filecache = {}

function parser.keys.import(s)
	local p = parser.filecache[s]
	if(p) then
		for k,v in pairs(p) do
			if(parser.nodes[k] == nil) then
				parser.nodes[k] = v
			end
		end
		return
	end
	parser.parsefile(s,true)
end

function parser.checkkeys(n,line)
	local len = string.len(line)
	for k,v in pairs(parser.keys) do
		local f = string.find(line,k)
		local l = string.len(k)
		if(f ~= nil) then
			local val = string.sub(line,f+l,len)
			val = killGaps(val)
			local b,e = pcall(v,val)
			if not (b) then error(e) end
			return true
		end
	end
end

function parser.checkGrouping(k,v,f)
	if(f) then
		if(parser.level > 0) then
			--print(parser.level .. "\n")
			for i=1, parser.level do
				local lk = parser.locs[i]
				print("^1missing closing '}' for '{' at " .. lk[1] .. ":" .. lk[2] .. "\n")
			end
			error("")
		end
		return
	end
	local t = string.ToTable(v)
	for n,ch in pairs(t) do
		if(ch == "{") then
			parser.level = parser.level + 1
			parser.locs[parser.level] = {k,n}
		end
		if(ch == "}") then
			if(parser.level > 0) then
				parser.level = parser.level - 1
			else
				error("extra '}' at " .. k .. ":" .. n .. "\n")
			end
		end
	end
end

function parser.checkLevel(n,line)
	line = killGaps(line)
	local t = string.ToTable(line)
	local b = ""
	for n,ch in pairs(t) do
		b = b .. ch
		if(ch == "{") then
			b = string.sub(b,1,string.len(b)-1)
			parser.level = parser.level + 1
			--print("^2LEVEL: " .. parser.level .. "-'" .. b ..  "'\n")
			parser.codebuffer[parser.level] = {}
			parser.codebuffer[parser.level].title = b
			parser.codebuffer[parser.level].fields = {}
			parser.codebuffer[parser.level].fieldcount = 0
			return true
		end
		if(ch == "}") then
			local t = parser.codebuffer[parser.level]
			if(parser.level > 1) then
				local tb = {}
				local function pindex(self,v)
					--Meta check here for functions
					local o = t.fields[v]
					if(type(o) == "function") then
						local b,e = pcall(o)
						if(b) then o = e end
					end
					return o
				end
				setmetatable(tb,{__index=pindex})
				parser.codebuffer[parser.level-1].fields[t.title] = tb
			else
				parser.nodes[t.title] = t.fields
			end
			--print("^3LOAD: " .. t.title .. "\n")
			parser.level = parser.level - 1
			return true
		end	
	end
end

function parser.checkOp(n,v,s,ff)
	local mu = string.find(v,s)
	if(mu) then
		local v1 = string.sub(v,1,mu-1)
		local v2 = string.sub(v,mu+1,string.len(v))
		local sv = nil
		sv,v1 = parser.checkValue(n,v1)
		sv,v2 = parser.checkValue(n,v2)
		if(v1 ~= nil and v2 ~= nil) then
			if(type(v1) == "table") then
				if(type(v1) == type(v2)) then
					local f = function()
						local t = {}
						local k = 1
						while(v1[k] ~= nil) do
							local v1v = v1[k]
							local v2v = v2[k]
							if(type(v1[k]) == "function") then sv,v1v = pcall(v1[k]) end
							if(type(v2[k]) == "function") then sv,v2v = pcall(v2[k]) end
							if(type(v1v) == "number") then
								sv,t[k] = pcall(ff,v1v,v2v)
							else
								t[k] = v1v
							end
							k = k + 1
						end
						return t
					end
					return true,f
				else
					local f = function()
						local t = {}
						local k = 1
						while(v1[k] ~= nil) do
							local v1v = v1[k]
							local v2v = v2
							if(type(v2) == "function") then sv,v2v = pcall(v2) end
							if(type(v2v) == "number") then
								sv,t[k] = pcall(ff,v1v,v2v)
							else
								t[k] = v1v
							end
							k = k + 1
						end
						return t
					end
					return true,f
				end
			end
			return true,function()
				local v1v = v1
				local v2v = v2
				if(type(v1) == "function") then sv,v1v = pcall(v1) end
				if(type(v2) == "function") then sv,v2v = pcall(v2) end
				if(type(v1v) ~= "number") then 
					print("ErrorV1: " .. v1v .. "\n")
					return 0 
				end
				if(type(v2v) ~= "number") then
					print("ErrorV2: " .. v2v .. "\n")
					return 0 
				end
				local sv,m = pcall(ff,v1v,v2v)
				return m
			end
		end
	end
end

function parser.checkValue(n,v)
	if(v == NULL or v == "nil") then
		return true,NULL
	end

	if(string.find(v,"\"")) then 
		v = string.Replace(v,"\"","")
		return true,v
	end
	
	local n = tonumber(v)
	if(n ~= nil) then
		return true,n
	end
	
	local b,e = parser.checkOp(n,v,"*",function(v1,v2) return v1*v2 end)
	if(b) then return b,e end
	
	local b,e = parser.checkOp(n,v,"-",function(v1,v2) return v1-v2 end)
	if(b) then return b,e end
	
	local b,e = parser.checkOp(n,v,"+",function(v1,v2) return v1+v2 end)
	if(b) then return b,e end
	
	local b,e = parser.checkOp(n,v,"/",function(v1,v2) return v1/v2 end)
	if(b) then return b,e end
	
	local b,e = parser.checkOp(n,v,"|",function(v1,v2) return v1 + math.random()*(v2-v1) end)
	if(b) then return b,e end
	
	if(firstChar(v) == "[" and lastChar(v) == "]") then
		v = string.sub(v,2,string.len(v)-1)
		v = v
		local tab = {}
		local t = string.Explode(",",v)
		for lk,lv in pairs(t) do
			local s,llv = parser.checkValue(n,lv)
			if(s) then
				tab[lk] = llv
			end
		end
		local tv = {}
		
		local function pindex(self,k)
			--Meta check here for functions
			local o = tab[k]
			if(type(o) == "function") then
				--print("INDEX: " .. k .. "\n")
				local b,e = pcall(o)
				if(b) then o = e end
			end
			return o
		end
		local n = #tab
		setmetatable(tv,{__index=pindex})
		
		return true,tv
	end
	
	if(parser.nodes[v] ~= nil) then
		return true,parser.nodes[v]
	end
	if(_G[v] ~= nil) then
		--v = _G[v]
		return true,function() return _G[v] end
	end
	
	
	return false
end

function parser.checkField(n,line)
	line = killGaps(line)
	local c = string.find(line,":")
	if not c then
		local v = killGaps(line)
		if(parser.nodes[v] ~= nil) then
			local k = parser.codebuffer[parser.level].fieldcount + 1
			print("NODE: " .. k .. " " .. v .. "\n")
			local node = parser.nodes[v]
			node = parser.setMeta(node)
			table.insert(parser.codebuffer[parser.level].fields,node)
			--parser.codebuffer[parser.level].fields[k] = v
			parser.codebuffer[parser.level].fieldcount = k
			return true
		end
		s,v = parser.checkValue(n,v)
		if(s) then
			table.insert(parser.codebuffer[parser.level].fields,v)
			return true
		end
		
		return true
	end
	
	local k = string.sub(line,1,c-1)
	local v = string.sub(line,c+1,string.len(line))
	
	local s,v = parser.checkValue(n,v)
	if(s ~= true) then return true end
	parser.codebuffer[parser.level].fields[k] = v
end

function parser.setup(keepnodes)
	parser.level = 0
	parser.locs = {}
	parser.codebuffer = {}
	if not (keepnodes) then
		parser.nodes = {}
	end
end

function parser.parseLine(n,line)
	if(string.find(line,"//")) then return end
	if(parser.checkLevel(n,line)) then return end
	if(parser.checkkeys(n,line)) then return end
	if(parser.checkField(n,line)) then return end
end

function parser.parse(str,keepnodes)
	str = string.Replace(str,"\r","\n")
	parser.setup(keepnodes)
	local lines = string.Explode("\n",str)
	for k,v in pairs(lines) do
		parser.checkGrouping(k,v)
	end
	parser.checkGrouping(nil,nil,true)
	for k,v in pairs(lines) do
		parser.parseLine(k,v)
	end	
	
	return parser.nodes
end

function parser.parsefile(file,keepnodes)
	local txt = packRead(file)
	if(txt == nil) then
		ffile = io.open("../../" .. file,"r")
		if(ffile ~= nil) then
			local lines = 0
			local content = ""
			for line in ffile:lines() do
				content = content .. line .. "\n"
			end
			ffile:close()
		end
	end
	if(txt == nil) then 
		print("^1Error: Could Not Read File: " .. file .. ".\n") 
		return nil
	end
	local p = parser.parse(txt,keepnodes)
	parser.filecache[file] = p
	return p
end

function parser.clear()
	parser.filecache = {}
end

function parser.setMeta(tab)
	if(getmetatable(tab) ~= nil) then return tab end
	local __node = tab
	local mtnew = {}
	local mt = {}
	mt.__index = function(self,v)
		local t = __node
		local fv = t[v]
		local o = rawget(__node,fv)
		if(o == NULL) then return nil end
		if(v ~= "base") then
			while(fv == nil and t.base ~= nil) do
				t = t.base
				fv = t[v]
			end
			o = fv
		end
		if(type(o) == "function") then
			local b,e = pcall(o)
			if(b) then o = e end
		end
		return o
	end
	setmetatable(mtnew,mt)
	return mtnew
end

local ParserT = {}

function ParserT:ParseFile(f,tab)
	local p = parser.parsefile(f)
	if(type(tab) == "table" and p) then
		for k,v in pairs(p) do
			tab[k] = v
		end
	end
	return p
end

function ParserT:ParseString(s,tab)
	local p = parser.parse(s)
	if(type(tab) == "table" and p) then
		for k,v in pairs(p) do
			tab[k] = v
		end
	end
	return p
end

function ParserT:SetMeta(tab)
	for k,v in pairs(tab) do
		tab[k] = parser.setMeta(tab[k])
	end
end

function ParserT:Clear()
	 parser.clear()
end

function TreeParser()
	local o = {}

	setmetatable(o,ParserT)
	ParserT.__index = ParserT

	parser.clear()
	
	return o;
end

print("^1Loaded TreeParser\n")