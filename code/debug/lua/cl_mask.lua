local shader = LoadShader("gfx/2d/bigchars") --LoadShader("9slice1")
local r1x = 200
local r1y = 200
local r1w = 200
local r1h = 200

local mask = {x=100,y=100,w=120,h=40}

local function drawOutlineRect(x,y,w,h,s,shd,color)
	if(color) then draw.SetColor(unpack(color)) end
	draw.Rect(x,y,w-s,s,shd)
	draw.Rect(x+(w-s),y,s,h-s,shd)
	draw.Rect(x+s,y+(h-s),w-s,s,shd)
	draw.Rect(x,y,s,h,shd)
	if(color) then draw.SetColor(1,1,1,1) end
end

function doMask()
	local x = GetXMouse()
	local y = GetYMouse()
	mask.x = x
	mask.y = y
	mask.w = 100 + (math.sin(LevelTime()/100)*10)
	drawOutlineRect(mask.x,mask.y,mask.w,mask.h,3,nil)
end

local function clamp(v)
	if(v > 1) then v = 1 end
	if(v < 0) then v = 0 end
	return v
end

function drawRect1(rx,ry,rw,rh,s,t,s1,t1)
	s = s or 0
	t = t or 0
	s1 = s1 or 1
	t1 = t1 or 1
	
	local m = mask
	local r = {x=rx,y=ry,w=rw,h=rh}
	local v = {x=0,y=0,w=0,h=0}
	
	if(r.x < m.x) then v.x = m.x - rx end
	if(r.y < m.y) then v.y = m.y - ry end
	if(r.x + r.w > m.x + m.w) then v.w = (m.x + m.w) - (r.x + r.w) end
	if(r.y + r.h > m.y + m.h) then v.h = (m.y + m.h) - (r.y + r.h) end
	
	s = s + v.x/r.w
	s1 = s1 + v.w/r.w
	
	t = t + v.y/r.h
	t1 = t1 + v.h/r.h
		
	r.x = r.x + v.x
	r.w = r.w - (v.x - v.w)
	
	r.y = r.y + v.y
	r.h = r.h - (v.y - v.h)
	
	drawOutlineRect(rx,ry,rw,rh,2,nil,{1,0,0,1})
	if(r.w < 0) then return end
	if(r.h < 0) then return end
	drawOutlineRect(rx,ry,rw,rh,2,nil,{1,.8,.3,1})
	
	draw.Rect(r.x,r.y,r.w,r.h,shader,s,t,s1,t1)
end

function draw2d()
	doMask()
	drawRect1(r1x,r1y,r1w,r1h)
end
hook.add("Draw2D","cl_mask",draw2d)

EnableCursor(true)