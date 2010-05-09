local flare = LoadShader("flareShader")

local function trDown(pos)
	local endpos = vAdd(pos,Vector(0,0,-1000))
	local res = TraceLine(pos,endpos,nil,1)
	return res.endpos
end

local identity = Vector(1,1,1)

local function r()
	local rx = math.random(0,3)
	if(rx == 1) then
		return 1
	else
		return 0
	end
end

local function RefFlare(pos)
	local fl = RefEntity()
	fl:SetShader(flare)
	fl:SetColor(r(),r(),r(),1)
	fl:SetRadius(math.random(32,64))	
	fl:SetPos(pos)
	fl:SetType(RT_SPRITE)
	fl:Render()
end

local function drawPlayer(v)
	local pos = v:GetPos()
	local ang = v:GetAngles()
	local vlen = VectorLength(v:GetTrajectory():GetDelta())
	
	local head = RefEntity()
	local torso = RefEntity()
	local legs = RefEntity()

	util.AnimatePlayer(v,legs,torso)
	util.AnglePlayer(v,legs,torso,head)
	
	pos.z = pos.z - 2
	
	--legs:SetAngles(ang)
	legs:SetPos(pos) --Vector(652,1872,24)
	legs:SetColor(1,1,1,1)
	legs:SetModel(v:GetInfo().legsModel)
	legs:SetSkin(v:GetInfo().legsSkin)
	legs:Scale(Vector(1,1,1))
	
	torso:SetModel(v:GetInfo().torsoModel)
	torso:SetSkin(v:GetInfo().torsoSkin)
	
	head:SetModel(v:GetInfo().headModel)
	head:SetSkin(v:GetInfo().headSkin)

	--local f,r,u = AngleVectors(torso:GetAngles())
	torso:Scale(Vector(4,4,4))
	torso:PositionOnTag(legs,"tag_torso")
	
	--head:Scale(Vector(2,2,1.5))
	head:Scale(Vector(.5,.5,.5))
	head:PositionOnTag(torso,"tag_torso")

	legs:Render()
	--torso:Render()
	head:Render()
	
	RefFlare(torso:GetPos())
	--[[for i=0, 1 do
		local f,r,u = head:GetAngles()
		local dp = vMul(u,12)
		head:SetPos(vAdd(head:GetPos(),dp))
		head:Scale(Vector(1.1,1.1,1.1))
		head:Render()
		RefFlare(head:GetPos())
	end]]	
end

local function d3d()
	local tab = GetEntitiesByClass("player")
	for k,v in pairs(tab) do
		v:CustomDraw(true)
		drawPlayer(v)
	end
end
hook.add("Draw3D","cl_funkyplayers",d3d)