print("Hooray!\n")

local soundtest = "";
local t = 0
local marks = {}

local texture = LoadShader("bloodMark");

local lastHP = 0
local i = 400

local function reset()
	t = 0
	i = 400
	marks = {}
end

local function newMark(x,y,dmg)
	table.insert(marks,{x=x,y=y,dmg=dmg,alpha=1})
end

local function damaged(amt)
	print("Damage\n")
	if(amt < 10) then
		amt = amt + math.random(0,10)
	end
	newMark(math.random(0,640),math.random(0,480),amt)
end

function MarkTest(dmg)
	damaged(dmg)
end

local function drawMarks()
	for k,v in pairs(marks) do
		local a = v.dmg / 20
		
		local size = (a*320) + 120
		
		draw.SetColor(1,1,1,v.alpha)
		draw.Rect(v.x-(size/2),v.y-(size/2),size,size,texture)
		
		v.alpha = v.alpha - 0.002
		v.dmg = v.dmg + 0.007
		v.y = v.y + 0.03
		if(v.dmg < 10) then
		v.alpha = v.alpha - 0.002
		end
		if(v.alpha < 0) then
			table.remove(marks,k)
		end
	end
end

local function draw2D()
	local inf = LocalPlayer():GetInfo()["health"];
	local dhp = lastHP - inf
	
	if(dhp > 1) then
		damaged(dhp)
	end
	
	local hp = math.min(math.max(inf + 20,1),100)
	local hpx = 1 - (hp/100)
	
	if(t > 0) then t = t - 0.006 end
	--if(t < hpx) then t = hpx end
	
	local d = 2-t;
	local d2 = t;
	
	if(inf <= 0) then 
		t = .9
		if(i < 2000) then i = i + 0.4 end
	end
	
	if(inf > 0 and lastHP <= 0) then reset() end
	
	drawMarks()
	
	draw.SetColor(1,1,1,t)
	draw.Rect(-i,-i,640+i*2,480+i*2,texture)
	
	lastHP = inf
end
hook.add("Draw2D","marks",draw2D)

local function draw3D()

end
hook.add("Draw3D","marks",draw3D)

function event(entity,event,pos)
	--print("Got Event: " .. EnumToString(entity_event_t,event) .. "\n")
	if(event == EV_FIRE_WEAPON) then
		--local sound = LoadSound("sound/items/s_health.wav")
		--PlaySound(entity,sound)
	end
	if(event == EV_PAIN) then
		draw2D()
	end
end
hook.add("EventReceived","marks",event)