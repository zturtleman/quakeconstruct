if(CLIENT) then
	local DL_FILENAME = ""
	local DL_CONTENTS = ""
	local DL_SIZE = 0
	local DL_DOWNLOADED = 0
	
	local function draw2D()
		if(DL_FILENAME != "") then
			local text = "Downloading: " .. DL_FILENAME .. "(" .. DL_DOWNLOADED .. " / " .. DL_SIZE .. ")"
			draw.SetColor(1,1,1,1)
			draw.Text(320-(5*string.len(text)),240-5,text,10,10)			
		end
	end
	hook.add("Draw2D","scriptmanager2d",draw2D)
	
	local function messagetest(str)
		local args = string.Explode(" ",str)
		if(args[1] == "loadscript") then
			includesimple(args[2])
		end
		if(args[1] == "begindownload") then
			DL_FILENAME = args[2];
			DL_SIZE = tonumber(args[3])
			DL_CONTENTS = ""
			print("Download Started: " .. DL_FILENAME .. "\n")
		end
		if(args[1] == "downloadline") then
			str = string.sub(str,14,string.len(str))
			DL_CONTENTS = DL_CONTENTS .. str .. "\n"
			DL_DOWNLOADED = DL_DOWNLOADED + 1
		end
		if(args[1] == "enddownload") then
			local rez = "lua/downloads/" .. DL_FILENAME
			print("Download Finished: " .. rez .. "\n")
			
			local file = io.open(rez,"w")
			file:write(DL_CONTENTS)
			file:close()
			
			include(rez)
			
			DL_FILENAME = ""
			DL_CONTENTS = ""
			DL_SIZE = 0
			DL_DOWNLOADED = 0
		end
	end
	hook.add("MessageReceived","scriptmanager",messagetest)
	--self.VAriblae
end
if(SERVER) then
	local function cleanse(f)
		local out = string.lower(f)
		if(!string.find(out,".lua")) then
			out = out .. ".lua"
		end

		local ex = string.Explode("/",out)
		return ex[#ex]
	end

	local function sendString(str)
		for k,v in pairs(GetAllPlayers()) do
			if(!v:IsBot()) then
				v:SendString(str)
			end
		end
	end

	function SendScript(script)
		if(fileExists(script)) then
			print("Sending Script: " .. script .. "\n")
			file = io.open(script, "r")
			if(file != nil) then
				local lines = 0
				for line in file:lines() do
					lines = lines + 1
				end
				
				file:close()
				file = io.open(script, "r")
			
				sendString("begindownload " .. cleanse(script) .. " " .. lines)
				
				local i = 1
				for line in file:lines() do
					line = string.Replace(line, "\"", "'")
					Timer(i*.05,sendString,"downloadline " .. line)
					i=i+1
				end
				
				Timer(i*.05,sendString,"enddownload")
				file:close()
			end
		else
			print("Script Not Found: " .. script .. "\n")
		end
	end
end