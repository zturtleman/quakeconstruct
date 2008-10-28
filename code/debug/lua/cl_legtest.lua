local torsosub = 156 - 94
local leganim = Animation(190 - torsosub,11,20)
local legidle = Animation(258 - torsosub,10,15)
local torsoanim = Animation(156,1,50)
leganim:SetType(ANIM_ACT_LOOP_LERP)
legidle:SetType(ANIM_ACT_LOOP_LERP)
local function d3d()
	local pos = _CG.refdef.origin --LocalPlayer():GetPos()
	
	pos.z = LocalPlayer():GetPos().z
	
	local legs = RefEntity()
	local f = _CG.refdef.forward
	local ang = VectorToAngles(f)
	local vlen = VectorLength(LocalPlayer():GetTrajectory():GetDelta())
	
	ang.x = 0
	ang.z = 0
	
	f = AngleVectors(ang)
	local off = vMul(f,10)

	legs:SetPos(vSub(pos,off)) --Vector(652,1872,24)
	legs:SetPos2(vSub(pos,off))
	legs:SetColor(1,1,1,1)
	legs:SetModel(LocalPlayer():GetInfo().legsModel)
	legs:SetSkin(LocalPlayer():GetInfo().legsSkin)
	legs:SetAngles(ang)
	
	if(vlen > 100) then
		leganim:SetRef(legs)
		leganim:Animate()
	else
		legidle:SetRef(legs)
		legidle:Animate()
	end
	
	legs:Render()
end
hook.add("Draw3D","cl_legtest",d3d)