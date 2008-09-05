altmenu = {}

local flash = LoadShader("flareShader")
local frame = LoadShader("menu/art/addbotframe")
local s_menu_open = LoadSound("sound/misc/menu1.wav")
local s_menu_item = LoadSound("sound/misc/menu2.wav")
local s_menu_close = LoadSound("sound/misc/menu3.wav")
local s_menu_select = s_menu_close
local s_menu_fail = LoadSound("sound/misc/menu4.wav")

local mx = 0
local my = 0
local buttons = {}
local mFade = 0
local lastbtn = -1
local textw = 15
local texth = 20
local cursortrails = {}
local nextTrail = LevelTime()

local function ctrails()
	if(nextTrail < LevelTime()) then
		nextTrail = LevelTime() + 10
		altmenu.addctrail(mx+math.random(-3,3),my+math.random(-3,3))
	end
	for k,v in pairs(cursortrails) do
		if(v[3] > 0) then
			local x = v[1]
			local y = v[2]
			draw.SetColor(v[3],v[3],v[3],1)
			draw.Rect(x-10,y-10,20,20,flash)	
			v[3] = v[3] - 0.1
			v[2] = v[2] + 1
		else
			v[4] = true
		end
	end
	for k,v in pairs(table.Copy(cursortrails)) do
		if(v[4] == true) then table.remove(cursortrails,k) end
	end
end

function altmenu.addctrail(x,y)
	table.insert(cursortrails,{x,y,1})
end

function altmenu.textSize(w,h)
	textw = w
	texth = h
end

function altmenu.addButton(name,func,...)
	--local args = unpack(arg)
	table.insert(buttons,{name=name,func=func,args=arg})
end

function altmenu.clearButtons()
	buttons = {}
end

local function drawButtons(x,y,tw,th,maxw)
	for k,v in pairs(buttons) do
		local text = v.name
		local func = v.func
		local lw = maxw --tw*string.len(fixcolorstring(v.name))
		local lx = x
		if(mx > lx and my > y and mx < lx + lw and my < y + th) then
			if(v.moused != 1 and !MouseDown()) then
				v.moused = 1
				if(lastbtn != k) then
					PlaySound(s_menu_item)
					lastbtn = k
				end
			end
		else
			v.moused = 0
			if(lastbtn == k) then
				lastbtn = -1
			end
		end
		if(v.moused == 1 and MouseDown()) then
			v.moused = 2
		end
		if(v.moused == 1) then
			draw.SetColor(.7,.7,.7,.4)
			draw.Rect(lx,y,lw,th)
		end
		if(v.fade and v.fade > 0) then
			draw.SetColor(1,0,0,v.fade)
			draw.Rect(lx,y,lw,th)
			v.fade = v.fade - 0.02
		end
		draw.SetColor(1,1,1,1)
		draw.Text(lx,y,text,tw,th)
		y = y + th
	end
end

local function drawMenu()
	if(#buttons == 0) then return end
	local x = 20
	local y = 150
	local tw = textw
	local th = texth
	local maxw = 0
	local maxh = 0
	local padding = 10
	for k,v in pairs(buttons) do
		local text = fixcolorstring(v.name)
		if(tw*string.len(text) > maxw) then
			maxw = tw*string.len(text)
		end
		maxh = maxh + th
	end
	maxh = maxh + padding
	maxw = maxw + padding
	x = 10
	y = 240 - maxh/2
	draw.SetColor(1,1,1,.1)
	draw.Rect(x,y,maxw,maxh)
	x = x + padding/2
	y = y + padding/2
	drawButtons(x,y,tw,th,maxw - padding)
end

local function draw2d()
	mx = GetXMouse()
	my = GetYMouse()
	if(MouseFocused()) then
		ctrails()
		drawMenu()
		draw.SetColor(1,1,1,1)
		draw.Rect(mx-10,my-10,20,20,flash)
		if(mFade > 0) then
			draw.SetColor(mFade,0,0,0)
			draw.Rect(mx-20,my-20,40,40,flash)
			mFade = mFade - 0.05
		end
	else
		cursortrails = {}
	end
end
hook.add("Draw2D","cl_menu",draw2d)
hook.add("MouseDown","cl_menu",function()
	if(!MouseFocused()) then return end
	for k,v in pairs(buttons) do
		local text = v.name
		local func = v.func
		local args = v.args
		if(v.moused != nil and v.moused > 0) then
			if(func != nil) then
				local b,e = pcall(func,unpack(args))
				if(!b) then
					print("^1BUTTON ERROR: " .. e .. "\n")
				end
			end
			PlaySound(s_menu_select)
			v.fade = 1
		end
	end
	mFade = 1 
end)

local function moused(x,y)
	mx = mx + x
	my = my + y
	
	if(mx > 640) then mx = 640 end
	if(mx < 0) then mx = 0 end
	
	if(my > 480) then my = 480 end
	if(my < 0) then my = 0 end
end
hook.add("MouseEvent","cl_menu",moused)

local function keyed(key,state)
	if(key == K_ALT) then
		if(state == false) then
			if(MouseFocused()) then
				EnableCursor(false)
				CallHook("AltMenuClose")
				if(#buttons == 0) then return end
				PlaySound(s_menu_close)
			end
		else
			if(!MouseFocused()) then
				EnableCursor(true)
				mx = 320
				my = 240
				CallHook("AltMenuOpen")
				if(#buttons == 0) then return end
				PlaySound(s_menu_open)
				for k,v in pairs(buttons) do
					v.fade = 0
				end
			end
		end
	end
end
hook.add("KeyEvent","cl_menu",keyed)