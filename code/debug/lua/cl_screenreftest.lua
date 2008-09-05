--local flash = LoadShader("flareshader")
local flash = LoadShader("menu/art/sliderbutt_0")
local sprite = RefEntity()
local aspect = (1 + ((640 - 480) / 640))
sprite:SetPos(Vector(10,0,0))
sprite:SetType(RT_SPRITE)
sprite:SetRadius(100/3)
sprite:SetShader(flash)

function setradius(r)
	sprite:SetRadius(r/3)
end

function setpos(x,y)
	x = x / 640
	y = y / 480
	x = x * 160
	y = y * 160
	local nx = 80-x
	local ny = 80-y
	nx = nx * aspect
	sprite:SetPos(Vector(300,nx,ny))
end

setpos(100,100)

local refdef = {}
refdef.x = 0
refdef.y = 0
refdef.width = 640
refdef.height = 480
refdef.origin = Vector(0,0,0)
refdef.angles = Vector(0,0,0)
refdef.fov_y = 30
refdef.fov_x = refdef.fov_y * aspect

local r = 0

function nsBox(x,y,w,h,v,shader)
	local d = 1/3
	draw.Rect(x,y,v,v,shader,0,0,d,d)
	draw.Rect(x+v,y,v+(w-v*3),v,shader,d,0,d*2,d)
	draw.Rect(x+(w-v),y,v,v,shader,d*2,0,d*3,d)
	
	draw.Rect(x,y+v,v,v+(h-v*3),shader,0,d,d,d*2)
	draw.Rect(x+v,y+v,v+(w-v*3),v+(h-(v*3)),shader,d,d,d*2,d*2)
	draw.Rect(x+(w-v),y+v,v,v+(h-(v*3)),shader,d*2,d,d*3,d*2)
	
	draw.Rect(x,y+(h-v),v,v,shader,0,d*2,d,d*3)
	draw.Rect(x+v,y+(h-v),v+(w-v*3),v,shader,d,d*2,d*2,d*3)
	draw.Rect(x+(w-v),y+(h-v),v,v,shader,d*2,d*2,d*3,d*3)
end

function draw2D()
	local d = 1/3
	render.CreateScene()
	sprite:SetColor(0,1,1,.4)
	sprite:Render()
	
	r = r + .1
	if(r > 360) then r = 0 end
	sprite:SetRotation(r)
	--render.RenderScene(refdef)
	
	draw.SetColor(1,1,1,1)
	--draw.Rect(10,10,200,210)
	--nsBox(0,0,100,100,100/3,flash)
end
hook.add("Draw2D","screenref",draw2D)