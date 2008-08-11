function etest(ent)
	local test = CreateEntity("weapon_rocketlauncher")
	--test:SetPos(Vector(433.611694,-469.85690,475.6014404))
	if(ent and ent:IsPlayer()) then
		local forward = VectorForward(ent:GetAimVector())
		local startpos = ent:GetMuzzlePos()
		local ignore = ent
		local mask = 1 --Solid
		
		local endpos = vAdd(startpos,vMul(forward,16000))
		local res = TraceLine(startpos,endpos,ignore,mask)
	
		if(res.hit) then
			test:SetPos(vAdd(res.endpos,vMul(res.normal,2)))
			test:SetVelocity(vMul(res.normal,308))
		else
			test:SetPos(res.endpos)
		end
	end

	Timer(5,function() if(test != nil) then test:Remove() end end)
end
concommand.Add("etest",etest)