print("Hooray!\n")

local soundtest = "";
local t = 0
local marks = {}

local texture = LoadShader("bloodTrail"); --bloodMark

local lastHP = 0
local i = 200
local wasDamage = false
local lastDX = 0
local lastDY = 0

local function reset()
	t = 0
	i = 200
	marks = {}
end

local function newMark(x,y,dmg)
	local al = .5
	if(dmg > 70) then dmg = 70 end
	
	if(#marks > 5 and dmg < 15) then al = .25 end
	
	table.insert(marks,{x=x,y=y,dmg=dmg,alpha=al})
end

local function clamp(v,min,max)
	return math.max(math.min(v,max),min)
end

local function damaged(amt)
	if(amt < 10) then
		amt = amt + math.random(0,10)
	end
	local scrw = 640
	local scrh = 480
	local dx = (_CG.damageX+1)*scrw/2
	local dy = (_CG.damageY+1)*scrh/2
	
	if(lastDX == _CG.damageX and lastDY == _CG.damageY) then
		--dx = scrw/2
		--dy = scrh
		amt = amt * 2
	end
	
	dx = dx + math.random(-40,40)
	dy = dy + math.random(-40,40)
	
	lastDX = _CG.damageX
	lastDY = _CG.damageY
	
	dx = clamp(dx,0,scrw)
	dy = clamp(dy,0,scrh)
	
	newMark(dx,dy,amt)
end

function MarkTest(dmg)
	damaged(dmg)
end

local function drawMarks(inf)
	for k,v in pairs(marks) do
		local a = v.dmg / 20
		
		local size = (a*220) + 120
		
		draw.SetColor(1,1,1,v.alpha)
		draw.Rect(v.x-(size/2),v.y-(size/2),size,size,texture)
		
		if(inf > 0) then
			v.alpha = v.alpha - 0.002
			v.dmg = v.dmg + 0.007
			v.y = v.y + 0.03
			if(v.dmg < 10) then
			v.alpha = v.alpha - 0.002
			end
		else
			v.alpha = 1
		end
		if(v.alpha < 0) then
			v.remove = true
		end
	end
	for k,v in pairs(table.Copy(marks)) do
		if(v.remove) then table.remove(marks,k) end
	end
end

local function draw2D()
	local inf = LocalPlayer():GetInfo()["health"];
	local dhp = lastHP - inf
	if(inf > 0 and lastHP <= 0) then reset() end
	lastHP = inf
	
	if(dhp > 1 or (wasDamage and dhp > 0)) then
		damaged(dhp)
		wasDamage = false
	end
	
	local hp = math.min(math.max(inf + 20,1),100)
	local hpx = 1 - (hp/100)
	
	t = 0
	if(t < hpx) then t = hpx end
	
	local d = 2-t;
	local d2 = t;
	
	if(inf <= 0) then 
		t = 0
		if(i < 2000) then i = i + 0.4 end
	end
	
	drawMarks(inf)
	
	draw.SetColor(1,1,1,t/1.6)
	draw.Rect(-i,-i,640+i*2,480+i*2,texture)
	
end
hook.add("Draw2D","marks",draw2D)

function event(entity,event,pos)
	--print("Got Event: " .. EnumToString(entity_event_t,event) .. "\n")
	if(event == EV_FIRE_WEAPON) then
		--local sound = LoadSound("sound/items/s_health.wav")
		--PlaySound(entity,sound)
	end
	if(event == EV_PAIN and entity == LocalPlayer()) then
		wasDamage = true
		--draw2D()
	end
end
hook.add("EventReceived","marks",event)