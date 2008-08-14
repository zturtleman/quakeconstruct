--require("cg_marks")

local texts = {}
local texture = LoadShader("gfx/2d/colorbar.tga");

function DebugBarString(txt)
	table.insert(texts,{txt,1})
end

local function draw2D()
	if(#texts > 0) then
		local msize = 0;
		for k,v in pairs(texts) do
			local n = string.len(v[1])*10
			msize = math.max(msize,n)
		end
		draw.SetColor(.8,0,0,.7)
		draw.Rect(0,100,msize,10*(#texts),texture)
		for k,v in pairs(texts) do
			local rk = #texts-k
			if(rk > 5) then
				for x=0,(rk-5) do
					v[2] = v[2] - 0.001
				end
			end
			if(v[2] < 0) then v[2] = 0 end
			draw.SetColor(1,1,1,v[2])
			draw.Text(0,100 + (10*((#texts) - k)),v[1],10,10)
		end
		for k,v in pairs(table.Copy(texts)) do
			if(v[2] <= 0) then
				table.remove(texts,k)
			end
		end
	end
end
hook.add("Draw2D","debugbar",draw2D)