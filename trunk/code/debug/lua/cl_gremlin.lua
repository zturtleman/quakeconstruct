local ghead = LoadModel("models/players/sorlag/head.md3")
local gtorso = LoadModel("models/players/sorlag/upper.md3")
local glegs = LoadModel("models/players/sorlag/lower.md3")

local headskin = util.LoadSkin("models/players/sorlag/head_default.skin")
local torsoskin = util.LoadSkin("models/players/sorlag/upper_default.skin")
local legskin = util.LoadSkin("models/players/sorlag/lower_default.skin")

local torsosub = 156 - 94 --Subtract these frames
local leganim = Animation(173 - torsosub,17,20)
leganim:SetType(ANIM_ACT_LOOP_LERP)
local lx = 0
local speed = .32
local legs = RefEntity()
legs:SetModel(glegs)
legs:SetSkin(legskin)
leganim:SetRef(legs)

local torso = RefEntity()
torso:SetModel(gtorso)
torso:SetSkin(torsoskin)
torso:SetFrame(156)

local head = RefEntity()
head:SetModel(ghead)
head:SetSkin(headskin)

local function trDown(pos)
	local endpos = vAdd(pos,Vector(0,0,-1000))
	local res = TraceLine(pos,endpos,nil,1)
	return res.endpos
end

local function d3d()
	local look = math.sin(LevelTime()/400)*20
	
	lx = lx + speed
	
	if(lx > 500) then speed = speed * -1 end
	if(lx < -400) then speed = speed * -1 end
	
	local lp = Vector(652,1872,34)
	lp.x = lp.x + lx
	
	lp.z = trDown(lp).z
	lp.z = lp.z + 10
	
	--LEGS------------------------------------------------------------------------------------
	legs:SetPos(lp)
	
	--Scaling works relative so set angles to reset scale
	legs:SetAngles(Vector(0,0,0))
	if(speed < 0) then
		legs:SetAngles(Vector(0,180,0))
	end
	
	legs:Scale(Vector(.4,.4,.4))
	legs:Render()
	
	--TORSO------------------------------------------------------------------------------------
	torso:PositionOnTag(legs,"tag_torso")
	
	if(speed < 0) then
		torso:SetAngles(Vector(0,look+180),0)
	else
		torso:SetAngles(Vector(0,look,0))
	end
	
	torso:Scale(Vector(.6,.6,.6))
	torso:Render()
	
	--HEAD-----------------------------------------------------------------------------------
	head:PositionOnTag(torso,"tag_head")
	
	if(speed < 0) then
		head:SetAngles(Vector(0,(look*2)+180),0)
	else
		head:SetAngles(Vector(0,(look*2),0))
	end
	
	head:Scale(Vector(.8,.8,.8))
	head:Render()
	
	--ANIMATION--------------------------------------------------------------------------------
	leganim:Animate()
end
hook.add("Draw3D","cl_init",d3d)