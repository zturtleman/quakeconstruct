include("lua/includes/treeparser.lua")

local s = [[
//import particles/base.psf

Test {
	base:null
	shader:"flareshader"
	render:RT_SPRITE
	type:LE_FRAGMENT
	time:4000
	scale:[1,1,1]
	radius {
		start:0|80
		end:0
	}
	color {
		start:[EMITTER_TIME,EMITTER_TIME,EMITTER_TIME/2]*EMITTER_TIME
		end:[0,1-EMITTER_TIME*EMITTER_TIME,0]
	}
	emit {
		time:5000
		delay:10
		spread:360
		speed:50|100
	}
}
]]

local b = [[
import particles/base.psf
TestA {
	type:100
}

TestB {
	base:TestA
}

TestC {
	base:TestB
}]]

local function VectorFromT(v,d)
	if(type(v) == "number") then return Vector(v) end
	if(type(v) == "table") then 
		local a = v[1] or 0
		local b = v[2] or a
		local c = v[3] or b
		return Vector(a,b,c)
	end
	return d
end

local function ColorFromT(v,d)
	if(type(v) ~= "table") then return unpack(d) end
	local r = v[1] or 1
	local g = v[2] or r
	local b = v[3] or g
	local a = v[4] or 1
	
	--print("COLOR: " .. r .. ", " .. g .. ", " .. b .. "\n")
	return r,g,b,a
end

local function BuildParticleEmitter(t,pos)
	local ref = RefEntity()
	--ref:SetColor(ColorFromT(t.color.start,{1,1,1,1}))
	ref:SetAngles(angle or Vector(0))
	ref:Scale(VectorFromT(t.scale,Vector(1)))
	ref:SetType(t.render or RT_SPRITE)
	if(model != nil) then ref:SetType(RT_MODEL) end
	if(model != nil) then ref:SetModel(model) end
	ref:SetShader(LoadShader(t.shader) or 0)
	if(t.radius == nil) then t.radius = {} end
	ref:SetRadius(t.radius.start or 5)
	ref:SetPos(pos)
	
	local le = LocalEntity()
	le:SetPos(pos)
	le:SetAngles(Vector(0))
	le:SetRefEntity(ref)
	le:SetStartTime(LevelTime())
	le:SetEndTime(LevelTime() + (t.time or 1000))
	le:SetType(t.type)
	if(t.type == LE_FRAGMENT and t.tr == nil) then
		t.tr = TR_GRAVITY
	end
	
	local trtype = t.tr or TR_LINEAR
	if(t.emit) then
		local estart = t.emit.start or 0
		local duration = t.emit.time or 0
		local d = t.emit.delay or 10
		le:Emitter(LevelTime()+estart, LevelTime()+estart+duration, d, function(l,lt)
			EMITTER_TIME = (1 - lt)
			--print(EMITTER_TIME .. "\n")
			local rnd = VectorRandom()*(t.emit.spread or 0)
			--rnd.z = 0
			local a = le:GetAngles()-- + rnd
			local f,r,u = AngleVectors(a)
			f = f  +  rnd/180
			f = VectorNormalize(f)
			l:SetVelocity(f*(t.emit.speed or 0))
			l:SetPos(le:GetPos())
			l:SetTrType(trtype)
			local r,g,b,a = ColorFromT(t.color.start,{1,1,1,1})
			l:SetStartColor(r,g,b,a)
			l:SetEndColor(ColorFromT(t.color["end"],{r,g,b,a}))
			local start = t.radius.start or 5
			--print(t.radius["end"] .. "\n")
			l:SetStartRadius(start)
			l:SetEndRadius(t.radius["end"] or start)
		end)
	end
	
	le:SetTrType(TR_STATIONARY)
	
	return le,ref
end

local parser = TreeParser()
parser:Clear()
local tree = {}
local test = packList("particles",".psf")
for k,v in pairs(test) do
	parser:ParseFile("particles/" .. v,tree)
end
parser:ParseString(s,tree)
parser:SetMeta(tree)

--print(tree["Test"].time .. "\n")

for k,v in pairs(tree) do
	local t = table.ToString(v,nil,true)
	t = string.Replace(t,"\t","  ")
	print(k .. ": " .. t .. "\n")
end

local tr = PlayerTrace()
local le,ref = BuildParticleEmitter(tree["Simple"],tr.endpos)

le:SetPos(tr.endpos + tr.normal * 100)
le:SetAngles(VectorToAngles(tr.normal))


--parser.parse(s)