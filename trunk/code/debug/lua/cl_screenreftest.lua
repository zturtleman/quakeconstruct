local flash = LoadShader("flareShader")
local sprite = RefEntity()
sprite:SetPos(Vector(10,0,0))
sprite:SetType(RT_SPRITE)
sprite:SetRadius(20)
sprite:SetShader(flash)

function set(x,y)
	x = x / 640
	y = y / 480
	x = x * 160
	y = y * 160
	sprite:SetPos(Vector(300,80-x,80-y))
end

set(100,100)

local refdef = {}
refdef.x = 0
refdef.y = 0
refdef.width = 640
refdef.height = 480
refdef.origin = Vector(0,0,0)
refdef.angles = Vector(0,0,0)

local r = 0

function draw2D()
	render.CreateScene()
	sprite:SetColor(1,1,1,1)
	sprite:Render()
	
	r = r + 1
	if(r > 360) then r = 0 end
	refdef.angles = Vector(0,0,0)
	render.RenderScene(refdef)
end
hook.add("Draw2D","screenref",draw2D)