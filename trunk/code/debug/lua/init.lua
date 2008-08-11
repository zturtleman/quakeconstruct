--require "create"

print("INIT\n")
--[[local function gp(ent,cmd,args)
	if(ent && ent:GetPos()) then
		local p = ent:GetPos()
		print(p.x .. " " .. p.y .. " " .. p.z .. "\n")
	end
end
concommand.Add("GetPos",gp)]]

function pval()
	print("===" .. val .. "===\n")
	for i=0, 31 do
		local n = bitShift(1,-i)
		if(bitAnd(val,n) != 0) then
			print(i .. "\n")
		else
			print("----\n")
		end
	end
end

function shiftIn(v)
	local n = bitShift(1,-v)
	val = bitOr(n,val)
end

function shiftOut(v)
	local n = bitShift(1,-v)
	val = bitXor(n,val)
end

local val = 0;
shiftIn(0)
shiftIn(1)
shiftIn(3)
shiftIn(6)
shiftIn(8)
shiftIn(16)
shiftIn(30)
shiftIn(31)
shiftOut(16)
pval()