local fire = LoadShader("fireSphere")
local flare = LoadShader("flareShader")
local sphere = LoadModel("models/misc/sphere.md3")
local explosions = {}

local expsound = LoadSound("sound/weapons/rocket/rocklx1a.wav")

local function rpoint(pos)
	local s = RefEntity()
	s:SetType(RT_SPRITE)
	s:SetPos(pos)
	s:SetColor(1,1,1,1)
	s:SetRadius(2)
	s:SetShader(flare)
	return s
end

function genFireSphere(pos,radius,a)
	local r = radius/61.3
	local s = RefEntity()
	s:SetModel(sphere)
	s:SetPos(pos)
	s:SetColor(a,a,a,a)
	s:Scale(Vector(r,r,r))
	s:SetShader(fire)
	s:AlwaysRender(true)
	s:Render()
end

local function HandleMessage(msgid)
	if(msgid == "explosion") then
		local pos = message.ReadVector()
		local r = message.ReadLong()
		local st = message.ReadLong()
		local et = message.ReadLong()
		
		local e = {
			st = st,
			et = et,
			pos = pos,
			r = r
		}
		table.insert(explosions,e)
		
		PlaySound(pos,expsound)
	end
end
hook.add("HandleMessage","cl_explosion",HandleMessage)

local function d3d()
	for k,v in pairs(explosions) do
		local lt = LevelTime()
		local len = v.et - v.st
		local dt = (lt - v.st)/len
		local r = v.r * dt
		
		if(dt <= 1) then
			genFireSphere(v.pos,r,1-dt)
		end
		
		if(lt > v.et) then
			explosions[k].rem = true
		end
	end
	for k,v in pairs(table.Copy(explosions)) do
		if(explosions[k] and explosions[k].rem) then
			table.remove(explosions,k)
		end
	end
end
hook.add("Draw3D","cl_explosion",d3d)