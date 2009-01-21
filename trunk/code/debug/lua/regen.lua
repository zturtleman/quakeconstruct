local function clThink(client)
	local tab = GetEntityTable(client)
	if(tab) then
		tab.lastrecharge = tab.lastrecharge or LevelTime()
		if(tab.lastrecharge < LevelTime()) then
			local myHp = client:GetInfo().health
			local vel = VectorLength(client:GetVelocity())/100
			vel = math.max(5-vel,1)
			if(myHp < 100 and myHp > 0) then
				client:SetInfo(PLAYERINFO_HEALTH,myHp + 1)
			end
			tab.lastrecharge = LevelTime() + 100/vel --5 hp every 2 seconds when standing still
		end
	end
end
hook.add("ClientThink","regenexample",clThink)