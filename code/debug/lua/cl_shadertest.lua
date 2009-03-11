local outlines = {}
local n = 40
for i=1,n do
	local d = 
	[[{
		cull back
		deformVertexes wave 10 sin ]] .. (i/n)*10 .. [[ 2 ]] .. ((i/n) * 2)-1 .. [[ 2
		polygonoffset
		{
			map gfx/misc/dissolve2.tga
			blendFunc add
			alphaFunc GE128
			rgbGen entity
			alphaGen entity
			tcMod turb 0 .2 ]] .. i/n ..  [[ 2
			tcGen environment
		}
	}]]
	table.insert(outlines,CreateShader("f",d))
end

local data3 = 
[[{
	cull back
	deformVertexes wave 10000 sin 20 20 .5 .6
	polygonoffset
	{
		map gfx/misc/dissolve2.tga
		blendFunc add
		alphaFunc GE128
		rgbGen entity
		alphaGen wave inversesawtooth 0 1 .75 .6	
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
local s3 = CreateShader("f",data3)
local s2 = CreateShader("f",data2)
local rmodel = LoadModel("models/gibs/skull.md3")
local tr = PlayerTrace()
local pos = tr.endpos + Vector(0,0,50)
local ref = RefEntity()
ref:SetPos(pos)
ref:SetModel(rmodel)

local function drawItem(ent,mdl)
	local delta = ent:GetPos() - _CG.viewOrigin
	local d = VectorLength(delta)
	local ref = RefEntity()
	ref:SetPos(ent:GetPos() + Vector(0,0,10+math.sin(LevelTime()/300)*4))
	
	local normal = VectorNormalize(ref:GetPos() - _CG.viewOrigin)
	
	--ref:SetPos(ref:GetPos() - normal*60)
	ref:SetAngles(Vector(0,LevelTime()/7,0))
	ref:SetModel(mdl)
	ref:Render()
	local vd = (1-(d/300))
	
	if(d < 300) then
		ref:SetColor(vd/8,vd/8,vd/8,1)
		ref:SetShader(s3)
		for i=0, 40 do
			local t = LevelTime() - 300 - ((1 - vd)*1000)
			ref:SetTime(t + i*5)
			ref:Render()
		end
		--[[for k,v in pairs(outlines) do
			local c = (1-(k/n))/10
			--c = c * vd
			--if(vd > .7) then vd = .7 end
			ref:SetColor((1-c)/2,c,0,vd - (k/10)/20)
			ref:SetShader(v)
			ref:Render()
		end]]
	end
end

local function d3d()
	--[[ref:SetColor(1,1,1,1)
	ref:SetShader(0)
	ref:Render()
	for k,v in pairs(outlines) do
		local c = (1-(k/20))/20
		ref:SetColor(c,c/10,0,1)
		ref:SetShader(v)
		ref:Render()
	end]]
	
	for k,v in pairs(GetEntitiesByClass('item')) do
		local mdl = util.GetItemModel(v:GetModelIndex())
		v:CustomDraw(true)
		drawItem(v,mdl)
	end
end
hook.add("Draw3D","cl_shadertest",d3d)

local function d2d()
	draw.SetColor(1,1,1,1)
	--draw.Rect(50,300,100,100,s)
end
hook.add("Draw2D","cl_shadertest",d2d)