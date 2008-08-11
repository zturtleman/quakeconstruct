ROCKET_GUIDESTRENGTH = 0.5
ROCKET_VELOCITY = 700

local function Guided()
	for k,v in pairs(GetEntitiesByClass("rocket")) do
		local parent = v:GetParent()
		local tab = GetEntityTable(v)
		
		if(parent) then
			if(parent:GetInfo()["health"] <= 0) then
				tab.disarmed = true
			end
			if(!tab.disarmed) then
				local vel = v:GetVelocity()
				local forward = VectorForward(parent:GetAimVector())
				local startpos = parent:GetMuzzlePos()
				local ignore = parent
				local mask = 1 --Solid
				
				local endpos = vAdd(startpos,vMul(forward,16000))
				local res = TraceLine(startpos,endpos,ignore,mask)
				
				local delta = vSub(res.endpos,v:GetPos())
				delta = VectorNormalize(delta)
				
				local normal = VectorNormalize(vel)
				normal = vAdd(normal,vMul(vSub(delta,normal),ROCKET_GUIDESTRENGTH))
				
				v:SetVelocity(vMul(normal,ROCKET_VELOCITY))
			end
		end
	end
end
hook.add("Think","GuidedMissileStuff",Guided)