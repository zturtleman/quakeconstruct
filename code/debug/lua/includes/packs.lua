local packlib = {}
packlib.packs = {}

local function gapFix(str)
	local nstr = ""
	local inquotes = false
	local l = string.len(str)
	for i=1,l do
		local ch = string.sub(str,i,i)
		if(ch == "\"") then
			inquotes = !inquotes
		elseif((ch != " " and ch != "\t") or inquotes) then
			nstr = nstr .. ch
		end
	end
	return nstr
end

local function fileDir(file)
	local fname = string.GetFileFromFilename(file)
	local bdir = string.sub(file,0,string.len(file)-(string.len(fname)))
	return bdir
end

function packlib.CreatePack(file)

	local o = {}

	setmetatable(o,{})
	
	o['PACK_DIR'] = fileDir(file)
	o['PACK_AUTHOR'] = "n/a"
	o['PACK_DESCRIPTION'] = "n/a"
	o['PACK_MODE'] = "invalid"
	o.include = function(self,name)
		P = table.Copy(self)
		P['PACK_DIR'] = fileDir(fileDir(file) .. "/" .. name)
		include(self['PACK_DIR'] .. "/" .. name)
		P = table.Copy(self)
	end
	
	return o
	
end

function packlib.LoadPacks()
	local packs = findFileByType("pack","./lua/packs")
	for k,v in pairs(packs) do
		local t = packlib.CreatePack(v)
		table.insert(packlib.packs,t)
	end
end

function packlib.ParsePack(pack)
	local err = 0
	local p = pack['PACK_DIR']
	local ef = io.input(p .. "/info.pack")
	P = pack
	while true do
		local line = io.read()
		if line == nil then break end
		line = gapFix(line)
		local eq = string.find(line,"=")
		if(eq == nil) then err = 1 break end
		local key = string.sub(line,0,eq-1)
		local val = string.sub(line,eq+1,string.len(line))
		pack[key] = val
	end
	io.close(ef)
	if(err == 0) then
		local dir = pack['PACK_DIR']
		local mode = pack['PACK_MODE']
		local name = pack['PACK_DESCRIPTION']
		if(name == "n/a") then name = dir end
		print("Loading Pack: '" .. name .. "'\n")
		if(mode != "lib" and mode != "game") then 
			print("^1Unable to load pack: invalid type, specify \"game\" or \"lib\"\n")
			return 
		end
		if(fileExists(dir .. "/cl_init.lua") and CLIENT) then
			include(dir .. "/cl_init.lua")
		end
		if(fileExists(dir .. "/init.lua") and SERVER) then
			include(dir .. "/init.lua")
		end
		return ptab
	else
		print("^1There was an error loading the pack.\n")
	end
	P = nil
end

function packlib.ParseAll()
	for k,v in pairs(packlib.packs) do
		packlib.ParsePack(v)
	end
end

packlib.LoadPacks()
packlib.ParseAll()