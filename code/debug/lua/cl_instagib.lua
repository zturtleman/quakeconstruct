local shd = LoadShader("railCore")
local clicksound = LoadSound("sound/weapons/noammo.wav")
local landsound = LoadSound("sound/player/land1.wav")
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
	local y = 0
	for i=1, #stats do
		local v = stats[i]
		local txt = v[2] .. ": " .. v[1]
		if(v[3]) then txt = txt .. "%" end
		draw.Text(640 - (string.len(txt) * 15),y,txt,15,15)
		y = y + 20
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

local function HandleMessage(msgid)
	if(msgid == "igrailfire") then
		fading = false
		if(railStart != 0 and railEnd != 0) then
			PlaySound(clicksound)
		end
		railStart = message.ReadLong()
		railEnd = message.ReadLong()
	end
	if(msgid == "igstat") then
		stats[message.ReadShort()][1] = message.ReadShort()
	end
end
hook.add("HandleMessage","cl_instagib",HandleMessage)

local function event(entity,event,pos,dir)
	if(event == EV_FALL_MEDIUM or event == EV_FALL_FAR) then
		PlaySound(landsound)
		return true --No fall pain sounds
	end
end
hook.add("EventReceived","cl_newgibs",event)