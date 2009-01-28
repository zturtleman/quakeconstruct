local i=0
local rpos = Vector(670,500,30)
local lastPos = Vector()
local bob = 0
local nxt = 0
local plmoved = Vector()
local lastplmoved = Vector()
local smoothvel = 0
local smoothfall = 0
local ddir = 0
local sdir = 0
local hp = 100
local look = Vector()
local look2 = Vector()
local shake = 0
local headang = Vector()
local headpos = Vector()
local gibhp = -40
local skspin = Vector()
local spin = 0
local gibpos = Vector()
local deadpos = Vector()

local function trAlong(pos,angle,dist)
	local off = VectorForward(angle)*dist
	local endpos = vAdd(pos,off)
	local res = TraceLine(pos,endpos,nil,1)
	return res.endpos
end

local function trDown(pos)
	local endpos = vAdd(pos,Vector(0,0,-1000))
	local res = TraceLine(pos,endpos,nil,1)
	return res.endpos
end

local function maxvel(v)
	return math.min(math.max(v,-320),320)/320;
end

local function d3d()
	LocalPlayer():CustomDraw(true)
	
	local player = LocalPlayer()
	local hp = _CG.stats[STAT_HEALTH]
	local pos = player:GetPos()
	
	local head = RefEntity()
	local torso = RefEntity()
	local legs = RefEntity()
	local f = _CG.refdef.forward
	local ang = LocalPlayer():GetAngles()--VectorToAngles(f)
	local vlen = VectorLength(LocalPlayer():GetTrajectory():GetDelta())
	
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
	local hang = Vector(p,y,r)
	
	local delta = getDeltaAngle3(hang,headang)
	headang = vAdd(headang,vMul(delta,.2))
	headpos = head:GetPos()
	
	if(hp > 0) then skspin = Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10)) end
	if(hp > gibhp) then
		if(hp <= 0) then
			legs:Render()
			torso:Render()
			--head:Render()
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
end
hook.add("Draw3D","cl_viewtest",d3d)

local function bobview(pos,ang,fovx,fovy)
	if(!_CG) then return end
	local crd = _CG.refdef.right
	local vel = LocalPlayer():GetTrajectory():GetDelta()
	local lvel = VectorLength(vel)
	local cvel = Vectorv(vel)
	local nang = Vectorv(ang)
	local rvel = maxvel(DotProduct(vel,crd))
	cvel.z = 0
	plmoved = plmoved + vAbs(cvel)
	
	--nang.x = ang.x + (math.cos(VectorLength(plmoved)/2000)*1) * maxvel(lvel)
	--pos.z = pos.z + (math.cos(VectorLength(plmoved)/1000)*1) * maxvel(lvel)
	
	nang.z = nang.z - smoothvel*2
	nang.x = nang.x + (smoothfall/2)
	
	if(hp <= 0) then nang.z = nang.z + (30*ddir) else ddir = (math.random(0,1)*2)-1 end
	
	ang = nang
	
	--pos = vAdd(pos,vMul(crd,-20))
	
	local f = (maxvel(vel.z/2)*2) * 2
	
	smoothvel = smoothvel + (rvel - smoothvel)*.2
	smoothfall = smoothfall + (f - smoothfall)*.2
	
	if(hp <= 0) then
		ang = headang
		pos = headpos
	end
	look2 = look2 + (look - look2)*(.03*Lag())
	--ang.z = ang.z + 90

	--HEAD STUFF
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
		
		if(headtween == nil) then headtween = headang end
		
		pos = headpos
		ang = headtween
		ang = ang + look2
		
		pos = trAlong(pos,headang,10)
		pos = pos - VectorForward(headang)*8
		
		pos = trAlong(pos,ang,10)
		pos = pos - VectorForward(ang)*10
		
		pos = pos + VectorUp(ang)*8
		pos = pos + VectorUp(headang)*5
		
		headtween = headtween + (getDeltaAngle3(headang,headtween)*.2)
		
		--ang.z = ang.z - 25
	else
		look = Vector()
		headtween = nil
	end
	--DONE
	
	if(shake > 0) then
		pos = pos + _CG.refdef.right*(math.random(-shake*100,shake*100)/100)
		pos = pos + _CG.refdef.up*(math.random(-shake*100,shake*100)/100)
		shake = shake / (1 + (0.04 * Lag()))
		if(shake < .1) then shake = 0 end
		local r = shake*2
		if(r > 90) then r = 90 end
		if(r < -90) then r = -90 end
		ang.z = ang.z + (sdir * r)
		if(ang.z < -30) then ang.z = -30 end
		if(ang.z > 30) then ang.z = 30 end
	end
	
	ApplyView(pos,ang)
	
	if(lastTarget != LocalPlayer()) then
		hp = 100
		lastTarget = LocalPlayer()
	end
	--print("Set Ref\n")
end
hook.add("CalcView","cl_viewtest",bobview)

local function moused(x,y)
	look = vAdd(look,Vector(y/10,-x/10,0))
	if(look.x < -70) then look.x = -70 end
	if(look.x > 100) then look.x = 100 end
	
	if(look.y < -80) then look.y = -80 end
	if(look.y > 80) then look.y = 80 end
end
hook.add("MouseEvent","cl_viewtest",moused)

local function shakeIt(p,c,a)
	shake = shake + 5
	sdir = ddir
end
concommand.Add("shake",shakeIt)

local function respawn()
	hp = 100
end

local function processDamage(attacker,pos,dmg,death,waslocal,wasme,health)
	if(dmg > 50) then dmg = 50 end
	if(waslocal) then
		hp = health
		shake = shake + (dmg/3)
		sdir = ddir
	end
end

local function rvec(amt)
	return Vector(math.random(-amt,amt),math.random(-amt,amt),math.random(-amt,amt))
end

hook.add("Respawned","cl_viewtest",respawn)
hook.add("Damaged","cl_viewtest",processDamage)