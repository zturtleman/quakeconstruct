function GAME:Think()
	for k,v in pairs(GetAllPlayers()) do
		if(v:IsPlayer() and v:GetHealth() > 0) then
			--v:SetPowerup(PW_FLIGHT,POWERUP_FOREVER)
			local bits = v:GetInfo()["buttons"];
			--print(bits .. "\n")
			if(bitAnd(bits,16) != 0) then 
			
			end
			
			local f,r,u = AngleVectors(v:GetAimAngles())
			--v:SetVelocity(f * 500)
		end
	end
end