if(SERVER) then
	downloader.add("lua/pmove.lua")
end

function PlayerMove(pm,walk,forward,right)
	--PM_Accelerate(Vector(0,0,1),4,10)
	if(pm:WaterLevel() > 1) then
		PM_WaterMove()
	elseif(walk) then
		PM_WalkMove()
	else
		PM_AirMove()
	end
	
	if(SERVER) then
		--print(scale .. "\n")
	end
	
	return true
end
hook.add("PlayerMove","pmove.lua",PlayerMove)

--[[if(SERVER) then
	function ClientThink(pl)
		pl:SetVelocity(pl:GetVelocity() + Vector(0,0,-50))
	end
	hook.add("ClientThink","pmove.lua",ClientThink)
end]]