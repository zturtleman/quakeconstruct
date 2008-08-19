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
		if(args[1] == "getHash") then
			if(args[2] != nil) then
				print("Cl_File: " .. args[2] .. "\n")
				
				local md5sum = fileMD5("lua/downloads/" .. args[2])
				md5sum = hexFormat(md5sum)
				
				print("Cl_Hash: " .. md5sum .. "\n")
				SendString("md5hash " .. args[2] .. " " .. md5sum)
			end
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
	local masterqueue = {}
	
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
	
	function scriptmanager.getQueue(pl)
		if(pl != nil and GetEntityTable(pl) and GetEntityTable(pl).dl_queue) then
			return GetEntityTable(pl).dl_queue
		end	
	end
	
	function scriptmanager.copyMasterQueue(pl)
		local myqueue = scriptmanager.getQueue(pl)
		for k,v in pairs(masterqueue) do
			local c = cleanse(v)
			print("Check Master: " .. v .. "\n")
			if(!table.HasValue(myqueue,v)) then
				if(GetEntityTable(pl).dl_hashtable[c] != nil) then
					local md5sum = fileMD5(v)
					md5sum = hexFormat(md5sum)
					if(GetEntityTable(pl).dl_hashtable[c] != md5sum) then
						print("Player Queued: " .. c .. "\n")
						table.insert(myqueue,v)
					else
						print("Player Has Valid Copy\n")
					end
				end
			end
		end
	end
	
	function scriptmanager.sendqueue(pl)
		if(scriptmanager.getQueue(pl)) then
			pl:SendString("beginqueue")
			for k,v in pairs(scriptmanager.getQueue(pl)) do
				pl:SendString(v)
			end
			pl:SendString("endqueue")
		end
	end
	
	function scriptmanager.ready(pl,nv)
		if(nv != nil) then
			GetEntityTable(pl).dl_ready = nv
		end
		return GetEntityTable(pl).dl_ready
	end
	
	function scriptmanager.checkToSend(pl)
		local sendqueue = scriptmanager.getQueue(pl)		
		if(sendqueue != nil) then
			local f = sendqueue[1]
			if(f != nil and scriptmanager.ready(pl) == true) then
				scriptmanager.sendIt(pl,f)
				table.remove(sendqueue,1)
				scriptmanager.sendqueue(pl)
			end
		end
	end
	
	function scriptmanager.getHash(pl,script)
		if(GetEntityTable(pl).dl_connected == true) then
			local str = "getHash " .. cleanse(script)
			GetEntityTable(pl).dl_phc = GetEntityTable(pl).dl_phc + 1
			pl:SendString(str)
		end
	end
	
	function scriptmanager.sendIt(pl,script)
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
			
				scriptmanager.ready(pl,false)
				pl:SendString("begindownload " .. cleanse(script) .. " " .. lines)
				
				local i = 1
				for line in file:lines() do
					line = string.Replace(line, "\"", "'")
					Timer(i*d,pl.SendString,pl,"downloadline " .. line)
					i=i+1
				end
				
				Timer(i*d,sendString,"enddownload")
				Timer((i*d)+0.8,scriptmanager.ready,pl,true)
				Timer((i*d)+1,scriptmanager.checkToSend,pl)
				file:close()
			end
		else
			print("Script Not Found: " .. script .. "\n")
		end	
	end
	
	function scriptmanager.checkPlayers(script)
		if(script != nil) then
			for k,v in pairs(GetAllPlayers()) do
				if(!v:IsBot()) then
					scriptmanager.getHash(v,script)
				end
			end
		else
			for k,v in pairs(GetAllPlayers()) do
				if(!v:IsBot()) then
					for _,script in pairs(masterqueue) do
						scriptmanager.getHash(v,script)
					end
				end
			end
		end
	end

	function SendScript(script)
		if(script != nil) then
			if(fileExists(script)) then
				if(!table.HasValue(masterqueue,script)) then
					table.insert(masterqueue,script)
					print("Script Added To Queue: " .. script .. "\n")
				end
				scriptmanager.checkPlayers(script)
			else
				print("Script Not Found: " .. script .. "\n")
			end
		end
	end
	
	function pljoin(pl)
		GetEntityTable(pl).dl_ready = true
		GetEntityTable(pl).dl_queue = {}
		GetEntityTable(pl).dl_hashtable = {}
		GetEntityTable(pl).dl_connected = true
		GetEntityTable(pl).dl_phc = 0
		scriptmanager.checkPlayers()
	end
	hook.add("PlayerJoined","scriptmanager",pljoin)
	
	local function messagetest(str,pl)
		local args = string.Explode(" ",str)
		if(args[1] == "md5hash") then
			local filename = args[2];
			local hash = args[3];
			if(hash == nil) then hash = "" end
			print("Got MD5Hash[" .. filename .. "]: " .. hash .. "\n")
			GetEntityTable(pl).dl_hashtable[filename] = hash
			GetEntityTable(pl).dl_phc = GetEntityTable(pl).dl_phc - 1
			if(GetEntityTable(pl).dl_phc <= 0) then
				GetEntityTable(pl).dl_phc = 0
				print("Got All MD5Hash... Starting Downloads\n")
				scriptmanager.copyMasterQueue(pl)
				scriptmanager.checkToSend(pl)
			end
			return
		end
	end
	hook.add("MessageReceived","scriptmanager",messagetest)
end