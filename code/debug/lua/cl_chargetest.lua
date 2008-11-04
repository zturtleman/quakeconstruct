local lerp = 0
local lp = Vector(652,1872,28)
local seq = Sequence(0,50)
local start = LevelTime()
local delay = (1000*seq:GetLength())/20 --1 Second * Number Of Frames / Frames Per Second
local endt = LevelTime() + delay 
local charger = LoadModel("models/misc/healthcharger.md3")
local medsphere = LoadModel("models/powerups/health/medium_sphere.md3")
local smallcross = LoadModel("models/powerups/health/small_cross.md3")

local ref = RefEntity()
ref:SetModel(charger)
ref:SetPos(lp)

local ball = RefEntity()
ball:SetModel(medsphere)
ball:SetPos(lp)

local plus = RefEntity()
plus:SetModel(smallcross)

charger_pos = charger_pos or Vector(0,0,0)
charger_normal = charger_normal or Vector(0,0,0)

local pos = charger_pos
local normal = charger_normal

local function trForward(pos,dir)
	local endpos = vAdd(pos,vMul(dir,10000))
	local res = TraceLine(pos,endpos,nil,1)
	return res.endpos,res.normal
end

local function d3d()
	local tw = (endt - LevelTime()) / delay
	lerp = 1-tw
	
	if(lerp > 1) then 
		start = LevelTime()
		delay = (1000*seq:GetLength())/20
		endt = LevelTime() + delay 	
	end
	seq:SetRef(ref)
	seq:SetLerp(lerp)
	
	--local pos,normal = trForward(_CG.viewOrigin,_CG.refdef.forward)
	local ang = VectorToAngles(normal)
	local c = 1 - lerp --(math.random(0,50)/100)+.5
	ang.x = ang.x + 90
	ref:SetPos(pos)
	ref:SetAngles(ang)
	ref:Scale(Vector(.4,.4,.4))
	ref:SetColor(c,c,c,1)
	
	local f,r,u = AngleVectors(ang)
	ball:PositionOnTag(ref,"tag_ball")
	local center = ball:GetPos()
	center = vAdd(center,vMul(u,.4))
	center = vAdd(center,vMul(f,1.5))

	ball:SetPos(center)
	ball:SetAngles(Vector(0,0,0))
	ball:Scale(Vector(.3,.3,.3))
	
	--center = vAdd(center,vMul(u,-1))
	ang.x = ang.x - 90
	center.z = center.z + lerp*1.2
	plus:SetPos(center)
	plus:SetAngles(ang)
	plus:Scale(vMul(Vector(.3,.3,.3),1-lerp))
	
	ref:Render()
	ball:Render()
	plus:Render()
end
hook.add("Draw3D","cl_chargetest",d3d)

local function used(t)
	if(t) then
		charger_pos,charger_normal = trForward(_CG.viewOrigin,_CG.refdef.forward)
		pos = charger_pos
		normal = charger_normal
	end
end
hook.add("Use","cl_chargetest",used)