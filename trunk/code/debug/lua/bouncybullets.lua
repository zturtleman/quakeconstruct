//__DL_BLOCK
if(SERVER) then
downloader.add("lua/bullets.lua")

local MASK_SHOT = gOR(CONTENTS_SOLID,CONTENTS_BODY,CONTENTS_CORPSE)

message.Precache("bulletbounce")

local function crand()
	return 2 * (math.random() - 0.5)
end

local function sendline(s,e)
	local msg = Message()
	message.WriteVector(msg,s)
	message.WriteVector(msg,e)
	SendDataMessageToAll(msg,"bulletbounce")
end

local function bullet(i,start,angle,pl,spread,damage,mod)
	local forward,right,up = AngleVectors(angle)

	local r = math.random() * math.pi * 2
	local u = math.sin(r) * crand() * spread * 16
	r = math.cos(r) * crand() * spread * 16
	
	local vend = start + forward * 8192*16
	vend = vend + right * r
	vend = vend + up * u
	
	local ignore = pl:EntIndex()
	if(i > 0) then ignore = nil end
	local tr = TraceLine(start,vend,ignore,MASK_SHOT)
	
	if(tr.hit) then
		if(bitAnd(tr.surfaceflags, SURF_NOIMPACT) == 1) then
			return
		end
		
		local ent = tr.entity
		local tent = nil
		if(ent ~= nil and ent:IsPlayer()) then
			tent = CreateTempEntity(tr.endpos,EV_BULLET_HIT_FLESH)
			tent:SetEventParm(ent:EntIndex())
		else
			tent = CreateTempEntity(tr.endpos,EV_BULLET_HIT_WALL)
			tent:SetEventParm(DirToByte(tr.normal))
		end
		tent:SetOtherEntity(pl)
		
		if(ent ~= nil) then
			ent:Damage(pl,pl,damage,mod,forward,tr.endpos)
		else
			if(i < 3) then
				local dot = DotProduct( forward, tr.normal );
				local reflect = VectorNormalize(vAdd(forward,vMul(tr.normal,-2*dot)))
				local angle = VectorToAngles(reflect)
				Timer(.06,function()
					bullet(i+1,tr.endpos,angle,pl,spread,damage,mod)
				end)
			end
		end
		sendline(start,tr.endpos)
	else
		sendline(start,vend)
	end
end

function FireBullet(start,angle,pl,spread,damage,mod)
	bullet(0,start,angle,pl,spread,damage,mod)
end

local function fired(clientnum,weapon,t,muzzle,forward)
	if(weapon == WP_MACHINEGUN) then
		local pl = GetPlayerByIndex(clientnum)
		if(pl == nil) then return end
		
		FireBullet(muzzle,forward,pl,0,32,MOD_MACHINEGUN)
		
		return true
	end
end
hook.add("SVFiredWeapon","bullets.lua",fired)
return
end
//__DL_UNBLOCK

local mark = LoadShader("gfx/damage/hole_lg_mrk")
local flare = LoadShader("flareShader")
local fx = LoadShader("railCore")

local function getBeamRef(v1,v2,r,g,b,size)
	local st1 = RefEntity()
	st1:SetType(RT_RAIL_CORE)
	st1:SetPos(v1)
	st1:SetPos2(v2)
	st1:SetColor(r,g,b,1)
	st1:SetRadius(size or 12)
	st1:SetShader(fx)
	return st1
end

local function rpoint(pos,size)
	local s = RefEntity()
	s:SetType(RT_SPRITE)
	s:SetPos(pos)
	s:SetColor(1,1,1,1)
	s:SetRadius(size or 8)
	s:SetShader(flare)
	return s
end

local function qbeam(v1,v2,r,g,b,size,np,delay,stdelay)
	local ref = getBeamRef(v1,v2,r,g,b,size)
	
	for i=1,3 do
		if(!np or i==3) then
			local le = LocalEntity()
			le:SetPos(v1)
			
			le:SetRefEntity(ref)
			if(i == 1) then le:SetRefEntity(rpoint(v1,size*i)) end
			if(i == 2) then le:SetRefEntity(rpoint(v2,size*i)) end
			le:SetRadius(ref:GetRadius())
			le:SetStartTime(LevelTime() + (stdelay or 0))
			le:SetEndTime(LevelTime() + (delay or 500))
			le:SetType(LE_FADE_RGB)
			--if(point) then le:SetType(LE_FRAGMENT) end --LE_FRAGMENT
			le:SetColor(r,g,b,1)
			le:SetTrType(TR_STATIONARY)
		end
	end
end

local function HandleMessage(msgid)
	if(msgid == "bulletbounce") then
		local s = message.ReadVector()
		local e = message.ReadVector()
		
		qbeam(s,e,1,.7,.4,1,false,800)
	end
end
hook.add("HandleMessage","cl_instagib",HandleMessage)