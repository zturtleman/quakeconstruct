--[[for k,v in pairs(GetAllEntities()) do
	print(v:Classname() .. "\n")
	if(string.find(v:Classname(),"func_door")) then
		print("Door\n")
		v:Fire()
	end
end]]

local tab = FindEntities("Classname","trigger_multiple")
for k,v in pairs(tab) do
	local tn = v:GetTarget()
	if(tn != nil) then
		print("target " .. tn .. "\n")
	else
		print("target\n")
	end
end

for k,v in pairs(GetAllEntities()) do
	local tn = v:GetTargetName()
	if(tn) then
		print("[" .. v:Classname() .. "] " .. tn .. "\n")
	end
end

local function fire(p,c,a)
	if(type(a[1]) != "string") then return end
	local tab = FindEntities("GetTargetName",a[1])
	for k,v in pairs(tab) do
		v:Fire()
		print("Fired: " .. v:Classname() .. "\n")
	end
end
concommand.add("efire",fire)