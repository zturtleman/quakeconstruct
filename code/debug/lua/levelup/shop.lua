downloader.add("lua/levelup/cl_shop.lua")

local function RemoveStuff()
	local tab = table.Copy(GetAllEntities())
	for k,v in pairs(tab) do
		local class = v:Classname()
		if(string.find(class,"weapon")) then
			v:Remove()
		end
	end
end
RemoveStuff()

local function buyWeapon(pl,id)
	local t = LV_tableForPlayer()
	if(t == nil) then return end
	local w = t.weapons[id] or 0
	local bcost = LVSHOP[1][id][1]
end