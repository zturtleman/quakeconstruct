for k,v in pairs(GetAllEntities()) do
	print(v:Classname() .. "\n")
	if(string.find(v:Classname(),"func_door")) then
		print("Door\n")
		v:Fire()
	end
end