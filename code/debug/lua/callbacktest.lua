function playerCallbackTest(cl)
	local touch = function(ent,other,trace)
		if(ent and other) then
			local entName = ent:Classname()
			local otherName = other:Classname()
			if(entName == "player") then entName = ent:GetInfo()["name"] end
			if(otherName == "player") then otherName = ent:GetInfo()["name"] end
			
			print("Entities Touching: ")
			print(entName .. "^7->" .. otherName .. "\n")
			
			if(trace.endpos) then
				local traceto = vAdd(ent:GetPos(),{x=0,y=0,z=30})
				local res = TraceLine(ent:GetPos(),traceto,ent)
				print(res.fraction .. "\n")
				ent:AddEvent(EV_MISSILE_HIT,0)
				--CreateTempEntity(res.endpos,EV_DEATH1)
			end
		end
	end
	cl:SetCallback(ENTITY_CALLBACK_TOUCH, touch)
end