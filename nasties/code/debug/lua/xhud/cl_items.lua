local armor_yellow = LoadModel("models/powerups/armor/armor_yel.md3")
local armor_red = LoadModel("models/powerups/armor/armor_red.md3")

function DrawArmor(x,y,w,h,count)
	if(count <= 0) then return end
	local mdl = armor_yellow
	local pos = Vector(90,0,-12)
	local ang = Vector(0,LevelTime()/10,0)
	
	if(count >= 100) then
		mdl = armor_red
	end
	
	render.CreateScene()
	
	local ref = RefEntity()
	ref:SetAngles(ang)
	ref:SetModel(mdl)
	ref:SetPos(pos)
	ref:Render()
	
	local refdef = {}
	refdef.x = x
	refdef.y = y
	refdef.width = w
	refdef.height = h
	refdef.origin = Vector()
	refdef.angles = Vector()
	refdef.flags = 1
	render.RenderScene(refdef)
end

local inf = util.WeaponInfo(1)
for k,v in pairs(inf) do
	print(k .. "\n")
end

function DrawAmmo(x,y,w,h)
	local id = _CG.weapon
	local pos = Vector(60,0,0)
	local ang = Vector(0,90 + (math.sin(LevelTime()/1000)*10),0)
	
	if(id == WP_NONE) then return end
	if(id == WP_GAUNTLET) then return end
	
	local inf = util.WeaponInfo(id)
	local mid = inf.weaponMidpoint
	local mins,maxs = render.ModelBounds(inf.weaponModel)
	if(inf.barrelModel != 0) then
		--local mins2,maxs2 = render.ModelBounds(inf.barrelModel)
		--mins = mins + mins2
		--maxs = maxs + maxs2
	end
	mins.y = 0
	mins.z = 0
	maxs.y = 0
	maxs.z = 0
	
	render.CreateScene()
	
	local ref = RefEntity()
	ref:SetAngles(ang)
	ref:SetModel(inf.ammoModel)
	ref:SetPos(pos - mins)
	ref:Render()
	
	local refdef = {}
	refdef.x = x
	refdef.y = y
	refdef.width = w
	refdef.height = h
	refdef.origin = Vector()
	refdef.angles = Vector()
	refdef.flags = 1
	render.RenderScene(refdef)
end