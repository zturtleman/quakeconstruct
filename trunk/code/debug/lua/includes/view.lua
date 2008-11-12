local vpos = Vector()
local vang = Vector()
local vfovx = 0
local vfovy = 0
function ApplyView(pos,ang,fovx,fovy)
	pos = pos or Vector()
	ang = ang or Vector()
	fovx = fovx or 0
	fovy = fovy or 0
	
	vpos = vpos + (pos - vpos)
	vang = vang + getDeltaAngle3(ang,vang)
	vfovx = vfovx + fovx
	vfovy = vfovy + fovy
end

function _ViewCalc(pos,ang,fovx,fovy)
	vpos = Vectorv(pos)
	vang = Vectorv(ang)
	vfovx = fovx
	vfovy = fovy
	CallHook("CalcView",pos,ang,fovx,fovy)

	local def = {
		origin = vpos,
		angles = vang,
	}
	render.SetRefDef(def)
end