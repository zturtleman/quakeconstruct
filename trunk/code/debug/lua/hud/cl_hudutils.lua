local flashes = {}
local flash = LoadShader("flareShader")

function hud_flasheffect(x,y,size,vx,vy)
	table.insert(flashes,{x=x,y=y,size=size,t=1,vx=vx,vy=vy})
end

function hud_drawFlashes()
	for k,v in pairs(flashes) do
		if(v.t > 0) then
			draw.SetColor(v.t,v.t,v.t,1)
			draw.Rect(v.x-v.size/2,v.y-v.size/4,v.size,v.size/2,flash)
			draw.Rect(v.x-v.size/4,v.y-v.size/2,v.size/2,v.size,flash)
			v.t = v.t - 0.1
			v.size = v.size - 10
			if(v.vx) then v.x = v.x + v.vx end
			if(v.vy) then v.y = v.y + v.vy end
		else
			v.remove = true
		end
	end
	for k,v in pairs(table.Copy(flashes)) do
		if(v.remove) then table.remove(flashes,k) end
	end
end

function hud_field(x,y,v,num,m,color,size)
	draw.SetColor(color[1],color[2],color[3],color[4])
	if(num) then
		local blink = (math.fmod(CurTime(),.4) > .2)
		if(v > 100) then draw.SetColor(1,1,1,1) end
		if(v <= 0 and m != "Health" and m != "Ammo") then return y end
		if(v < 0 and m != "Health" and m != "Armor") then return y end
		if(v <= 25 and m != "Armor" and m != "Ammo" and blink) then 
			draw.SetColor(1,0,0,1) 
		end
		if(v <= 5 and m != "Armor" and blink) then 
			draw.SetColor(1,0,0,1) 
		end
		if(v <= 0 and m == "Health") then
			draw.SetColor(1,0,0,1) 
		end
	end
	y = y - size
	local str = "" .. v
	if(m != nil) then str = m .. ": " .. v end
	local nx = 10 + size*string.len(str)
	
	draw.Text(x,y,str,size,size)
	return y
end