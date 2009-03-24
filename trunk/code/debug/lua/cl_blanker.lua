--local shader = LoadShader("flareShader")

BLANKER_TIMERS = BLANKER_TIMERS or {}

local function StopTimers()
	for k,v in pairs(BLANKER_TIMERS) do
		StopTimer(v)
	end
	BLANKER_TIMERS = {}
end
StopTimers()


local s_menu_open = LoadSound("sound/misc/menu1.wav")
local s_menu_item = LoadSound("sound/misc/menu2.wav")
local s_menu_close = LoadSound("sound/misc/menu3.wav")
local s_menu_select = s_menu_close
local s_menu_fail = LoadSound("sound/misc/menu4.wav")
local s_rocket = LoadSound("sound/weapons/rocket/rockfly.wav")
-- s_rocket = LoadSound("sound/player/sorlag/death1.wav")

local path = "sound/misc/keyboard/"
local k_space = {
	LoadSound(path .. "k_space1.wav"),
	LoadSound(path .. "k_space2.wav"),
	LoadSound(path .. "k_space3.wav")
}
local k_return = {
	LoadSound(path .. "k_return1.wav"),
	LoadSound(path .. "k_return2.wav"),
	LoadSound(path .. "k_return3.wav")
}
local k_keys = {
	LoadSound(path .. "k_key1.wav"),
	LoadSound(path .. "k_key2.wav"),
	LoadSound(path .. "k_key3.wav"),
	LoadSound(path .. "k_key4.wav"),
	LoadSound(path .. "k_key5.wav"),
	LoadSound(path .. "k_key6.wav")
}

print(s_rocket .. "\n")

local mx,my = 0,0
local lmx,lmy = 0,0
local lx,ly = 0,0
local cx,cy = 0,0
local wd = false
local kd = false
local loop = nil
local function drawStuff()
	if(MouseDown()) then
		draw.SetColor(1,1,1,1)
		draw.Line(cx,cy,lx,ly,nil,2)
		if(!wd) then
			PlaySound(s_menu_open)
			loop = LoopSound(s_rocket,Vector(0,0,0))
		end
		wd = true
	else
		if(wd) then
			PlaySound(s_menu_close)
			if(loop) then loop:StopSound() end
		end
		wd = false
	end
	--ly = ly + (my - ly)*.1
	--lx = lx + (mx - lx)*.1
	lx,ly = cx,cy
	cx = cx + (mx - cx)*.1
	cy = cy + (my - cy)*.1
end

local function moused(x,y)
	mx = mx + x
	my = my + y
	
	if(MouseDown()) then
		--PlaySound()
		--[[local dx = (mx - cx)
		local dy = (my - cy)
		local dist = math.sqrt(dx*dx + dy*dy)/40
		
		loop = LoopSound(s_rocket,Vector(0,0,dist))]]
	end
	
	if(mx > 640) then mx = 640 end
	if(mx < 0) then mx = 0 end
	
	if(my > 480) then my = 480 end
	if(my < 0) then my = 0 end
end
hook.add("MouseEvent","cl_blanker",moused)

local para = [[
	Hello... and again,
	Welcome to the 'Aperture Science
	Computer-Aided Enrichment Center'.
	
	We hope your brief detention in the
	'Relaxation Vault' has been a pleasent one.
	
	Your specimen has been processed, and we
	are now ready to begin the test proper.
	
	Before we start however. Keep in mind that
	although fun, and learning are the primary
	goals of all 'Enrichment Center' activities.
	Serious injury may occur.
	
	For your own safety and the safety of others,
	Please refrain from Por favor bordon 
	de fallar Muchos gracias de fallar gracias.
	
	Stand back, the portal will open in.
	3
	2
	1
	
	.
	.
	.
	Press enter to quit.
]]

local tpara = ""
local enterquit = false
local active = true

local i = 1
local last = ""
for k,v in pairs(string.ToTable(para)) do
	i = i + (.05 + math.random(1,10)/100)
	local snd = k_keys[math.random(1,#k_keys)]
	if(last == "." and v != ".") then i = i + .6 end
	if(last == ",") then i = i + .4 end
	if(v == "\n" and last == "\n") then i = i + .4 end
	if(last == "3" or last == "2" or last == "1") then i = i + 1 end
	
	if(v == "\n") then snd = k_return[math.random(1,#k_return)] end
	if(v == " ") then snd = k_space[math.random(1,#k_space)] end
	
	local t = Timer(i,function() 
		tpara = tpara .. v 
		PlaySound(snd)
		if(v == "\n" or v == " ") then
			PlaySound(snd)
		end
	end)
	
	table.insert(BLANKER_TIMERS,t)
	last = v
end

local t = Timer(i,function() 
	enterquit = true
end)
table.insert(BLANKER_TIMERS,t)

local texts = {}

local function changeColor(c,amt,limit)	
	if(amt > 0 and c < limit) then c = c + amt end
	if(amt < 0 and c > limit) then c = c + amt end
	
	if(amt > 0 and c > limit) then c = limit end
	if(amt < 0 and c < limit) then c = limit end
	return c
end

local function textLine(index,y,line,current)
	local i=index
	local x = 0
	for k,v in pairs(string.ToTable(line)) do
		if(v == "\t") then v = "-" end
		texts[i] = texts[i] or {1,1,1}
		
		draw.SetColor(texts[i][1]*.8,texts[i][2]*.8,texts[i][3]*.8,1)
		draw.Text(x,y,v,10,15)
		
		texts[i][1] = changeColor(texts[i][1],-.08,0)
		texts[i][3] = changeColor(texts[i][3],-.08,0)
		
		i = i + 1
		x = x + 10
	end
	if((LevelTime() % 100) > 50 and current) then
		draw.SetColor(1,1,1,.8)
		draw.Rect(x,y,10,15)
	end
	
	return i
end

local function textParagraph()
	local y = 0
	local i = 1
	local tab = string.Explode("\n",tpara)
	
	for k,v in pairs(tab) do
		i=i + textLine(i,y,v,(k == #tab))
		y = y + 15
	end
end

local wmodel = LoadModel("*0")
local clx = 0
local function d3d()
	if(!active) then return end
	draw.SetColor(0,0,0,1)
	
	--if(KeyIsDown(K_SPACE)) then
		draw.Rect(0,0,640,480)
		--if(!kd) then PlaySound(s_menu_fail) end
		--kd = true
	--else
		--kd = false
	--end
	
	--draw.Rect(lmx-1,lmy-1,2,2)
	
	--draw.SetColor(1,1,1,1)
	--draw.Rect(mx-1,my-1,2,2)
	
	if(KeyIsDown(K_ENTER)) then --enterquit
		active = false
		StopTimers()
	end
	
	lmx,lmy = mx,my
	
	--drawStuff()
	textParagraph()
	
	local ref = RefEntity()
	ref:SetModel(wmodel)
	ref:SetShader(0)
	ref:Scale(Vector(1,1,1))
	--ref:Render()
end
hook.add("Draw3D","cl_blanker",d3d)

--ClearLoopingSounds()
--StopMusic()

hook.add("AllowGameSound","cl_blanker",function(sound) return !active end)

local function UserCmd(pl,angle,fm,rm,um,buttons,weapon)
	if(active) then
		SetUserCommand(Vector(),0,0,0,buttons,0)
	end
end
hook.add("UserCommand","cl_blanker",UserCmd)

local function noNuthin(str)
	if(!active) then return true end
	if(str == "WORLD") then return false end
	if(str == "ENTITIES") then return false end
	if(str == "HUD") then return false end
	if(str == "HUD_DRAWGUN") then return false end
	print(str .. "\n")
end
hook.add("ShouldDraw","cl_blanker",noNuthin);