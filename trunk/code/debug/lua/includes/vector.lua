function vAdd(v1,v2)
	return v1 + v2
end

function vSub(v1,v2)
	return v1 - v2
end

function vMul(v1,v2)
	return v1 * v2
end

function vAbs(v)
	local out = Vector()
	out.x = math.abs(v.x)
	out.y = math.abs(v.y)
	out.z = math.abs(v.z)
	return out
end

--[[function Vector(x,y,z)
	x = x or 0
	y = y or 0
	z = z or 0
	return {x=x,y=y,z=z}
end]]

function Vectorv(tab)
	return Vector(tab.x,tab.y,tab.z) --{x=tab.x,y=tab.y,z=tab.z}
end