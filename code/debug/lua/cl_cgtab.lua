local CHAR_TAB = "   "

local function draw2D()
	local i=0
	draw.SetColor(1,1,1,1)
	for k,v in pairs(_CG) do
		if(type(v) == "table") then
			draw.Text(0,100 + (10*i),k .. "[" .. #v .. "]",10,10)
			i = i + 1
			--[[for x,y in pairs(v) do
				draw.Text(0,100 + (10*i),CHAR_TAB .. x .. " - " .. y,10,10)
				i = i + 1
			end]]
		else
			draw.Text(0,100 + (10*i),k .. " - " .. v,10,10)
			i = i + 1
		end
	end
	_CG.viewOrigin.z = _CG.viewOrigin.z + 530
end
hook.add("Draw2D","cgtab",draw2D)