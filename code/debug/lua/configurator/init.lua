downloader.add("lua/configurator/cl_init.lua")

local weapons = GetEnumSet(weapon_t,val)

for k,v in pairs(weapons) do
	print(v.name .. "\n")
end