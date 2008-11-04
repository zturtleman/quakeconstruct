local flare = LoadShader("flareShader")
local fx = LoadShader("railCore")
local function getBeamRef(v1,v2,r,g,b)
	local st1 = RefEntity()
	st1:SetType(RT_RAIL_CORE)
	st1:SetPos(v1)
	st1:SetPos2(v2)
	st1:SetColor(r,g,b,1)
	st1:SetRadius(12)
	st1:SetShader(fx)
	return st1
end

local function qbeam(v1,v2,r,g,b)
	local ref = getBeamRef(v1,v2,r,g,b)
	local le = LocalEntity()
	le:SetPos(v1)
	
	le:SetRefEntity(ref)
	le:SetRadius(ref:GetRadius())
	le:SetStartTime(LevelTime())
	le:SetEndTime(LevelTime() + 1000)
	le:SetType(LE_FADE_RGB) --LE_FRAGMENT
	le:SetColor(r,g,b,1)
	le:SetTrType(TR_STATIONARY)
end

local function qpoint(ref,r,g,b)
	local le = LocalEntity()
	le:SetPos(ref:GetPos())	
	le:SetRefEntity(ref)
	le:SetRadius(ref:GetRadius())
	le:SetStartTime(LevelTime())
	le:SetEndTime(LevelTime() + 1000)
	le:SetType(LE_FADE_RGB) --LE_FRAGMENT
	le:SetColor(r,g,b,1)
	le:SetTrType(TR_STATIONARY)
end

local nextTrail = LevelTime()

local function UnlinkEntity(ent)
	if(ent != nil and ent:GetWeapon() == WP_ROCKET_LAUNCHER) then
		local base = ent:GetTable().mybase
		if(base != nil) then
			qbeam(base,ent:GetPos(),1,1,1)
		end
	end
end

local function LinkEntity(ent)
	if(ent != nil and ent:Classname() == "missile" and ent:GetWeapon() == WP_ROCKET_LAUNCHER) then
		ent:GetTable().mybase = ent:GetTrajectory():GetBase() or ent:GetPos()
	end
end

local function d3d()
	local tab = GetEntitiesByClass("missile")
	for k,v in pairs(tab) do
		if(v != nil and v:GetWeapon() == WP_ROCKET_LAUNCHER) then
			v:CustomDraw(true)
			local s = RefEntity()
			s:SetType(RT_SPRITE)
			s:SetPos(v:GetPos())
			s:SetColor(1,.7,0,1)
			s:SetRadius(22)
			s:SetShader(flare)
			s:Render()
			
			s:SetColor(1,.3,0,1)
			s:SetRadius(12)
			s:Render()
			
			local base = v:GetTrajectory():GetBase()
			if(v:GetTable()) then
				base = v:GetTable().mybase or v:GetTrajectory():GetBase()
			end
			if(base != nil) then
				getBeamRef(base,v:GetPos(),1,1,1):Render()
			end
		end
	end
	
	--[[if(nextTrail < LevelTime()) then
		for k,v in pairs(tab) do
			if(v != nil and v:GetWeapon() == WP_ROCKET_LAUNCHER) then
				local base = v:GetTrajectory():GetBase()
				qbeam(base,v:GetPos(),1,1,1)
			end
		end
		nextTrail = LevelTime() + 40
	end]]
end
hook.add("Draw3D","cl_coolrockets",d3d)
hook.add("EntityUnlinked","cl_coolrockets",UnlinkEntity)
hook.add("EntityLinked","cl_coolrockets",LinkEntity)