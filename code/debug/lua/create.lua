function vectoangles(v)
	local yaw = ( (math.atan2 ( v.y, v.x ) * 180) / math.pi );
	local forward = math.sqrt ( v.x*v.x + v.y*v.y );
	local pitch = ( (math.atan2(v.z, forward) * 180) / math.pi );
	local roll = 0
	
	v.x = pitch * -1
	v.y = yaw
	v.z = roll
	return v
end

function etest(ent)
	local test = CreateEntity("testent")
	test:SetPos(Vector(433.611694,-469.85690,475.6014404))
	if(ent and ent:IsPlayer()) then
		local forward = VectorForward(ent:GetAimAngles())
		local startpos = ent:GetMuzzlePos()
		local ignore = ent
		local mask = 1 --Solid
		
		local endpos = vAdd(startpos,vMul(forward,16))
		local res = TraceLine(startpos,endpos,ignore,mask)
	
		if(res.hit) then
			local ang = vMul(res.normal,360) -- Needs To Be Big Number For Networking
			test:SetPos(vAdd(res.endpos,vMul(res.normal,2)))
			test:SetVelocity(vMul(res.normal,308))
			test:SetAngles(ang)
		else
			local ang = vMul(forward,360) -- VectorToAngles(
			test:SetVelocity(vMul(forward,308))
			test:SetAngles(ang)
			test:SetPos(res.endpos)
			local ang2 = vectoangles(forward)
			test:SetAngles(ang2)
			print(ang2.x .. " " .. ang2.y .. " " .. ang2.z .. "\n")
		end
	end
	
	local callback = function(ent,other,trace)
		local tab = ent:GetTable()
		if(!tab.notouch) then
			ent:SetPos(vAdd(trace.endpos,Vector(0,0,2)))
			ent:SetTrType(TR_LINEAR)
			ent:SetVelocity(vMul(trace.normal,30))
			ent:SetNextThink(LevelTime() + 1000)
			local ang1 = ent:GetAngles()
			local ang2 = vectoangles(trace.normal)
			ang2.x = ang2.x + 90
			ang2.y = ang1.y
			ent:SetAngles(ang2)
			print("Touch\n")
			tab.notouch = true
		end
	end
	test:SetCallback(ENTITY_CALLBACK_TOUCH,callback)
	
	local callback2 = function(ent)
		--if(ent:GetTable().rotate) then
			ent:SetPos(ent:GetPos())
			ent:SetTrType(TR_STATIONARY)
		--end
		--ent:SetNextThink(LevelTime())
	end
	test:SetCallback(ENTITY_CALLBACK_THINK,callback2)

	Timer(5,function() if(test != nil) then test:Remove() end end)
end
concommand.Add("etest",etest)