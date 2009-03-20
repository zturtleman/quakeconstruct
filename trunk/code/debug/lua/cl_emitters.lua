local flare = LoadShader("flareShader")

local function rvel(a)
	return Vector(
	math.random(-a,a),
	math.random(-a,a),
	math.random(-a,a))
end

local ref = RefEntity()
	ref:SetColor(1,1,1,1)
	ref:SetType(RT_SPRITE)
	ref:SetShader(flare)
	
local function newParticle(pos,indir,freeze)
	scale = scale or 1
	
	ref:SetRadius(math.random(5,10)*scale)
	ref:SetRotation(math.random(360))
	ref:SetPos((rvel(2000) * .01) + pos)

	local le = LocalEntity()
	le:SetPos(pos)
	le:SetRefEntity(ref)
	le:SetStartTime(LevelTime())
	le:SetEndTime(LevelTime() + (800) + math.random(300,800))
	le:SetType(LE_FRAGMENT)
	le:SetColor(1,1,1,1)
	le:SetEndColor(0,0,0,0)
	le:Emitter(LevelTime(), LevelTime() + 600, 1, 
	function(le2,frac)
		local dir = Vector(indir.x,indir.y,indir.z)
		dir.x = dir.x + (math.random(-10,10)/30)
		dir.y = dir.y + (math.random(-10,10)/30)
		dir.z = dir.z + (math.random(-10,10)/30)
		
		print("EMIT : " .. frac .. "\n")
		
		dir = dir * (math.random(100,200))	
		le2:SetVelocity(dir)
		le2:SetRadius(ref:GetRadius() * (1-frac))
	end)
end

local function particleTest()
	local pos = PlayerTrace().endpos
	newParticle(pos + Vector(0,0,30),Vector(0,0,1),false)
end
concommand.add("ptest",particleTest)