local sounds = {}

local function loaded(str,i,compressed)
	print("Loaded Sound: " .. str .. " | " .. i .. "\n")
	if(i != 0) then
		table.insert(sounds,{str,i,compressed})
	end
end
hook.add("SoundLoaded","sounds",loaded)

function LoadSound(str,compressed)
	for k,v in pairs(sounds) do
		if(v[1] == str) then
			print("Loaded Sound From Cache: " .. v[1] .. "(" .. v[2] .. ")\n")
			return v[2]
		end
	end
	return __loadsound(str,compressed)
end