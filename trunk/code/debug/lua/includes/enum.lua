local enum = {}
enum_weaponentities = {
	"weapon_gauntlet",
	"weapon_machinegun",
	"weapon_shotgun",
	"weapon_grenadelauncher",
	"weapon_rocketlauncher",
	"weapon_lightning",
	"weapon_railgun",
	"weapon_plasmagun",
	"weapon_bfg"
}

function killWhiteSpace(line)
	local tab = string.Explode ( "\t", line )
	for k,v in pairs(tab) do
		if not (v == "" or string.find(v, "//")) then
			return v
		end
	end
	return ""
end

function parseEnumerationSet(file)
	local ef = io.input(file)
	local inEnum = false
	local enumlist = {}
	local enumcontents = {}
	while true do
		local line = io.read()
		if line == nil then break end
		line = string.Trim(line)
		if(string.find(line,"enum {")) then
			inEnum = true
		elseif(string.find(line,"}")) then
			inEnum = false
			line = string.Replace(line, ";", "")
			line = string.sub(line,3)
			enum[line] = enumcontents
			enumcontents = {}
		else
			if(inEnum) then
				line = killWhiteSpace(line)
				if not (line == "") then
					line = string.Replace(line, ",", "")
					table.insert(enumcontents,line)
				end
			end
		end
	end
	io.close(ef)
end

local enumfiles = findFileByType("enum")
for k,v in pairs(enumfiles) do
	print("^3Found Enumeration Set '" .. v .. "'.\n")
	parseEnumerationSet(v)
end

local count = 0
for n,e in pairs(enum) do
	print("^3Enumerated '" .. n .. "'.\n")
	for k,v in pairs(e) do 
		_G[v] = k-1
		count = count + 1
	end
	e.IsEnumeration = true
	_G[n] = e--enumstrings[n]
end

function EnumToString(set,val)
	if not(set == nil) then
		if(type(set) == "table") then
			for k,v in pairs(set) do
				if(k == (val+1)) then
					if(type(v) == "string") then
						return v
					end
				end
			end
		else
			error("Invalid Set Type.\n")
		end
	else
		error("Set Was Nil.\n")
	end
	error("Unable To Find Value\n")
	return ""
end

print("^3" .. count .. " Enumerations loaded.\n")