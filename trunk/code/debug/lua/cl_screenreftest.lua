local flash = LoadShader("lagometer")
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

function draw2D()
	render.CreateScene()
	sprite:SetColor(0,1,1,.4)
	sprite:Render()
	
	r = r + .1
	if(r > 360) then r = 0 end
	sprite:SetRotation(r)
	render.RenderScene(refdef)
end
hook.add("Draw2D","screenref",draw2D)