local tp = Vector()

local function d2d()
	local c = 0
	for k,v in pairs(GetEntitiesByClass("item")) do
		if(VectorLength(v:GetPos() - _CG.viewOrigin) < 1000) then
			local ts,clip = VectorToScreen(v:GetPos())
			local index = v:GetModelIndex()
			local n = util.GetItemName(index)
			ts.z = -ts.z
			if(clip and ts.z < 1000) then
				ts.z = 1 - (ts.z / 1000)
				local v = n or index
				draw.SetColor(0,.1,.4,ts.z)
				draw.Rect(ts.x-5,ts.y-5,(10*string.len(v)) + 10,20)
				draw.SetColor(1,1,1,ts.z)
				draw.Text(ts.x,ts.y,v,10,10)
				c = c + 1
			end
		end
	end
	draw.SetColor(1,1,1,1)
	draw.Text(0,300,"Linked: " .. c,10,10)
end
hook.add("Draw2D","cl_junk",d2d)

local function event(entity,event,pos,dir)
	if(event == EV_BULLET_HIT_WALL) then
		tp = pos
	end
end
hook.add("EventReceived","vecdefine",event)