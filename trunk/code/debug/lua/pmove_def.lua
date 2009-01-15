if(SERVER) then
	downloader.Add("lua/pmove_def.lua")
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
	--PM_FlyMove()
	--PM_AirMove()
	
	return true
end
hook.add("PlayerMove","pmove_def.lua",PlayerMove)