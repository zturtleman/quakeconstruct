--require("cl_marks")
--require("cl_cgtab")
--self.VAriblae
require "cl_menu"
require "cl_testmenu"

local test = false
local startTime = os.time()

local function drawTimer()
	local t = (os.time() - startTime)
	local seconds = math.floor(t) % 60
	local minutes = math.floor(t/60) % 60
	local hours = math.floor(t/3600)
	if(seconds < 10) then seconds = "0" .. seconds end
	if(minutes < 10) then minutes = "0" .. minutes end
	local txt = hours .. ":" .. minutes .. ":" .. seconds
	draw.SetColor(1,0.6,0.3,1)
	draw.Text(10,60,txt,12,12)
end
hook.add("Draw2D","timertest",drawTimer)

local function ef_drawtext(x,y,txt,size,mask)
	local tab = string.ToTable(txt)
	local mx = mask[1]
	local my = mask[2]
	local mw = mask[3]
	local mh = mask[4]
	for k,v in pairs(tab) do
		if((x+size) > mx and x < (mx + mw)) then
			if((y+size) > my and y < (my + mh)) then
			draw.Text(x,y,v,size,size)
			end
		end
		x = x + size
	end
end

local function draw2d()
	--if(test == true) then
		local speed = 60
		local lip = 30
		local vw = 100
		local ts = 20
		local str = "Welcome to QConstruct: This is a test of my scrollie thingie. Which just happens to be really awesome!"
		local tw = string.len(str)*ts
		local scroll = ((CurTime() - startTime)*speed) % (tw+vw+lip)
		draw.SetColor(1,1,1,.2)
		draw.Rect(15,15,vw+10,ts+10)
		draw.MaskRect(20,20,vw,ts)
		draw.SetColor(0.1,0.6,1,1)
		--draw.Text((20+vw) - (scroll),20,str,ts,ts)
		ef_drawtext((20+vw) - (scroll),20,str,ts,{20,20,vw,ts})
		draw.EndMask()
	--end
	--draw.EndMask()
	--draw.EndMask()
end
hook.add("Draw2D","cl_init",draw2d)

--print(K_TAB .. "\n")

local function keyed(key,state)
	if(key == K_ENTER) then
		test = state
		return true
	end
end
hook.add("KeyEvent","cl_init",keyed)


EnableCursor(true)
local panel = UI_Create("frame")
if(panel != nil) then
	panel.name = "base"
	panel:SetPos(100,100)
	panel:SetSize(140,100)
	panel:SetTitle("Test Panel")
	panel:ConstrainToScreen(true)
end
--Timer(12,panel.Remove,panel)

local panel3 = UI_Create("dragbutton",panel)
if(panel3 != nil) then
	panel3.name = "base->inset->button"
	panel3:SetPos(0,0)
	panel3:SetSize(30,30)
	panel3:SetText("test")
	panel3:ScaleToContents()
	panel3:ConstrainToParent(true)
end

--[[panel.Think = function(self)
	self:SetPos(GetMouseX(),GetMouseY())
end]]
