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
	if(_CG == nil) then return end
	vpos = Vectorv(pos)
	vang = Vectorv(ang)
	vfovx = _CG.refdef.fov_x
	vfovy = _CG.refdef.fov_y
	CallHook("CalcView",pos,ang,_CG.refdef.fov_x,_CG.refdef.fov_y)

	local def = {
		origin = vpos,
		angles = vang,
		fov_x = vfovx,
		fov_y = vfovy,
	}
	render.SetRefDef(def)
end