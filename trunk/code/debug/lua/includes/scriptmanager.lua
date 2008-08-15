if(CLIENT) then
	local DL_FILENAME = ""
	local DL_CONTENTS = ""
	local DL_SIZE = 0
	local DL_DOWNLOADED = 0
	local DL_INQUEUE = false
	local DL_QUEUE = {}
	
	local function draw2D()
		if(DL_FILENAME != "") then
			local text = "Downloading: " .. DL_FILENAME .. "(" .. DL_DOWNLOADED .. " / " .. DL_SIZE .. ")"
			draw.SetColor(1,1,1,1)
			draw.Text(320-(5*string.len(text)),240-5,text,10,10)
		end
		for k,text in pairs(DL_QUEUE) do
			draw.SetColor(1,1,1,1)
			draw.Text(320-(5*string.len(text)),(240-5)+(10*k),text,10,10)
		end
	end
	hook.add("Draw2D","scriptmanager2d",draw2D)
	
	local function messagetest(str)
		local args = string.Explode(" ",str)
		if(args[1] == "loadscript") then
			includesimple(args[2])
			return
		end
		if(args[1] == "begindownload") then
			DL_FILENAME = args[2];
			DL_SIZE = tonumber(args[3])
			DL_CONTENTS = ""
			print("Download Started: " .. DL_FILENAME .. "\n")
			return
		end
		if(args[1] == "downloadline") then
			str = string.sub(str,14,string.len(str))
			DL_CONTENTS = DL_CONTENTS .. str .. "\n"
			DL_DOWNLOADED = DL_DOWNLOADED + 1
			return
		end
		if(args[1] == "enddownload") then
			local rez = "lua/downloads/" .. DL_FILENAME
			print("Download Finished: " .. rez .. "\n")
			
			local file = io.open(rez,"w")
			file:write(DL_CONTENTS)
			file:close()
			
			local b,e = pcall(include,rez)
			if(!b) then
				print("^1Script Manager Error: " .. e .. "\n")
			end
			
			file = io.open(rez,"w")
			file:write("")
			file:close()
			
			DL_FILENAME = ""
			DL_CONTENTS = ""
			DL_SIZE = 0
			DL_DOWNLOADED = 0
			return
		end
		if(args[1] == "beginqueue") then
			DL_QUEUE = {}
			DL_INQUEUE = true
			return
		end
		if(args[1] == "endqueue") then
			DL_INQUEUE = false
			return
		end
		if(DL_INQUEUE) then
			table.insert(DL_QUEUE,str)
		end
	end
	hook.add("MessageReceived","scriptmanager",messagetest)
	--self.VAriblae
end
if(SERVER) then
	local scriptmanager = {}
	local sendqueue = {}
	scriptmanager.sending = false
	
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
	
	function scriptmanager.sendqueue()
		sendString("beginqueue")
		for k,v in pairs(sendqueue) do
			sendString(v)
		end
		sendString("endqueue")
	end
	
	function scriptmanager.checkToSend()
		local f = sendqueue[1]
		if(f != nil and scriptmanager.sending == false) then
			scriptmanager.sendIt(f)
			table.remove(sendqueue,1)
			scriptmanager.sendqueue()
		end
	end
	
	function scriptmanager.sendIt(script)
		local d = 0.08
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
			
				scriptmanager.sending = true
				sendString("begindownload " .. cleanse(script) .. " " .. lines)
				
				local i = 1
				for line in file:lines() do
					line = string.Replace(line, "\"", "'")
					Timer(i*d,sendString,"downloadline " .. line)
					i=i+1
				end
				
				Timer(i*d,sendString,"enddownload")
				Timer(i*d,function() scriptmanager.sending = false end)
				Timer((i*d)+0.3,scriptmanager.checkToSend)
				file:close()
			end
		else
			print("Script Not Found: " .. script .. "\n")
		end	
	end

	function SendScript(script)
		if(script != nil) then
			if(fileExists(script)) then
				print("Script Added To Queue: " .. script .. "\n")
				table.insert(sendqueue,script)
				scriptmanager.checkToSend()
				scriptmanager.sendqueue()
			else
				print("Script Not Found: " .. script .. "\n")
			end
		end
	end
end