local models = {}

local function loaded(str,i)
	print("Loaded Model: " .. str .. " | " .. i .. "\n")
	if(i != 0) then
		table.insert(models,{str,i})
	end
end
hook.add("ModelLoaded","models",loaded)

function LoadModel(str)
	for k,v in pairs(models) do
		if(v[1] == str) then
			--print("Loaded Model From Cache: " .. v[1] .. "(" .. v[2] .. ")\n")
			return v[2]
		end
	end
	return __loadmodel(str)
end