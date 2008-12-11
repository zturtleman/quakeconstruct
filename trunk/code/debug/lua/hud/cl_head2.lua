local animsets = {}
local lerps = {}

local blood1 = LoadShader("viewBloodFilter_HQ")
local blood2 = LoadShader("dissolve")

local function parseSingleAnim(animtab,line)
	local args = string.Explode("\t",line)
	local temp = {}
	for k,v in pairs(args) do
		v = string.Replace(v," ","")
		local fc = firstChar(v)
		local n = tonumber(fc)
		if(fc == "/") then
			v = string.sub(v,3,string.len(v))
			if(lastChar(v) == "\r") then
				v = string.sub(v,0,string.len(v)-1)
			end
			--print("Anim:" .. v .. "||\n")
			animtab[v] = Animation(temp[1],temp[2],temp[4])
			--animtab[v]:Play()
			return
		end
		if(n) then
			--print(tonumber(v) .. "\n")
			table.insert(temp,tonumber(v))
		end
	end
end

local function fixLegs(tab)
	local torsoStart = 9999
	local torsoEnd = 0
	animtab = table.Copy(tab)
	for k,v in pairs(animtab) do
		if(string.find(k,"TORSO")) then
			if(v:GetStart() < torsoStart) then
				torsoStart = v:GetStart()-1
			end
			if(v:GetStart() > torsoEnd) then
				torsoEnd = v:GetStart()
			end
		end
	end
	for k,v in pairs(animtab) do
		if(string.find(k,"LEGS")) then
			local start = v:GetStart()
			local len = v:GetLength()
			v:SetStart(start - (torsoEnd - torsoStart))
			v:SetEnd(v:GetLength())
			--print("Fixed Leg Anim: " .. k .. "\n")
			--print("- " .. start .. " " .. len .. "\n")
			--print("- " .. v:GetStart() .. " " .. v:GetLength() .. "\n")
			animtab[k] = v
		end
	end
	return animtab
end

local function parseAnims(txt)
	local animtab = {}
	local list = string.Explode("\n",txt)
	for k,v in pairs(list) do
		if(v != "\r" and firstChar(v) != "/" and 
			string.find(v,"footsteps") == nil and
			string.find(v,"sex") == nil) then
			parseSingleAnim(animtab,v)
		end
	end
	return fixLegs(animtab)
end

local function loadAnimations(name)
	local path = "models/players/" .. name .. "/animation.cfg"
	local txt = packRead(path)
	if(txt == nil) then 
		error("Could Not Read File: " .. f .. ".\n") 
		return {} 
	end
	
	return parseAnims(txt)
end

local function getAnims(name)
	animsets[name] = animsets[name] or loadAnimations(name)
	return animsets[name]
end

local function getRefs()
	local inf = LocalPlayer():GetInfo()
	local head = RefEntity()
	local body = RefEntity()
	local legs = RefEntity()
	
	head:SetModel(inf.headModel)
	body:SetModel(inf.torsoModel)
	legs:SetModel(inf.legsModel)
	
	head:SetSkin(inf.headSkin)
	body:SetSkin(inf.torsoSkin)
	legs:SetSkin(inf.legsSkin)
	
	return head,body,legs,inf.modelName
end

local function animateLegs(legs,name)
	local anims = getAnims(name)
	local idlebottom = anims["LEGS_IDLECR"]

	if(idlebottom) then
		idlebottom:SetRef(legs)
		idlebottom:SetType(ANIM_ACT_LOOP_LERP)
		idlebottom:Play()
		idlebottom:Animate()
		--print(idlebottom:GetFrame() .. "\n")
	end
end

local function animateBody(body,name)
	local anims = getAnims(name)
	local idletop = anims["TORSO_STAND"]
	
	if(idletop != nil) then
		idletop:SetRef(body)
		idletop:SetType(ANIM_ACT_LOOP_LERP)
		idletop:Play()
		idletop:Animate()
	end
end

local function renderScene(x,y,size,viewpos,aimat)
	local aim = VectorNormalize(aimat - viewpos)
	local refdef = {}
	
	aim = VectorToAngles(aim)
	
	refdef.x = x
	refdef.y = y
	refdef.width = size
	refdef.height = size
	refdef.origin = viewpos
	
	refdef.angles = aim
	
	local b, e = pcall(render.RenderScene,refdef)
	if(!b) then
		print("^1" .. e .. "\n")
	end
end

local function positionObjects(head,legs,body)
	legs:SetPos(Vector(0,0,-18))
	head:SetAngles(Vector())
	legs:SetAngles(Vector())
	body:SetAngles(Vector())
	body:PositionOnTag(legs,"tag_torso")
	head:PositionOnTag(body,"tag_head")
end

local function tagLocation(ref,tag)
	local r = RefEntity()
	r:PositionOnTag(ref,tag)
	return r:GetPos()
end

local function blood(ref,hp)
	if(hp > 100) then hp = 100 end
	if(hp < 0) then hp = 0 end
	ref:SetColor(1,1,1,1 - (hp/100))
	--ref:SetShader(blood1)
	--ref:Render()
	ref:SetShader(blood2)
	ref:Render()
end

function drawHead(x,y,ICON_SIZE,hp)
	local head,body,legs,name = getRefs()
	
	local dtag = tagLocation(legs,"tag_torso") - legs:GetPos()
	dtag = VectorLength(dtag)
	
	local dtag2 = tagLocation(body,"tag_head") - body:GetPos()
	dtag2 = VectorLength(dtag2)
	
	animateBody(body,name)
	animateLegs(legs,name)
	
	positionObjects(head,legs,body)

	
	render.CreateScene()
	
	legs:Render()
	body:Render()
	head:Render()
	
	blood(legs,hp)
	blood(body,hp)
	blood(head,hp)
	
	print(dtag .. "\n")
	
	local pos = head:GetPos()
	local lpos = legs:GetPos() + Vector(50,0,dtag)
	
	pos.z = lpos.z
	
	renderScene(x,y,ICON_SIZE, lpos,pos)
end

--loadAnimations(LocalPlayer():GetInfo().modelName)