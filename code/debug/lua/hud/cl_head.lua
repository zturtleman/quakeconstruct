local inf = LocalPlayer():GetInfo()
local blood1 = LoadShader("viewBloodFilter_HQ")
local blood2 = LoadShader("dissolve")

local skull = LoadModel("models/gibs/skull.md3")
local head = inf.headModel
local skin = inf.headSkin
local mins,maxs = render.ModelBounds(head)
local ref = RefEntity()
local ref2 = RefEntity()
local DAMAGE_TIME = 800
local headOrigin = Vector()

ref:SetModel(head)
ref:SetSkin(skin)
ref2:SetModel(head)
ref2:SetShader(blood1)

function positionHead()
	mins,maxs = render.ModelBounds(ref:GetModel())

	headOrigin.x = 2.2 * ( maxs.x - mins.x);
	headOrigin.y = 0.5 * ( mins.y + maxs.y );
	headOrigin.z = -0.5 * ( mins.z + maxs.z );
end

positionHead()

local headStartYaw = 0
local headEndYaw = 0
local headStartPitch = 0
local headEndPitch = 0
local headStartTime = 0
local headEndTime = 0
local deadFrac = 0
local dz = -1 + (2*math.random())
function drawHead(x,y,ICON_SIZE,hp)
	local frac = 0
	local size = 0
	local stretch = 0
	local damageTime = _CG.damageTime
	local ltime = LevelTime()
	local damageX = _CG.damageX
	local damageY = _CG.damageY
	local delta = (ltime - damageTime)
	local angles = Vector(0,0,0)
	if(delta < DAMAGE_TIME) then
		frac = delta / DAMAGE_TIME
		size = ICON_SIZE * 1.25 * ( 1.5 - frac * 0.5 );
		
		stretch = size - ICON_SIZE * 1.25;
		x = x - stretch * 0.5 + damageX * stretch * 0.5;
		y = y - stretch * 0.5 + damageX * stretch * 0.5;
		
		headStartYaw = 180 + damageX * 45;
		
		headEndYaw = 180 + 20 * math.cos( math.random()*math.pi );
		headEndPitch = 5 * math.cos( math.random()*math.pi );

		headStartTime = ltime;
		headEndTime = ltime + 100 + math.random() * 2000;
	else
		if ( ltime >= headEndTime ) then
			headStartYaw = headEndYaw;
			headStartPitch = headEndPitch;
			headStartTime = headEndTime;
			headEndTime = ltime + 100 + math.random() * 2000;

			if(deadFrac > 0) then
				headStartTime = ltime;
				headEndTime = ltime + 50 + math.random() * 500;
			end
			
			headEndYaw = 180 + 20 * math.cos( math.random()*math.pi );
			headEndPitch = 5 * math.cos( math.random()*math.pi );
			
			if(deadFrac > 0) then
				headEndYaw = 180 + 60 * math.cos( math.random()*math.pi );
				headEndPitch = 40 * math.cos( math.random()*math.pi );
			end
		end

		size = ICON_SIZE * 1.25;
	end
	
	if ( headStartTime > ltime ) then
		headStartTime = ltime;
	end
	
	frac = ( ltime - headStartTime ) / ( headEndTime - headStartTime );
	frac = frac * frac * ( 3 - 2 * frac );
	angles.y = headStartYaw + ( headEndYaw - headStartYaw ) * frac;
	angles.x = headStartPitch + ( headEndPitch - headStartPitch ) * frac;

	render.CreateScene()
	
	if(hp <= 0) then
		if(dz > 0) then dz = 1 end
		if(dz <= 0) then dz = -1 end
		angles.y = angles.y - (angles.y - 180)*deadFrac
		angles.x = angles.x - (angles.x - 30)*deadFrac
		angles.z = 13*dz
		if(deadFrac == 0) then
			headStartPitch = -50
			headStartTime = ltime;
			headEndPitch = -30
			headEndTime = ltime+200;
		end
		deadFrac = deadFrac + 0.008
		if(deadFrac > 1) then deadFrac = 1 end
	else
		dz = -1 + (2*math.random())
		deadFrac = 0
	end

	local hpx = (1-(math.min(math.max(hp/100,0),1)/5)) - 0.3
	if(hp >= 100) then 
		hpx = 0
	end
	ref2:SetColor(1,1,1,hpx)	
	if(delta < DAMAGE_TIME or hp <= 0) then
		local i = hpx + ((1-(delta/DAMAGE_TIME))/18)
		if(i < hpx) then i=hpx end
		if(i > 1) then i=1 end
		ref2:SetColor(1,1,1,i)
		if(hp <= 0) then ref2:SetColor(1,1,1,1) end
		if(hp <= -40) then
			if(ref:GetModel() != skull) then
				ref:SetModel(skull)
				ref:SetSkin(0)
				ref2:SetModel(skull)
				positionHead()
			end
		end
	elseif(ref:GetModel() == skull) then
		ref:SetModel(head)
		ref:SetSkin(skin)
		ref2:SetModel(head)
		positionHead()
	end
	ref:SetPos(Vector(0,headOrigin.y,headOrigin.z))
	ref2:SetPos(Vector(0,headOrigin.y,headOrigin.z))
	
	ref:Render()
	ref2:SetShader(blood1)
	ref2:Render()
	ref2:SetShader(blood2)
	ref2:Render()
	
	local forward = VectorForward(angles)
	
	local refdef = {}
	refdef.x = x
	refdef.y = y
	refdef.width = size
	refdef.height = size
	refdef.origin = vMul(forward,-headOrigin.x)
	local aim = VectorNormalize(refdef.origin)
	aim = vMul(aim,-1)
	aim = VectorToAngles(aim)
	aim.z = angles.z
	
	refdef.angles = aim
	render.RenderScene(refdef)
end

local function newClientInfo(newinfo)
	head = newinfo.headModel
	skin = newinfo.headSkin
	ref:SetModel(head)
	ref:SetSkin(skin)
	ref2:SetModel(head)
	
	positionHead()
end
hook.add("ClientInfoLoaded","cl_init",newClientInfo)