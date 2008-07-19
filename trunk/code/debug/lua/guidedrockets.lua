local function r()
	return math.random(-100,100)/100
end

local function rv(v)
	local t = {}
	t.x = r()*v
	t.y = r()*v
	t.z = r()*v
	return t
end

local function Guided()
	for k,v in pairs(GetEntitiesByClass({"bfg","rocket","grenade"})) do
		local parent = v:GetParent()
		local tab = GetEntityTable(v)
		tab.nextrv = tab.nextrv or CurTime()
		
		if(parent) then
			if(parent:GetInfo()["health"] <= 0) then
				tab.dead = true
			end
			if(!tab.dead) then
				
				local vel = v:GetVelocity()
				local forward = VectorForward(parent:GetAimVector())
				local startpos = parent:GetMuzzlePos()
				local endpos = vAdd(startpos,vMul(forward,16000))
				local res = TraceLine(startpos,endpos,parent)
				
				if(res.entity != nil) then
					--res.entity != parent
					if(res.entity:IsPlayer()) then
						if(!tab.lockon) then tab.lockon = res.entity end
						--print("LOCKON\n")
						parent:SendMessage("Locked On",true)
					end
				end
				
				if(tab.lockon) then
					res.endpos = tab.lockon:GetPos()
					if(tab.lockon:GetInfo()["health"] <= 0) then
						tab.lockon = nil
					end
				end	
				
				local delta = vSub(res.endpos,v:GetPos())
				local tdist = VectorLength(delta)
				delta = VectorNormalize(delta)
				
				if(tab.nextrv <= CurTime()) then
					tab.rv = rv(.2)
					tab.nextrv = CurTime() + 0.3
				end
				
				if(tdist > 500) then
					--delta = vAdd(delta,tab.rv)
				end
				
				local normal = VectorNormalize(vel)
				normal = vAdd(normal,vMul(vSub(delta,normal),0.2))
				
				if(!tab.successive) then
					--normal = vAdd(normal,rv(0.4))
					if(v:Classname() == "grenade") then
						local callback = function(ent,other,trace)
							if(!tab.dead) then
							CreateTempEntity(vAdd(ent:GetPos(),{x=0,y=0,z=10}),EV_SCOREPLUM)
								tab.dead = true
							end
						end
						
						v:SetCallback(ENTITY_CALLBACK_TOUCH,callback)
					end
					tab.successive = true
				end
				
				if(tab.lockon) then
					vel = vMul(normal,800)
				else
					vel = vMul(normal,800)
				end
				v:SetVelocity(vel)
			end
		end
	end
end
hook.add("Think",Guided)