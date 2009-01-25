//__DL_BLOCK
if(SERVER) then
	--downloader.add("lua/pmove.lua")
end

//__DL_UNBLOCK

local x = gOR(CONTENTS_SOLID,CONTENTS_PLAYERCLIP)

function PlayerMove(pm,walk,forward,right)
	--PM_Accelerate(Vector(0,0,1),4,10)
	--if(SERVER) then print("Set: " .. x .. "\n") end
	pm:SetMask(x)
	--if(SERVER) then print("Get: " .. pm:GetMask() .. "\n") end
	
	if(pm:GetType() == PM_NOCLIP) then
		PM_NoclipMove()
		return
	end
	
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