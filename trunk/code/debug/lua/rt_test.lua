local data = 
[[{
	sort nearest
	cull disable
	{
		blendfunc add
		//alphaFunc LT128
		map $rendertarget
		alphaGen vertex
		rgbGen vertex
		tcMod transform 1 0 0 -1 0 0
		//tcGen environment
	}
}]]
local renderTarget = CreateShader("f",data)
local blood = LoadShader("dissolve")

local function riter(s)
	draw.Rect(-s,0,640,480,renderTarget)
	draw.Rect(s,0,640,480,renderTarget)
	draw.Rect(0,-s,640,480,renderTarget)
	draw.Rect(0,s,640,480,renderTarget)
	draw.Rect(s,s,640,480,renderTarget)
	draw.Rect(-s,-s,640,480,renderTarget)
	draw.Rect(-s,s,640,480,renderTarget)
	draw.Rect(s,-s,640,480,renderTarget)
end

function d2d()
	draw.SetColor(.1,.1,.1,.3)
	
	riter(5)
	riter(7)
	riter(10)
	
	
	draw.Rect(0,0,1,1)
	draw.Text(0,200,"YO",10,10)
	draw.Text(0,210,"YO",10,10)
end
hook.add("Draw2D","test8",d2d)

local mdl = LoadModel("*0")

local poly = Poly(renderTarget)

poly:AddVertex(Vector(-10,-10,-0),1,1,{1,1,1,1})
poly:AddVertex(Vector(-10,10,0),0,1,{1,1,1,1})
poly:AddVertex(Vector(10,10,0),0,0,{1,1,1,1})
poly:AddVertex(Vector(10,-10,0),1,0,{1,1,1,1})

poly:Split()

local reftest = poly:ToRef(false)

local function draw2D()
	render.CreateScene()

	local ref = RefEntity()
	ref:AlwaysRender(true)
	ref:SetModel(mdl)
	ref:SetColor(1,1,1,1)
	ref:Scale(Vector(1,1,1))
	ref:Render()
	ref:SetShader(0)
	
	render.AddPacketEntities()
	render.AddLocalEntities()
	render.AddMarks()
	
	local ang = VectorToAngles(_CG.refdef.angles)
	local ang2 = ang - Vector(90,0,0)
	local f,r,u = AngleVectors(ang)
	local org = _CG.refdef.origin + (f*20)
	
	--_CG.refdef.origin
	
	reftest:SetAngles(ang2)
	reftest:Scale(Vector(1.5,2,5))
	reftest:SetColor(.15,.15,.15,1)
	reftest:SetShader(renderTarget)
	
	--[[reftest:SetPos(org + u/2)
	reftest:Render()
	reftest:SetPos(org - u/2)
	reftest:Render()
	reftest:SetPos(org + r/2)
	reftest:Render()
	reftest:SetPos(org - r/2)
	reftest:Render()]]
	
	local refdef = {}
	refdef.x = 0
	refdef.y = 0
	refdef.fov_x = _CG.refdef.fov_x
	refdef.fov_y = _CG.refdef.fov_y
	refdef.width = 640
	refdef.height = 480
	refdef.origin = _CG.refdef.origin
	refdef.angles = VectorToAngles(_CG.refdef.angles)
	refdef.flags = 1
	refdef.renderTarget = true
	render.RenderScene(refdef)
end
hook.add("DrawRT","test8",draw2D)