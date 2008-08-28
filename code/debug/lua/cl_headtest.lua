local inf = LocalPlayer():GetInfo()
local flash = LoadShader("viewBloodBlend")

--local skull = LoadModel("models/gibs/skull.md3")
local skull = inf.headModel
local skin = inf.headSkin
local mins,maxs = render.ModelBounds(skull)
local ref = RefEntity()
local ref2 = RefEntity()
local origin = Vector()
local DAMAGE_TIME = 500
local ICON_SIZE = 100

ref:SetModel(skull)
ref:SetSkin(skin)

origin.x = 2.2 * ( maxs.x - mins.x);
origin.y = 0.5 * ( mins.y + maxs.y );
origin.z = -0.5 * ( mins.z + maxs.z );

--print(mins.x .. ", " ..  mins.y .. ", " .. mins.z .. "\n")

ref:SetPos(origin)

ref2:SetPos(Vector(10,0,0))
ref2:SetType(RT_SPRITE)
ref2:SetRadius(5)
ref2:SetShader(flash)

local a = 0
local headStartYaw = 0
local headEndYaw = 0
local headStartPitch = 0
local headEndPitch = 0
local headStartTime = 0
local headEndTime = 0

local function draw2D()
	local y = 0
	local x = 0
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

			headEndYaw = 180 + 20 * math.cos( math.random()*math.pi );
			headEndPitch = 5 * math.cos( math.random()*math.pi );
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

	a = a + 1
	if(a > 360) then a = 0 end
	render.CreateScene()
	if(delta < DAMAGE_TIME) then
		ref2:SetColor(1,1,1,1-(delta/DAMAGE_TIME))
		ref2:Render()
		ref2:Render()
	end
	ref:SetAngles(angles)
	ref:Render()
	render.RenderScene(x,y,size,size)
end
hook.add("Draw2D","cl_init",draw2D)

local function newClientInfo(newinfo)
	skull = newinfo.headModel
	skin = newinfo.headSkin
	ref:SetModel(skull)
	ref:SetSkin(skin)
	mins,maxs = render.ModelBounds(skull)
	
	origin.x = 2.2 * ( maxs.x - mins.x);
	origin.y = 0.5 * ( mins.y + maxs.y );
	origin.z = -0.5 * ( mins.z + maxs.z );

	--print(mins.x .. ", " ..  mins.y .. ", " .. mins.z .. "\n")

	ref:SetPos(origin)
end
hook.add("ClientInfoLoaded","cl_init",newClientInfo)