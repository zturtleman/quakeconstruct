local marks = {}
local texture1 = LoadShader("viewBloodBlend"); --bloodMark
local texture2 = LoadShader("bloodTrail");
local texture3 = LoadShader("bloodMark");
local MARK_TIME = 3000
local resetnext = false
local health = 100
local lastTarget = LocalPlayer()

local modTypes = {}
modTypes[MOD_SHOTGUN] = texture1
modTypes[MOD_GAUNTLET] = texture3
modTypes[MOD_MACHINEGUN] = texture1
modTypes[MOD_GRENADE] = texture3
modTypes[MOD_GRENADE_SPLASH] = texture2
modTypes[MOD_ROCKET] = texture3
modTypes[MOD_ROCKET_SPLASH] = texture2
modTypes[MOD_PLASMA] = texture3
modTypes[MOD_PLASMA_SPLASH] = texture2
modTypes[MOD_RAILGUN] = texture1
modTypes[MOD_LIGHTNING] = texture2
modTypes[MOD_BFG] = texture3
modTypes[MOD_BFG_SPLASH] = texture2
modTypes[MOD_WATER] = texture2 --waterthing?
modTypes[MOD_SLIME] = texture2 --slimething?
modTypes[MOD_LAVA] = texture2 --lavathing?
modTypes[MOD_CRUSH] = texture2 --crushthing?
modTypes[MOD_TELEFRAG] = texture3
modTypes[MOD_FALLING] = texture2
modTypes[MOD_SUICIDE] = texture3
modTypes[MOD_TRIGGER_HURT] = texture3
modTypes[MOD_GRAPPLE] = texture1

local function drand(n)
	return math.random(-n,n)/2
end

local function mark(x,y,dmg,spread,method)
	local t = modTypes[method]
	local tx = 2
	local spr = Sprite(t)
	if(t == texture1) then 
		dmg = dmg + math.random(0,20)
		tx = 3
		tx = tx - math.random(0,10)/5
	end
	spr:SetPos(x+drand(spread),y+drand(spread))
	spr:SetRotation(math.random(360))
	
	local dx = math.abs(320 - x) / 320
	local dy = math.abs(240 - y) / 240
	local df = (math.sqrt(dx*dx + dy*dy) * 2) + .25
	
	print(df .. "\n")
	
	local x2,y2 = spr:GetPos()
	local spr2 = Sprite(t)
	spr2:SetPos(x2,y2)
	spr2:SetRotation(math.random(360))
	table.insert(marks,{spr2,dmg+10,LevelTime(),false,0,((MARK_TIME/tx)+10000) * df,true})
	table.insert(marks,{spr,dmg,LevelTime(),false,0,(MARK_TIME/tx) * df})
end

local function project(pos)
	local dir = VectorNormalize(vSub(pos,_CG.refdef.origin))
	
	local right = DotProduct (dir, _CG.refdef.right );
	local up = DotProduct (dir, _CG.refdef.up );

	return right,up
end

local function processDamage(attacker,pos,dmg,death,waslocal,wasme,hp)
	if(waslocal) then
		health = hp
		if(attacker) then
			local spread = 40
			local x,y = project(vAdd(pos,Vector(0,0,20)))
			x = 320 - 320 * x
			y = 240 - 240 * y
			if(death == MOD_SHOTGUN) then
				spread = 200
			end
			--[[if(!death == MOD_MACHINEGUN) then
				if(wasme or death == MOD_SUICIDE) then
					x = 320
					y = 240
					spread = 200
				end
			end]]
			mark(x,y,dmg,spread,death)
		else
			if(death == MOD_FALLING) then
				mark(320,560,dmg*10,50,death)
				mark(100,560,dmg*8,50,death)
				mark(540,560,dmg*8,50,death)
			else
				mark(320,240,dmg,0,death)
			end
		end
	end
end

local function draw2d()
	for k,v in pairs(marks) do
		local t = v[3]
		local spr = v[1]
		local dmg = v[2]
		local dt = 1 - (LevelTime() - t) / v[6]
		--if(health <= 0) then dt = 1 end
		if(dt > 0) then
			local targ = (100+(dmg*2)) - dt * 20
			v[5] = v[5] + (targ - v[5])*.4
			spr:SetRadius(v[5])
			if(spr:GetShader() == texture3) then
				spr:SetColor(.8,.4,.1,dt/1.4)
			elseif(spr:GetShader() == texture1) then
				spr:SetColor(.8,.4,0,dt/1.4)
				spr:Draw()
			else
				spr:SetColor(1,1,1,dt/1.4)
			end
			if(v[7]) then
				spr:SetShader(texture3)
				spr:SetColor(.6,.4,.1,dt/3)
			end
			spr:Draw()
			--spr:SetShader(texture3)
			--spr:SetColor(1,1,1,dt/5)
			--spr:SetRadius(v[5] + ((1-dt)*50))
		else
			v[4] = true
		end
	end
	for k,v in pairs(marks) do
		if(v[4] == true) then
			table.remove(marks,k)
		end
	end
	if(lastTarget != LocalPlayer()) then
		health = 100
		marks = {}	
		lastTarget = LocalPlayer()
	end
end

local function respawn()
	health = 100
	marks = {}
end
hook.add("Draw2D","cl_blah",draw2d)
hook.add("Damaged","cl_blah",processDamage)
hook.add("Respawned","cl_blah",respawn)