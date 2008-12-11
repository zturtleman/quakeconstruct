local explosions = {}

message.Precache("explosion")

local function sendExplosion(e)
	local msg = Message()
	message.WriteVector(msg,e.pos)
	message.WriteLong(msg,e.radius)
	message.WriteLong(msg,e.startTime)
	message.WriteLong(msg,e.endTime)
	for k,v in pairs(GetEntitiesByClass("player")) do
		SendDataMessage(msg,v,"explosion")
	end
end

local function damagePlayers(v,falloff,expush)
	local lt = LevelTime()
	local st = v.startTime
	local et = v.endTime
	local d = et - st
	local dt = (lt - st)/d
	local pos = v.pos
	local r = v.radius
	expush = expush or 0
	if(falloff) then r = r * dt end
	local etab = GetAllPlayers()
	table.Add(etab,GetEntitiesByClass("bodyque"))
	for _,pl in pairs(etab) do
		local plPos = pl:GetPos()
		local dp = (plPos - pos)
		local len = VectorLength(dp)
		local push = (dp / len) * (200 + expush)
		local dfc = 1 - (len / v.radius)
		if(dfc < .3) then dfc = .3 end
		if((v.lastdamage - lt) > 200) then
			v.lastdamage = 0
		end
		if(len < r and v.lastdamage < lt) then
			pl:Damage(v.owner,v.owner,v.damage*dfc,12)
			pl:SetVelocity(pl:GetVelocity() + push)
			v.lastdamage = lt + 80
		end
	end
end

function CreateExplosion(pos,radius,length,damage,owner)
	local startTime = LevelTime()
	local endTime = startTime + (radius * length)
	local e = {
		startTime = startTime,
		endTime = endTime,
		pos = pos,
		radius = radius,
		owner = owner,
		damage = damage,
		lastdamage = 0,
	}
	table.insert(explosions,e)
	sendExplosion(e)
	damagePlayers(e,false,120)
end

function etest(ent)
	if(ent == nil or ent:IsPlayer() == false) then return end
	if(ent:GetInfo().team == TEAM_SPECTATOR) then return end
	local forward = VectorForward(ent:GetAimVector())
	local startpos = vAdd(ent:GetMuzzlePos(),vMul(forward,12))
	local ignore = ent
	local mask = 1
	
	local endpos = vAdd(startpos,vMul(forward,10000))
	local res = TraceLine(startpos,endpos,ignore,mask)

	if(res.hit) then
		print("HIT!\n")
		CreateExplosion(res.endpos,160,2,25,ent)
	else
		print("No Hit\n")
	end
end
concommand.Add("explode",etest)

local function ExplosionThink()
	for k,v in pairs(explosions) do
		local lt = LevelTime()
		local st = v.startTime
		local et = v.endTime
		local d = et - st
		local dt = (lt - st)/d
		local pos = v.pos
		local r = v.radius * dt
		if(lt > et) then
			explosions[k].rem = true
		end
		damagePlayers(v,true)
	end
	for k,v in pairs(table.Copy(explosions)) do
		if(explosions[k] and explosions[k].rem) then
			table.remove(explosions,k)
		end
	end
end
hook.add("Think","explosion",ExplosionThink)

local function Rockets(v)
	if(v == nil) then return end
	if(v:Classname() != "rocket") then return end
	local touch = function(ent,other,trace)
		if(other != nil and other:IsPlayer() == false) then return end
		local pos = trace.endpos
		local pa = ent:GetParent()
		local add = 10
		if(pa != nil) then
			CreateExplosion(pos,70 + add,5,150,pa)
			CreateExplosion(pos,90 + add,8,25,pa)
			ent:Remove()
		end
	end
	v:SetCallback(ENTITY_CALLBACK_TOUCH, touch)
end
hook.add("EntityLinked","explosion_rockets",Rockets)