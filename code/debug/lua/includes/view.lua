local vpos = Vector()
local vang = Vector()
local vfovx = 0
local vfovy = 0
function ApplyView(pos,ang,fovx,fovy)
	pos = pos or Vector()
	ang = ang or Vector()
	fovx = fovx or vfovx
	fovy = fovy or vfovy
	
	vpos = vpos + (pos - vpos)
	vang = vang + getDeltaAngle3(ang,vang)
	vfovx = vfovx + (fovx - vfovx)
	vfovy = vfovy + (fovy - vfovy)
end

function _ViewCalc(pos,ang,fovx,fovy)
	if(_CG == nil) then return end
	vpos = Vectorv(pos)
	vang = Vectorv(ang)
	vfovx = fovx
	vfovy = fovy
	CallHook("CalcView",pos,ang,fovx,fovy)
	
	local def = {
		origin = vpos,
		angles = vang,
		fov_x = vfovx,
		fov_y = vfovy,
	}
	render.SetRefDef(def)
end