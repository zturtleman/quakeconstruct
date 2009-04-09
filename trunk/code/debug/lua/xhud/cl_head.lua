local inf = LocalPlayer():GetInfo()
local blood1 = LoadShader("dissolve2_mul")
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

	headOrigin.x = 2.5 * ( maxs.x - mins.x);
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
local dz = math.random(-1,1)
local timex = 0
local lct = CurTime()
local mvz = 0
local nalpha = 0
local calpha = 0
local calpha2 = 0
function DrawHead(x,y,ICON_SIZE,hp)
	local inf = LocalPlayer():GetInfo()
	local nhead = inf.headModel
	local nskin = inf.headSkin
	if(nhead != head or nskin != skin) then
		ref:SetModel(nhead)
		ref:SetSkin(nskin)
		ref2:SetModel(nhead)
		
		skin = nskin
		head = nhead
		
		positionHead()
	end

	local frac = 0
	local size = 0
	local stretch = 0
	local damageTime = _CG.damageTime
	local ltime = LevelTime()
	local damageX = _CG.damageX
	local damageY = _CG.damageY
	local delta = (ltime - damageTime)
	local angles = Vector()
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

			local hpx = (math.min(math.max(hp/100,.1),1))
			
			if(deadFrac > 0) then
				headStartTime = ltime;
				headEndTime = ltime + 50 + math.random() * 500;
			else
				headEndTime = headEndTime + (1-hpx)*800
			end
			
			headEndYaw = 180 + (20 * math.cos( math.random()*math.pi ))*hpx;
			headEndPitch = (5 * math.cos( math.random()*math.pi ))*hpx;
			
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
		dz = math.random(-1,1)
		deadFrac = 0
	end

	local hpx = (1-(math.min(math.max(hp/100,0),1)/5)) - 0.3
	if(hpx < 0) then 
		hpx = 0
	end
	nalpha = hpx
	if(delta < DAMAGE_TIME or hp <= 0) then
		local i = hpx + ((1-(delta/DAMAGE_TIME))/18)
		if(i < hpx) then i=hpx end
		if(i > 1) then i=1 end
		nalpha = i
		if(hp <= 0) then nalpha = 1 end
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
	
	local hp2x = math.min(math.max(hp/100,0),1)
	local na2 = math.min((hp2x/3) + .6,1)
	
	calpha = nalpha --calpha + (nalpha - calpha)*.01
	calpha2 = na2 --calpha2 + (na2 - calpha2)*.01
	if(calpha < 0.5) then calpha = 0.5 end
	
	ref:Render()
	ref2:SetColor(1,.2,.2,calpha2)
	ref2:SetShader(blood1)
	ref2:Render()
	ref2:SetColor(1,1,1,calpha)
	ref2:SetShader(blood2)
	ref2:Render()
	
	if(hp > 100) then hp = 100 end
	if(hp > 0) then
		local hp2 = (1-(hp/200))
		timex = timex + (CurTime() - lct) * ((hp2) * math.random(20,30)/5)
		
		angles.x = angles.x + (1-(hp/100))*30

		angles.x = angles.x + math.cos(timex)*(1-(hp/70))*6
		angles.z = angles.z + math.sin(timex/3)*(1-(hp/70))*4
		
		mvz = math.cos(timex)*(1-(hp/100))*.7
	end
	
	local forward = VectorForward(angles)
	
	local refdef = {}
	refdef.flags = 1
	refdef.x = x
	refdef.y = y
	refdef.width = size
	refdef.height = size
	refdef.origin = vMul(forward,-headOrigin.x)
	local aim = VectorNormalize(refdef.origin)
	aim = vMul(aim,-1)
	aim = VectorToAngles(aim)
	aim.z = angles.z
	
	refdef.origin.z = refdef.origin.z + mvz
	
	refdef.angles = aim
	local b, e = pcall(render.RenderScene,refdef)
	if(!b) then
		print("^1" .. e .. "\n")
	end
	lct = CurTime()
end

--[[local function newClientInfo(newinfo,entity)
	if(entity:IsClient()) then
		if(entity == LocalPlayer()) then
			print("Conditions Passed\n")
			local inf = LocalPlayer():GetInfo()
			head = inf.headModel
			skin = inf.headSkin
			ref:SetModel(head)
			ref:SetSkin(skin)
			ref2:SetModel(head)
			
			positionHead()
		end
	end
end
hook.add("ClientInfoLoaded","cl_head",newClientInfo)]]