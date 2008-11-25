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

local function trDown(pos)
	local endpos = vAdd(pos,Vector(0,0,-1000))
	local res = TraceLine(pos,endpos,nil,1)
	return res
end

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
function newParticle(pos,dir,model,scale,skin,head)
	--if(!flesh) then return end
	local ex = 0
	if(head) then ex = 60000 end
	scale = scale or 1
	local r = RefEntity()
	r:SetModel(model)
	if(skin) then r:SetSkin(skin) end
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
	le:SetEndTime(LevelTime() + (6000 + ex) + math.random(1000,4000))
	le:SetType(LE_FRAGMENT)
	le:SetColor(1,.5,.3,1)
	le:SetRadius(r:GetRadius())
	le:SetAngleVelocity(Vector(math.random(-360,360),math.random(-360,360),math.random(-360,360)))
	le:SetCallback(LOCALENTITY_CALLBACK_TOUCH,function(le,tr)
		if(VectorLength(le:GetVelocity()) < 10 or math.random(0,2) == 1) then
			util.CreateMark(blood[math.random(1,#blood)],tr.endpos,tr.normal,math.random(360),1,1,1,1,math.random(30,60),true)
		end
		if(!le:GetTable().stopped) then
		local ref = le:GetRefEntity()
			ref:SetAngles(ref:GetAngles()) --Vector(math.random(360),math.random(360),math.random(360))
			ref:Scale(Vector(scale,scale,scale))
			le:SetRefEntity(ref)
			le:SetAngleVelocity(Vector(math.random(-360,360),math.random(-360,360),math.random(-360,360)))
		end
	end)
	le:SetCallback(LOCALENTITY_CALLBACK_THINK,function(le)
		if(VectorLength(le:GetVelocity()) > 3) then
			--[[if(head) then
				local ref = le:GetRefEntity()
				ref:SetAngles(ref:GetAngles() + Vector(10,50,30))
				ref:Scale(Vector(scale,scale,scale))
				le:SetRefEntity(ref)		
			end]]
			local ref = le:GetRefEntity()
			ref:SetAngles(ref:GetAngles())
			ref:Scale(Vector(scale,scale,scale))
			
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
			le2:SetEndTime(LevelTime() + 1000)
			le2:SetType(LE_FADE_RGB) --LE_FRAGMENT
			le2:SetColor(1,0,0,.4)
			le2:SetTrType(TR_STATIONARY)
		end
		--le2:SetTrType(TR_STATIONARY)
		--end
	end)
	
	le:SetCallback(LOCALENTITY_CALLBACK_STOPPED,function(le)
		le:GetTable().stopped = true
		le:SetAngleVelocity(Vector(0,0,0))
		if(head) then
			print("LE_STOPPED\n")
			local ref = le:GetRefEntity()
			local tr = trDown(le:GetPos())
			ref:SetAngles(Vector(math.random(-40,40),math.random(-60,60),math.random(-60,60)))
			ref:Scale(Vector(scale,scale,scale))
			le:SetRefEntity(ref)
			for i=0, 2 do
				util.CreateMark(blood[math.random(1,#blood)],tr.endpos,tr.normal,math.random(360),1,1,1,1,math.random(10,20),true,65000)
			end
		end
	end)
	
	--local re = le:GetRefEntity()
	--AddLocalEntity(le);
	--table.insert(localents,le)
end

local function event(entity,event,pos,dir)
	if(event == EV_BULLET_HIT_WALL) then
		--newParticle(pos,entity:GetByteDir(),gibs[math.random(1,#gibs)])
	end
	if(event == EV_BULLET_HIT_FLESH) then
		--newParticle(pos,vMul(entity:GetByteDir(),.2),gibs[5])
	end
	if(event == EV_GIB_PLAYER) then
		local vel = entity:GetTrajectory():GetDelta()/500
		PlaySound(entity,explodeSound)
		
		local mdl = entity:GetInfo().headModel or skull
		local skin = entity:GetInfo().headSkin
		
		local torso = entity:GetInfo().torsoModel or skull
		local torsoskin = entity:GetInfo().torsoSkin
		
		local legs = entity:GetInfo().legsModel or skull
		local legsskin = entity:GetInfo().legsSkin
		
		newParticle(pos,Vector(0,0,1.2) + vel,mdl,1.4,skin,true)
		if(math.random(0,1) == 1) then
			newParticle(pos+Vector(0,0,20) + vel,Vector(0,0,.2),torso,1,torsoskin,false)
		else
			newParticle(pos,Vector(0,0,.2) + vel,legs,1,legsskin,false)
		end
		--for x=1, 2 do
			for i=1, #gibs do
				newParticle(pos,Vector(0,0,.4) + vel,gibs[i],1.2 + ((math.random(1,6))/20))
			end
		--end
		return true
	end
end
hook.add("EventReceived","cl_newgibs",event)