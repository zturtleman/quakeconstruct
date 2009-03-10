local data = 
[[{
	cull back
	deformVertexes wave 100 sin 0.8 0 .5 1 
	polygonoffset
	{
		map gfx/misc/dissolve1.tga
		blendfunc filter
		rgbGen entity
		alphaGen entity
		tcMod scroll 0 -.3
		tcGen environment
	}
}]]
local data2 = 
[[{
	deformVertexes wave 100 sin 0.8 0 .5 1 
	polygonoffset
	{
		map gfx/misc/dissolve1.tga
		rgbGen entity
		blendFunc filter
		alphaFunc GE128
		alphaGen entity
		tcMod scroll 0 -.3
		tcGen environment
	}
}]]
local s = CreateShader("f",data)
local s2 = CreateShader("f",data2)
local rmodel = LoadModel("models/gibs/skull.md3")--models[math.random(1,#models)]
local tr = PlayerTrace()
local pos = tr.endpos + Vector(0,0,50)
local ref = RefEntity()
ref:SetColor(1,1,1,1)
ref:SetPos(pos)
ref:SetModel(rmodel)
--ref:Scale(Vector(5,5,5))

local function d3d()
	ref:SetShader(0)
	ref:Render()
	ref:SetShader(s)
	ref:Render()
end
hook.add("Draw3D","cl_shadertest",d3d)

local function d2d()
	draw.SetColor(1,1,1,1)
	--draw.Rect(50,300,100,100,s)
end
hook.add("Draw2D","cl_shadertest",d2d)