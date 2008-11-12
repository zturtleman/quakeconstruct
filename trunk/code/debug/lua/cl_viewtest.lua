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
local hp = 100

local function maxvel(v)
	return math.min(math.max(v,-320),320)/320;
end

local function bobview(pos,ang,fovx,fovy)
	if(!_CG) then print("^1NO CG!\n") return end
	local crd = _CG.refdef.right
	local vel = LocalPlayer():GetTrajectory():GetDelta()
	local lvel = VectorLength(vel)
	local cvel = Vectorv(vel)
	local nang = Vectorv(ang)
	local rvel = maxvel(DotProduct(vel,crd))
	cvel.z = 0
	plmoved = plmoved + vAbs(cvel)
	
	nang.x = ang.x + (math.cos(VectorLength(plmoved)/2000)*1) * maxvel(lvel)
	pos.z = pos.z + (math.cos(VectorLength(plmoved)/1000)*1) * maxvel(lvel)
	
	nang.z = nang.z - smoothvel*5
	nang.x = nang.x + smoothfall
	
	if(hp <= 0) then nang.z = nang.z + (30*ddir) else ddir = (math.random(0,1)*2)-1 end
	
	ang = nang
	
	--pos = vAdd(pos,vMul(crd,-20))
	
	local f = (maxvel(vel.z/2)*2) * 2
	
	smoothvel = smoothvel + (rvel - smoothvel)*.2
	smoothfall = smoothfall + (f - smoothfall)*.2
	
	ApplyView(pos,ang)
	
	if(lastTarget != LocalPlayer()) then
		hp = 100
		lastTarget = LocalPlayer()
	end
	--print("Set Ref\n")
end
hook.add("CalcView","cl_viewtest",bobview)

local function respawn()
	hp = 100
end

local function processDamage(attacker,pos,dmg,death,waslocal,wasme,health)
	if(waslocal) then
		hp = health
	end
end

local function rvec(amt)
	return Vector(math.random(-amt,amt),math.random(-amt,amt),math.random(-amt,amt))
end

hook.add("Respawned","cl_viewtest",respawn)
hook.add("Damaged","cl_viewtest",processDamage)