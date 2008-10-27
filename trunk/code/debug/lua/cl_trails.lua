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

local nexttrail = LevelTime()
local function d3d()
	local tab = GetEntitiesByClass("player")
	table.insert(tab,LocalPlayer())
	for k,v in pairs(tab) do
		if(v != nil) then
			local t = v:GetTable()
			local team = v:GetInfo().team
			if(t != nil) then
				t.lastpos = t.lastpos or v:GetPos()
				if(nexttrail < LevelTime()) then
					if(team == TEAM_RED) then
						qbeam(v:GetPos(),t.lastpos,1,0,0)
					elseif(team == TEAM_BLUE) then
						qbeam(v:GetPos(),t.lastpos,0,0,1)
					elseif(team == TEAM_FREE) then
						qbeam(v:GetPos(),t.lastpos,1,1,.2)
					end
					t.lastpos = v:GetPos()
				else
					local st1 = nil
					if(team == TEAM_RED) then
						st1 = getBeamRef(v:GetPos(),t.lastpos,1,0,0)
					elseif(team == TEAM_BLUE) then
						st1 = getBeamRef(v:GetPos(),t.lastpos,0,0,1)
					elseif(team == TEAM_FREE) then
						st1 = getBeamRef(v:GetPos(),t.lastpos,1,1,.2)
					end
					if(st1 != nil) then
						st1:Render()
					end
				end
			end
		end
	end
	if(nexttrail < LevelTime()) then
		nexttrail = LevelTime() + 100
	end
end
hook.add("Draw3D","cl_init",d3d)