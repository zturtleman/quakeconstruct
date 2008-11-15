local y = 470

local function draw2d()
	local x = 0
	local hp = _CG.stats[STAT_HEALTH]
	local armor = _CG.stats[STAT_ARMOR]
	local ammo = _CG.ammo[_CG.weapon+1]
	local pk = _CG.itemPickupTime
	local pi = _CG.itemPickup
	local pkn = "<invalid>"
		local size = 150
		drawHead(x-15,y-size,size,hp)
		x = x + size
	
		if(pi > 0) then pkn = util.GetItemName(pi) end
		local dhp = math.min(math.max(hp/100,0),1)
		local dhp2 = math.min((1-dhp)*2,1)
		if(hp <= 25) then dhp2 = math.min(dhp2,.5) end
		
		y = hud_field(x,y,hp,true,"Health",{dhp2,dhp,0,1},30)
		if(hp > 0) then
			y = hud_field(x,y,armor,true,"Armor",{.7,1,0,1},20)
			y = hud_field(x,y,ammo,true,"Ammo",{1,1,.2,1},20)
		end
		y = hud_field(x,y,util.GetWeaponName(_CG.weapon),false,nil,{1,1,1,1},12)
		if((pk + 3000) > LevelTime() and pkn != nil) then
			local dp = ((pk+3000) - LevelTime())/3000
			y = hud_field(x,y,pkn,false,nil,{1,1,1,dp},15)
		end
	hud_drawPickups()
	hud_drawFlashes()
	y=470
end
hook.add("Draw2D","cl_hp",draw2d)

local function shouldDraw(str)
	if(str == "HUD_STATUSBAR_HEALTH") then return false end
	if(str == "HUD_STATUSBAR_ARMOR") then return false end
	if(str == "HUD_STATUSBAR_AMMO") then return false end
	if(str == "HUD_PICKUP") then return false end
	--print(str .. "\n")
end
hook.add("ShouldDraw","cl_hp",shouldDraw)