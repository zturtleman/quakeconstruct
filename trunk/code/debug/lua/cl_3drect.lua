local vorigin = Vector()
local vright = Vector()
local vdown = Vector()
local vdiag = Vector()
local on = false

local function d3d()
	if(!on) then return end

	--render.Quad(vorigin,vright,vdiag,vdown,nil,1,1,1,.2)
	
	draw.Start3D(vorigin,vright,vdown)
	
	draw.SetColor(1,1,1,.1)
	draw.Rect(10,10,620,460)
	
	
	DrawUI()
	
	draw.End3D()
end
hook.add("Draw3D","cl_3drect",d3d)

local function use(s)
	local pt = PlayerTrace()
	local pos = pt.endpos
	local normal = pt.normal
	local f,r,u = AngleVectors(VectorToAngles(normal))
	
	vorigin = pos + ((r*40) + (u*40))
	vright = pos - ((r*40) - (u*40))
	vdown = pos - ((u*40) - (r*40))
	vdiag = pos - ((r*40) + (u*40))
	on = true
end
hook.add("Use","cl_3drect",use)