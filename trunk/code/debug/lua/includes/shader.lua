local shaders = {}

local function loaded(str,i,nomip)
	--print("Loaded Shader: " .. str .. " | " .. i .. "\n")
	if(i != 0) then
		table.insert(shaders,{str,i,nomip})
	end
end
hook.add("ShaderLoaded","shaders",loaded)

function LoadShader(str,nomip)
	for k,v in pairs(shaders) do
		if(v[1] == str) then
			--print("Loaded Shader From Cache: " .. v[1] .. "(" .. v[2] .. ")\n")
			return v[2]
		end
	end
	return __loadshader(str,nomip)
end