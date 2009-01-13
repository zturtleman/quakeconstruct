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

local function maxvel(v)
	return math.min(math.max(v,-320),320)/320;
end

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
		ang.p = ang.p - look2.y
		ang.y = ang.y + look2.x
	else
		look = Vector()
	end
	look2 = look2 + (look - look2)*(.03*Lag())
	--ang.z = ang.z + 90
	
	if(shake > 0) then
		pos = pos + _CG.refdef.right*(math.random(-shake*100,shake*100)/100)
		pos = pos + _CG.refdef.up*(math.random(-shake*100,shake*100)/100)
		shake = shake / (1 + (0.07 * Lag()))
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
	look = vAdd(look,Vector(-x/10,-y/10,0))
end
hook.add("MouseEvent","cl_legtest",moused)

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