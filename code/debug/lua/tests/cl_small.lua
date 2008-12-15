function test() 
		--blash
		
end

local function dr2()
	local c = (math.sin(LevelTime()/1000)*100) + 100
	c = c / 255
	draw.SetColor(1,0,0,c)
	draw.Rect(0,0,30,30)
end
hook.add("Draw2D","cl_small",dr2)
--This is CL_SMALL

--blash1
--s
;