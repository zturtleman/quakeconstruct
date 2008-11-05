local gibs = {
	LoadModel("models/gibs/abdomen.md3"),
	LoadModel("models/gibs/arm.md3"),
	LoadModel("models/gibs/arm.md3"),
	LoadModel("models/gibs/chest.md3"),
	LoadModel("models/gibs/fist.md3"),
	LoadModel("models/gibs/fist.md3"),
	LoadModel("models/gibs/foot.md3"),
	LoadModel("models/gibs/forearm.md3"),
	LoadModel("models/gibs/intestine.md3"),
	LoadModel("models/gibs/leg.md3"),
	LoadModel("models/gibs/leg.md3"),
	LoadModel("models/gibs/brain.md3"),
}

local explodeSound = LoadSound("sound/player/gibsplt1.wav")
local skull = LoadModel("models/gibs/skull.md3")
local inviso = LoadShader("teleporteffect2")
local flare = LoadShader("flareShader")
local bullet = LoadShader("bulletExplosion")
local blood1 = LoadShader("BloodMark") --viewBloodFilter_HQ
local blood2 = LoadShader("BloodMarkN2")
local blood3 = LoadShader("viewBloodFilter_HQ")
local gore = LoadShader("deadGore")
local i=0
local rpos = Vector(670,500,30)
local lastPos = Vector()
local bob = 0
local nxt = 0

local blood = {}
for i=1,5 do
	table.insert(blood,LoadShader("BloodMarkN" .. i))
end

local function rvel(a)
	return Vector(
	math.random(-a,a),
	math.random(-a,a),
	math.random(-a,a))
end

local particles = {}
local localents = {}
function newParticle(pos,dir,model,scale)
	--if(!flesh) then return end
	scale = scale or 1
	local r = RefEntity()
	r:SetModel(model)
	r:SetColor(1,1,1,1)
	--r:SetType() --RT_RAIL_CORE
	--r:SetType(RT_SPRITE)
	r:SetRadius(20*scale)
	r:SetRotation(math.random(360))
	--r:SetShader(gore)
	r:SetPos(pos)
	r:SetPos2(pos)
	r:SetAngles(Vector(math.random(360),math.random(360),math.random(360)))
	r:Scale(Vector(scale,scale,scale))
	
	dir.x = dir.x + (math.random(-10,10)/30)
	dir.y = dir.y + (math.random(-10,10)/30)
	dir.z = dir.z + (math.random(-10,10)/30)
	
	dir = vMul(dir,math.random(60,120)/60)

	local le = LocalEntity()
	le:SetPos(pos)
	le:SetRefEntity(r)
	le:SetVelocity(vMul(dir,300))
	le:SetStartTime(LevelTime())
	le:SetEndTime(LevelTime() + (6000) + math.random(1000,4000))
	le:SetType(LE_FRAGMENT)
	le:SetColor(1,.5,.3,1)
	le:SetRadius(r:GetRadius())
	le:SetCallback(LOCALENTITY_CALLBACK_TOUCH,function(le,tr)
		if(VectorLength(le:GetVelocity()) < 10 or math.random(0,2) == 1) then
			util.CreateMark(blood[math.random(1,#blood)],tr.endpos,tr.normal,math.random(360),1,1,1,1,math.random(30,60),true)
		end
		local ref = le:GetRefEntity()
		ref:SetAngles(Vector(math.random(360),math.random(360),math.random(360)))
		ref:Scale(Vector(scale,scale,scale))
		le:SetRefEntity(ref)
	end)
	le:SetCallback(LOCALENTITY_CALLBACK_THINK,function(le)
		if(VectorLength(le:GetVelocity()) > 3) then
			le:SetNextThink(LevelTime() + 100)
			--for i=0, 1 do
			local le2 = LocalEntity()
			le2:SetPos(le:GetPos())
			--le2:SetVelocity(rvel(200))
			local ref = le:GetRefEntity()
			--ref:Scale(Vector(.91,.91,.91))
			ref:SetRotation(math.random(360))
			le:SetRefEntity(ref)
			ref:SetColor(1,1,1,1)
			ref:SetType(RT_SPRITE)
			ref:SetShader(blood1)
			ref:SetRadius(30 + math.random(0,10))
			le2:SetRadius(30 + math.random(0,10))
			le2:SetRefEntity(ref)
			le2:SetStartTime(LevelTime())
			le2:SetEndTime(LevelTime() + 3000)
			le2:SetType(LE_FADE_RGB) --LE_FRAGMENT
			le2:SetColor(1,0,0,.4)
			le2:SetTrType(TR_STATIONARY)
		end
		--le2:SetTrType(TR_STATIONARY)
		--end
	end)
	
	local re = le:GetRefEntity()
	--AddLocalEntity(le);
	--table.insert(localents,le)
end

local function event(entity,event,pos,dir)
	if(event == EV_BULLET_HIT_WALL) then
		--newParticle(pos,entity:GetByteDir(),gibs[math.random(1,#gibs)])
	end
	if(event == EV_BULLET_HIT_FLESH) then
		newParticle(pos,vMul(entity:GetByteDir(),.2),gibs[math.random(1,#gibs)])
	end
	if(event == EV_GIB_PLAYER) then
		PlaySound(entity,explodeSound)
		newParticle(pos,Vector(0,0,1),skull,1.4)
		--for x=1, 2 do
			for i=1, #gibs do
				newParticle(pos,Vector(0,0,.4),gibs[i],1.2 + ((math.random(1,6))/20))
			end
		--end
		return true
	end
end
hook.add("EventReceived","cl_newgibs",event)