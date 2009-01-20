local shd = LoadShader("railCore")
local mark = LoadShader("BloodMark")
local flare = LoadShader("flareShader")
local clicksound = LoadSound("sound/weapons/noammo.wav")
local landsound = LoadSound("sound/player/land1.wav")
local tr_flags = 1
tr_flags = bitOr(tr_flags,33554432)
tr_flags = bitOr(tr_flags,67108864)

STAT_SHOTS = 1
STAT_HITS = 2
STAT_ACCURACY = 3
STAT_DEATHS = 4
STAT_LONGSHOT = 5
local stats = {
	[STAT_SHOTS] = {0,"Shots"},
	[STAT_HITS] = {0,"Hits"},
	[STAT_ACCURACY] = {0,"Accuracy",true},
	[STAT_DEATHS] = {0,"Deaths"},
	[STAT_LONGSHOT] = {0,"Shot Distance"}
}

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
			if(i == 1) then le:SetRefEntity(rpoint(v1,size)) end
			if(i == 2) then le:SetRefEntity(rpoint(v2,size)) end
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

local function shouldDraw(str)
	if(str == "HUD_STATUSBAR_HEALTH") then return false end
	if(str == "HUD_STATUSBAR_AMMO") then return false end
	if(str == "HUD_AMMOWARNING") then return false end
	if(str == "HUD_WEAPONSELECT") then return false end
end
hook.add("ShouldDraw","cl_instagib",shouldDraw)

local railStart = 0
local railEnd = 0
local t = 0
local fading = false
local function drawHud()
	stats[STAT_ACCURACY][1] = math.floor((stats[STAT_HITS][1] / stats[STAT_SHOTS][1]) * 100)
	if(stats[STAT_SHOTS][1] <= 0) then
		stats[STAT_ACCURACY][1] = 0
	end
	draw.SetColor(1,1,1,.8)
	local y = 100
	for i=1, #stats do
		local v = stats[i]
		local txt = v[2] .. ": " .. v[1]
		if(v[3]) then txt = txt .. "%" end
		draw.Text(640 - (string.len(txt) * 10),y,txt,10,10)
		y = y + 15
	end
end

local function draw2d()
	drawHud()
	t = t + 1
	local d = (railEnd - railStart)
	local dt = (railEnd - LevelTime()) / d
	local w = 100
	local h = 8
	local n = w * (1 - dt)
	local pc = math.floor(10*(1-dt))*10 .. "%"
	if(dt <= 0) then pc = "100%" end
	local txt = "Reloading " .. pc
	local c = 150 * (1-dt)

	if(n > w) then n = w end
	if(c > 150) then c = 150 end
	
	if(railStart != 0 and railEnd != 0) then
		local al = 1
		if(dt < 0) then al = (1 + (dt*3.5)) end
		if(al < 0) then al = 0 end
		draw.SetColor(1,1,1,.1*al)
		draw.Rect(320 - w/2,260 - h/2,w,h)
		draw.Rect(320 - w/2,260 - h/3,w,h*.3)

		draw.SetColor(hsv(c,1,1,.4*al))
		draw.Rect(320 - n/2,260 - h/2,n,h)
		
		draw.SetColor(hsv(c,.5,1,.4*al))
		draw.Rect(320 - n/2,260 - h/3,n,h*.3)
		
		local x = 320 - (h*.8 * string.len(txt))/2
		local y = 270 - h/2
		draw.SetColor(0,0,0,.8*al)
		draw.Text(x-1,y,txt,h*.8,h)
		draw.Text(x+1,y,txt,h*.8,h)
		draw.Text(x,y-1,txt,h*.8,h)
		draw.Text(x,y+1,txt,h*.8,h)
		draw.SetColor(1,1,1,.8*al)
		draw.Text(x,y,txt,h*.8,h)
		
		if(dt <= 0 and fading == false) then
			PlaySound(clicksound)
			fading = true
		end
		if(al <= 0) then
			railStart = 0
			railEnd = 0
		end
	end
end
hook.add("Draw2D","cl_instagib",draw2d)

local function rvec() return Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100))/100 end
local nxtsnd = {}

local function HandleMessage(msgid)
	if(msgid == "igrailfire") then
		fading = false
		if(railStart != 0 and railEnd != 0) then
			PlaySound(clicksound)
		end
		railStart = message.ReadLong()
		railEnd = message.ReadLong()
	end
	if(msgid == "igdeath") then
		local id = message.ReadShort()
		local pl = GetEntityByIndex(id)
		if(pl != nil) then
			nxtsnd[id] = nxtsnd[id] or 1
			local snd = LoadCustomSound(pl,"*death" .. nxtsnd[id] .. ".wav")
			PlaySound(pl,snd)
			nxtsnd[id] = nxtsnd[id] + 1
			if(nxtsnd[id] > 3) then nxtsnd[id] = 1 end
		end
	end
	if(msgid == "igstat") then
		stats[message.ReadShort()][1] = message.ReadShort()
	end
	if(msgid == "igbeam") then
		local s = message.ReadVector()
		local e = message.ReadVector()
		local hue = message.ReadShort()
		local tr = TraceLine(s,e+VectorNormalize(e-s)*1000,nil,tr_flags)
		local r,g,b = hsv(hue,1,1)
		local len = VectorLength(e-s)
		local forward,right,up = AngleVectors(VectorToAngles(e-s))
		qbeam(s,e,r/3,g/3,b/3,5,true,8000)
		qbeam(s,e,r,g,b,5,false,700)
		qbeam(s,e,r/2,g/2,b/2,8,false,850)
		qbeam(s,e,r/5,g/5,b/5,12,false,1000)
		qbeam(s,e,1,1,1,5,false,600)
//__DL_BLOCK
		--[[local last = s
		local step = 20
		for i=0,len,step do
			if(i != 0) then
				local m = 180
				local new = s + (forward*step) * ((i/len) * (len/step))
				new = new + (right * math.cos((i/20) + m)) * 6
				new = new + (up * math.sin((i/20) + m)) * 6
				qbeam(last,new,r,g,b,4,true,600)
				qbeam(last,new,1,1,1,2,true,500)
				last = new
			end
		end]]
//__DL_UNBLOCK
		for x=1, 6 do
			local last = e
			for i=0,40,20 do
				local new = last + rvec()*60
				qbeam(last,new,r,g,b,4,true,500)
				qbeam(last,new,1,1,1,2,true,300)
				last = new
			end
		end
		
		if(!tr.normal) then return end
		util.CreateMark(mark,e,tr.normal,math.random(360),0,0,0,1,math.random(15,20),true)
		util.CreateMark(mark,e,tr.normal,math.random(360),0,0,0,.5,math.random(25,35),true)
		util.CreateMark(mark,e,tr.normal,math.random(360),0,0,0,.3,math.random(45,50),true)
		util.CreateMark(mark,e,tr.normal,math.random(360),0,0,0,.2,math.random(60,75),true)
	end
end
hook.add("HandleMessage","cl_instagib",HandleMessage)

local function event(entity,event,pos,dir)
	if(event == EV_FALL_MEDIUM or event == EV_FALL_FAR) then
		if(entity == LocalPlayer()) then PlaySound(landsound) end
		return true --No fall pain sounds
	end
	if(event == EV_RAILTRAIL) then return true end
end
hook.add("EventReceived","cl_instagib",event)