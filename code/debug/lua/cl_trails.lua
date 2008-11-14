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

local function rpoint(pos)
	local s = RefEntity()
	s:SetType(RT_SPRITE)
	s:SetPos(pos)
	s:SetColor(1,1,1,1)
	s:SetRadius(12)
	s:SetShader(flare)
	return s
end

local function qbeam(v1,v2,r,g,b,point)
	local ref = getBeamRef(v1,v2,r,g,b)
	local le = LocalEntity()
	le:SetPos(v1)
	
	le:SetRefEntity(ref)
	if(point) then le:SetRefEntity(rpoint(v1)) end
	le:SetRadius(ref:GetRadius())
	le:SetStartTime(LevelTime())
	le:SetEndTime(LevelTime() + 2000)
	le:SetType(LE_FADE_RGB)
	--if(point) then le:SetType(LE_FRAGMENT) end --LE_FRAGMENT
	le:SetColor(r,g,b,1)
	le:SetTrType(TR_STATIONARY)
end

local healthvals = {}
local nexttrail = LevelTime()
local function trailent(v)
	if(v != nil) then
		local hue = LevelTime()/5
		local t = v:GetTable()
		local team = v:GetInfo().team
		local hpx = nil
		if(t != nil) then
			t.lastpos = t.lastpos or v:GetPos()
			if(v.EntIndex) then hpx = healthvals[v:EntIndex()] end
			local hp = (hpx or v:GetInfo().health) / 100
			if(hp > 1) then hp = 1 end
			if(hp < 0) then hp = 0 end
			
			hue = hp * 120
			
			local st1 = nil
			if(team == TEAM_RED) then
				st1 = getBeamRef(v:GetPos(),t.lastpos,1,0,0)
			elseif(team == TEAM_BLUE) then
				st1 = getBeamRef(v:GetPos(),t.lastpos,0,0,1)
			elseif(team == TEAM_FREE) then
				st1 = getBeamRef(v:GetPos(),t.lastpos,hsv(hue,1,1))
			end
			if(st1 != nil) then
				st1:Render()
			end


			if(nexttrail < LevelTime()) then
				if(team == TEAM_RED) then
					qbeam(v:GetPos(),t.lastpos,1,0,0)
					qbeam(v:GetPos(),t.lastpos,1,0,0,true)
				elseif(team == TEAM_BLUE) then
					qbeam(v:GetPos(),t.lastpos,0,0,1)
					qbeam(v:GetPos(),t.lastpos,0,0,1,true)
				elseif(team == TEAM_FREE) then
					qbeam(v:GetPos(),t.lastpos,hsv(hue,1,1,false))
					qbeam(v:GetPos(),t.lastpos,hsv(hue,1,1,true))
				end
				t.lastpos = v:GetPos()
			end
		end
	end
end

local lpx = {tab = {}}

function lpx:GetTable()
	return self.tab
end

function lpx:GetPos()
	local p = _CG.viewOrigin
	p.z = LocalPlayer():GetPos().z
	return p
end

function lpx:GetInfo()
	return LocalPlayer():GetInfo()
end


local function d3d()
	local tab = GetEntitiesByClass("player")
	--table.insert(tab,LocalPlayer())
	for k,v in pairs(tab) do
		trailent(v)
	end
	trailent(lpx)
	if(nexttrail < LevelTime()) then
		nexttrail = LevelTime() + 100
	end
end
hook.add("Draw3D","cl_trails",d3d)

local function processDamage(self,attacker,pos,dmg,death,waslocal,wasme,hp,id)
	healthvals[id] = hp
end

local function respawn(self,id)
	print("Player Respawned\n")
	healthvals[id] = 100
end
hook.add("PlayerDamaged","cl_trails",processDamage)
hook.add("PlayerRespawned","cl_trails",respawn)