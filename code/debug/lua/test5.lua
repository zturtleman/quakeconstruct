local data = 
[[{
	{
		blendfunc add
		map $whiteimage
		alphaGen vertex
		rgbGen vertex
		//tcGen environment
	}
}]]
local trailfx1 = CreateShader("f",data)

local data = 
[[{
	{
		map $whiteimage
		alphaGen vertex
		rgbGen vertex
		//tcGen environment
	}
}]]
local trailfx2 = CreateShader("f",data)

local data = 
[[{
	{
		map gfx/misc/railcorethin_mono.tga
		blendfunc add
		alphaGen vertex
		rgbGen vertex
		//tcGen environment
	}
}]]
local trailfx3 = CreateShader("f",data)

local trailCache = {}
local posCache = {}
local healthCache = {}
local dtimers = {}

local function passTrail(trail) 
	--Pass the trail over to a local entity so the engine can render it out.
	local le = LocalEntity()
	le:SetPos(trail:GetPos())
	le:SetRefEntity(trail)
	le:SetVelocity(Vector(0,0,0))
	le:SetStartTime(LevelTime())
	le:SetEndTime(LevelTime() + 8000)
	
	
	local r,g,b,a = trail:GetColor()
	le:SetColor(r,g,b,1)
	le:SetRadius(trail:GetRadius())
	le:SetType(LE_FRAGMENT)
	le:SetTrType(TR_STATIONARY)
	
	le:SetCallback(LOCALENTITY_CALLBACK_THINK,function(le)
		local r = le:GetRefEntity()
		r:SetPos(r:GetPos())
		le:SetRefEntity(r)
		le:SetNextThink(LevelTime() + 40)
	end)
end

local function makeTrail(i,cr,cg,cb,ca)
	local r,g,b = hsv(math.random(360),1,1)
	local trail = RefEntity()
	trail:SetType(RT_TRAIL)
	trail:SetColor(cr or r,cg or g,cb or b,ca or 1)
	trail:SetRadius(4)
	trail:SetShader(trailfx1)
	trail:SetTrailLength(256)
	trail:SetTrailFade(FT_COLOR)
	trailCache[i] = trail
end

local function d3d()
	local players = GetAllPlayers()
	table.insert(players, LocalPlayer())
	for k,v in pairs(players) do
		local i = v:EntIndex()
		local trail = trailCache[i]
		local plpos = v:GetPos() - Vector(0,0,10)
		local health = v:GetInfo().health
		if(health > 0) then
			if(trail == nil) then
				makeTrail(i)
			else
				if(posCache[i] != nil) then
					if(VectorLength(posCache[i] - plpos) > 300) then
						passTrail(trail)
						makeTrail(i,trail:GetColor())
						trail = trailCache[i]
						posCache[i] = plpos
					end
				end
				if(healthCache[i] != nil and (healthCache[i] - health) > 1) then
					dtimers[i] = 10
				end
				if(dtimers[i] and dtimers[i] > 0) then
					local r,g,b,a = trail:GetColor()
					local trad = trail:GetRadius()
					local shd = trail:GetShader()
					trail:SetColor(dtimers[i]/10,0,0,1)
					trail:SetRadius(trad*8)
					trail:SetShader(trailfx3)
					trail:Render()
					trail:SetColor(r,g,b,a)
					trail:SetRadius(trad)
					trail:SetShader(shd)
					dtimers[i] = dtimers[i] - 1
				end
				trail:SetPos(plpos)
				trail:Render()
				posCache[i] = plpos
			end
		else
			if(trailCache[i] != nil) then
				local trail = trailCache[i]
				local r,g,b,a = trail:GetColor()
				trail:SetTrailLength(128)
				trail:SetRadius(trail:GetRadius() * 2)
				trail:SetShader(trailfx2)
				trail:SetTrailFade(FT_RADIUS)
				trail:SetColor(r/4,g/4,b/4,a/4)
				passTrail(trail)
				trailCache[i] = nil
			end
		end
		healthCache[i] = health
	end
end
hook.add("Draw3D","test5",d3d)