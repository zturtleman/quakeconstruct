local function loadINI(f)
	local file = io.open("C:/Quake3/baseq3/" .. f, "r")
	if(file != nil) then
		local lines = 0
		local content = ""
		for line in file:lines() do
			content = content .. line .. "\n"
		end
		file:close()
		return content
	else
		error("File not found: '" .. f .. "'.")
		return 
	end
	local txt = packRead(f)
	if(txt != nil) then
		error("File not found: '" .. f .. "'.")
		return txt
	end
	return 
end

function LoadFont(ini)
	local f = loadINI(ini)
	if(!f) then f = loadINI(ini .. ".ini") end
	if(!f) then return nil end
	local texture = string.sub(ini,0,string.len(ini) - 3) .. "tga"
	util.ClearImage(texture)
	local data = 
	[[{
		{
			map ]] .. texture .. [[
			blendFunc blend
			rgbGen vertex
			alphaGen vertex
		}
	}]]
	local tab = string.Explode("\n",f)
	local shader = CreateShader("f",data)
	local title = tab[1]
	local sprite = AnimSprite(shader,16,16,30,0)
	local spacings = {}
	for k,v in pairs(tab) do
		if(k > 1) then
			local eq = string.find(v,"=")
			if(eq) then
				local index = string.sub(v,0,eq-1)
				local value = string.sub(v,eq+1,string.len(v))
				spacings[tonumber(index)+1] = tonumber(value)
			end
		end
	end
	tab = nil
	
	local draw = function(x,y,str,w,h)
		local i=0
		local kern = 5
		local lead = 1
		for k,v in pairs(string.ToTable(str)) do
			local b = string.byte(v)+1
			sprite:SetFrame(b-1)
			x = x + (spacings[b]+kern)*(w/40)
			sprite:SetPos(x,y+(h/1.25))
			sprite:SetSize(w,h)
			sprite:DrawAnim()
			x = x + (spacings[b]+kern)*(w/40)
		end
		return x
	end
	
	return draw,title,sprite,spacings
end