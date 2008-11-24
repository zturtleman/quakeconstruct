_CUSTOM = {}

local function checkdir(str)
	if(str == "" or string.find(str,".") != nil) then return false end
	return true
end

function Execute(dir)
	if(SERVER) then
		include(dir .. "/init.lua")
	else
		include(dir .. "/cl_init.lua")
	end
end

function FindCustomFiles(dir)
	local out = {}
	for filename in lfs.dir(dir) do
		local attr = lfs.attributes(dir .. "/" .. filename)
		if (attr.mode == "directory" and checkdir(filename) ) then
			print("Found " .. filename .. "\n")
			table.insert(out,{dir .. "/" .. filename,filename})
		end
	end
	return out
end

include("lua/includes/custom_ents.lua")

FindCustomFiles = nil
