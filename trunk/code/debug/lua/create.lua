function etest(ent)
	local test = CreateEntity("weapon_rocketlauncher")
	--test:SetPos(Vector(433.611694,-469.85690,475.6014404))
	if(ent and ent:GetPos()) then
		test:SetPos(vAdd(ent:GetPos(),Vector(0,0,120)))
	end

	Timer(5,function() test:Remove() end)
end
concommand.Add("etest",etest)