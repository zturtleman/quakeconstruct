--SendScript("lua/cl_debugbar.lua")
--SendScript("lua/cl_marks.lua")
--includesimple("sctest")

--SendScript("lua/vampiric_cl.lua")
--SendScript("lua/includes/scriptmanager.lua")

local encoded = base64.enc("This is a test of the base64 encoder and decoder respectively.")
print(encoded .. "\n")

local decoded = base64.dec(encoded)
print(decoded .. "\n")

function makeMessage()
	local msg = Message()
	message.WriteLong(msg,1)
	message.WriteString(msg,base64.enc("I Rock!"))
	message.WriteFloat(msg,100.0)
	message.WriteFloat(msg,120.5)
	SendDataMessage(msg)
end
concommand.Add("msgtest",makeMessage)

local function writeVector(msg,v)
	message.WriteFloat(msg,v.x)
	message.WriteFloat(msg,v.y)
	message.WriteFloat(msg,v.z)
end

function ItemPickup(item, other, trace, itemid)
	if(item and other and itemid) then
		print("Pickup: " .. item:Classname() .. " | " .. other:Classname() .. " " .. itemid .. "\n")
		
		local v = item:GetPos()
		local v2 = other:GetVelocity()
		
		local msg = Message()
		message.WriteLong(msg,2)
		message.WriteString(msg,item:Classname())
		writeVector(msg,v)
		writeVector(msg,v2)
		message.WriteLong(msg,itemid)
		SendDataMessage(msg)
	end
	--return false
end
hook.add("ItemPickup","init",ItemPickup)