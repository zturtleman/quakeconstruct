local torsosub = 156 - 94
local leganim = Animation(190 - torsosub,11,20)
local legidle = Animation(258 - torsosub,10,15)
local torsoanim = Animation(156,1,50)
local health = 100
local lastTarget = nil
local gibhp = -40
local skull = LoadModel("models/gibs/skull.md3")
local flare = LoadShader("flareShader")
local skspin = Vector()
local spin = 0
local gibpos = Vector()
local look = Vector()
local look2 = Vector()
leganim:SetType(ANIM_ACT_LOOP_LERP)
legidle:SetType(ANIM_ACT_LOOP_LERP)
local function trDown(pos)
	local endpos = vAdd(pos,Vector(0,0,-1000))
	local res = TraceLine(pos,endpos,nil,1)
	return res.endpos
end

local headpos = Vector()
local headang = Vector()

local function RefFlare(pos)
	local fl = RefEntity()
	fl:SetShader(flare)
	fl:SetColor(.9,0,0,1)
	fl:SetRadius(5)	
	fl:SetPos(pos)
	fl:SetType(RT_SPRITE)
	fl:Render()
end

local function sight(pos,ang)
	local f = ang
	local endpos = vAdd(pos,vMul(f,10000))
	local res = TraceLine(pos,endpos,nil,1)
	RefFlare(res.endpos)
end

local function d3d()
	LocalPlayer():CustomDraw(true)
	--[[local tab = GetEntitiesByClass("player")
	for k,v in pairs(tab) do
		if(v != nil and v:GetWeapon() == WP_ROCKET_LAUNCHER) then
			v:CustomDraw(true)
			print("BQ\n")
		end
	end]]
	
	--local pos = _CG.refdef.origin --LocalPlayer():GetPos()
	--pos.z = pos.z - 25
	
	--pos.z = LocalPlayer():GetPos().z
	--local fl = trDown(pos).z + 25
	
	--pos.z = math.max(fl,pos.z)
	
	local player = LocalPlayer()
	local hp = health
	local pos = player:GetPos()
	
	local head = RefEntity()
	local torso = RefEntity()
	local legs = RefEntity()
	local f = _CG.refdef.forward
	local ang = LocalPlayer():GetAngles()--VectorToAngles(f)
	local vlen = VectorLength(LocalPlayer():GetTrajectory():GetDelta())
	
	--ang.x = 0
	--ang.z = 0
	
	f = AngleVectors(ang)
	local off = vMul(f,10)

	legs:SetAngles(ang)
	
	if(hp > gibhp) then
		util.AnimatePlayer(LocalPlayer(),legs,torso)
		util.AnglePlayer(LocalPlayer(),legs,torso,head)
	end
	
	legs:SetPos(vSub(pos,off)) --Vector(652,1872,24)
	legs:SetPos2(vSub(pos,off))
	legs:SetColor(1,1,1,1)
	legs:SetModel(LocalPlayer():GetInfo().legsModel)
	legs:SetSkin(LocalPlayer():GetInfo().legsSkin)
	
	torso:SetModel(LocalPlayer():GetInfo().torsoModel)
	torso:SetSkin(LocalPlayer():GetInfo().torsoSkin)
	torso:PositionOnTag(legs,"tag_torso")
	
	head:SetModel(LocalPlayer():GetInfo().headModel)
	head:SetSkin(LocalPlayer():GetInfo().headSkin)
	head:PositionOnTag(torso,"tag_head")

	local f,r,u = head:GetAxis()
	local p = VectorToAngles(f).x
	local y = VectorToAngles(r).y - 90
	local r = VectorToAngles(r).x
	local hang = Vector(p,y,r)--head:GetAngles()
	
	local delta = getDeltaAngle3(hang,headang)
	headang = vAdd(headang,vMul(delta,.2))
	
	
	headpos = head:GetPos()
	--headpos = vAdd(headpos,vMul(f,-5))
	--headpos = vAdd(headpos,vMul(u,8))
	
	--[[if(vlen > 100) then
		leganim:SetRef(legs)
		leganim:Animate()
	else
		legidle:SetRef(legs)
		legidle:Animate()
	end]]
	
	if(hp > gibhp) then
		legs:Render()
		if(hp <= 0) then
			torso:Render()
			head:Render()
		end
	else
		local ref = RefEntity()
		ref:SetModel(LocalPlayer():GetInfo().headModel)
		ref:SetSkin(LocalPlayer():GetInfo().headSkin)
		ref:SetPos(LocalPlayer():GetPos())
		local vlen = VectorLength(LocalPlayer():GetTrajectory():GetDelta())
		if(vlen > 1) then
			spin = spin + 1
		else
			local pos = ref:GetPos()
			pos.z = trDown(pos).z + 5
			ref:SetPos(pos)
		end
		
		ref:SetAngles(vMul(skspin,spin))
		ref:Scale(Vector(1.5,1.5,1.5))
		
		ref:Render()
		
		legs:SetAngles(vAdd(LocalPlayer():GetAngles(),Vector(90,0,0)))
		legs:SetPos(gibpos)
		legs:SetFrame(1)
		legs:SetOldFrame(1)
		
		legs:Render()
	end
	
	if(lastTarget != LocalPlayer()) then
		health = 100
		lastTarget = LocalPlayer()
	end
end
hook.add("Draw3D","cl_legtest",d3d)

local deadpos = Vector()

local function legview(pos,ang,fovx,fovy)
	local hp = health
	local prev = Vector(pos.x,pos.y,pos.z)
	local preva = Vector(ang.x,ang.y,ang.z)
	
	if(hp > 0) then sight(pos,AngleVectors(ang)) end
	
	if(hp > gibhp) then
		pos = headpos
		ang = headang
		
		skspin = Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10))
		
		--Constrain Bob
		if(hp > 0) then
			ang.y = ang.y + getDeltaAngle(ang.y,preva.y)/1.5
			ang.x = ang.x + getDeltaAngle(ang.x,preva.x)/2
			ang.z = ang.z + getDeltaAngle(ang.z,preva.z)/4
			
			deadpos = pos
			
			--pos.z = prev.z
		end
	end
	
	if(hp <= 0) then
	
		local ang2 = LocalPlayer():GetAngles()--VectorToAngles(f)
	
		if(hp > gibhp) then
			deadpos = vAdd(deadpos,vMul(vSub(pos,deadpos),.05))
			local f,r,u = AngleVectors(ang2)
			pos = vAdd(deadpos,Vector(0,0,45))
			--pos.x = prev.x
			--pos.y = prev.y
			pos = vAdd(pos,vMul(r,35))
		else
			deadpos = LocalPlayer():GetPos()
			pos = deadpos
		end
		--ang = Vector(90,LevelTime()/60,0)
		
		if(hp > gibhp) then
			ang = VectorToAngles(VectorNormalize(vSub(headpos,pos)))
			ang.z = headang.z --ang.z + 30
			pos.z = headpos.z + 45
			ang = vAdd(ang,look2)
		else
			ang = VectorToAngles(VectorNormalize(vSub(gibpos,pos)))
			ang = vAdd(ang,look2)
			local f = AngleVectors(ang)
			pos = vAdd(pos,vMul(f,-100))
			pos.z = LocalPlayer():GetPos().z + 4
		end
		
		look2 = vAdd(look2,vMul(getDeltaAngle3(look,look2),.03))
		
		ang.z = ang.z - 25
	else
		look = Vector()
	end
	
	ApplyView(pos,ang)
end
hook.add("CalcView","cl_legtest",legview)

local function moused(x,y)
	look = vAdd(look,Vector(y/6,-x/6,0))
	if(look.x < -90) then look.x = -90 end
	if(look.x > 90) then look.x = 90 end
end
hook.add("MouseEvent","cl_legtest",moused)

local function processDamage(attacker,pos,dmg,death,waslocal,wasme,hp)
	if(waslocal) then
		if(hp < -40 and health > 0) then
			gibpos = LocalPlayer():GetPos()
			gibpos.z = trDown(gibpos).z
		end
		health = hp
	end
end

local function respawn()
	health = 100
	marks = {}
end
hook.add("Damaged","cl_legtest",processDamage)
hook.add("Respawned","cl_legtest",respawn)