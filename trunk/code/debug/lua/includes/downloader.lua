if(downloader == nil) then
	downloader = {}
	downloader.queue = {}
end

FILE_PENDING = 1
FILE_DOWNLOADING = 2
FILE_FINISHED = 3

DLFile = {}

function newFile(name,md5,lines)
	local o = {}

	setmetatable(o,DLFile)
	DLFile.__index = DLFile
	
	o.name = name
	o.md5 = md5
	o.status = FILE_PENDING
	o.isfile = true
	o.lines = lines
	
	return o;
end

function DLFile.__eq(a,b)
	if(a == nil or b == nil) then return false end
	if(a.isfile != true or b.isfile != true) then return false end
	return (a.name == b.name and a.md5 == b.md5)
end

function DLFile:Copy()
	return newFile(self.name,self.md5,self.lines)
end

function getFileByName(file,tab)
	for k,v in pairs(tab) do
		if(v.name == file.name) then return v end
	end
	return nil
end

if(SERVER) then
	message.Precache("__fileheader")
	message.Precache("__fileline")
	message.Precache("__queuefile")
	
	local lastNumPlayers = 0
	
	local function cleanFilename(f)
		local out = string.lower(f)
		if(!string.find(out,".lua")) then
			out = out .. ".lua"
		end

		local ex = string.Explode("/",out)
		return ex[#ex]
	end

	local function fixLine(line)
		if(line != "" and line != " " and line != "\n") then
			line = string.Replace(line,"\t","")
			line = string.Replace(line,"\r","")
			if(line != "" and line != " " and line != "\n") then
				return line
			end
		end	
		return nil
	end

	function downloader.add(filename)
		if(filename != nil and type(filename) == "string") then
			if(fileExists(filename)) then
				local md5sum = fileMD5(filename)
				local lines = countFileLines(filename,function(l,n) return (fixLine(l) != nil) end)
				local file = newFile(filename,md5sum,lines)
				if(!table.HasValue(downloader.queue,file)) then
					local exist = getFileByName(file,downloader.queue)
					if(exist) then
						exist.status = FILE_PENDING
						exist.md5 = md5sum
						exist.lines = lines
						print("File updated in queue: '" .. file.name .. "'\n")
						downloader.notify()
						return 
					end
					table.insert(downloader.queue,file)
					print("File added to queue: '" .. file.name .. "'\n")
					downloader.notify()
				end
			else
				error("File not found: '" .. filename .. "'.")
			end
		else
			error("String expected got '" .. type(filename) .. "'.")
		end
	end
	
	function downloader.playerready(pl)
		if(pl == nil) then return false end
		if(pl:GetTable() == nil) then return false end
		if(pl:GetTable().ready != true) then return false end
		return true
	end
	
	function downloader.putqueue(pl,file)
		local msg = Message(pl,"__queuefile")
		message.WriteString(msg,base64.enc(file.name))
		message.WriteShort(msg,file.lines)
		SendDataMessage(msg)
	end
	
	function downloader.putplayerfile(pl,filex)
		if(!downloader.playerready(pl)) then return end
		local ptab = pl:GetTable()
		local fqueue = ptab.files
		if(!table.HasValue(fqueue,filex) or filex.status == FILE_PENDING) then
			local pfile = getFileByName(filex,fqueue)
			if(pfile != nil) then
				if(pfile.status != FILE_DOWNLOADING) then
					print("Updated Player File " .. pfile.name .. ".\n")
					pfile.status = FILE_PENDING
					pfile.md5 = filex.md5
					pfile.lines = filex.lines
					downloader.putqueue(pl,pfile)
				end
			else
				print("Added Player File " .. filex.name .. ".\n")
				filex = filex:Copy()
				table.insert(ptab.files,filex:Copy())
				downloader.putqueue(pl,filex)
			end
		end
	end
	
	function downloader.sendline(pl,line)
		local ptab = pl:GetTable()
		local fl = fixLine(line)
		if(fl != nil) then
			local msg = Message(pl,"__fileline")
			message.WriteString(msg,base64.enc(fl))
			SendDataMessage(msg)
		end
	end
	
	function downloader.sendheader(pl,file)
		local msg = Message(pl,"__fileheader")
		message.WriteString(msg,base64.enc(file.name))
		message.WriteShort(msg,file.lines)
		message.WriteString(msg,base64.enc(file.md5))
		SendDataMessage(msg)
	end
	
	function downloader.beginlines(pl,filex)
		if(filex == nil) then return end
		if(!fileExists(filex.name)) then return end
		file = io.open(filex.name, "r")
		if(file != nil) then
			local lines = 0
			for line in file:lines() do
				Timer(.08*lines,downloader.sendline,pl,line)
				lines = lines + 1
			end
			Timer((.08*lines) + 0.2,downloader.stopdownload,pl,filex)
			file:close()
		else
			downloader.stopdownload(pl,filex)
		end	
	end
	
	function downloader.stopdownload(pl,file)
		local ptab = pl:GetTable()
		if(!ptab.downloading) then return end
		print("Finished Downloading: " .. file.name .. "\n")
		file.status = FILE_FINISHED
		ptab.downloading = false
		downloader.notify()
	end
	
	function downloader.begindownload(pl,file)
		local ptab = pl:GetTable()
		if(ptab.downloading) then return end
		print("Sending File: " .. file.name .. "[" .. file.md5 .. "] - " .. file.lines .. " lines.\n")
		file.status = FILE_DOWNLOADING
		ptab.downloading = true
		ptab.currentdownload = file
		Timer(.5,downloader.sendheader,pl,file)
		Timer(.6,downloader.beginlines,pl,file)
	end
	
	function downloader.updateplayer(pl)
		if(!downloader.playerready(pl)) then return end
		local ptab = pl:GetTable()
		local fqueue = ptab.files
		if(ptab.downloading) then return end
		for i=1, #fqueue do
			local v = fqueue[i]
			if(v.status == FILE_PENDING) then
				downloader.begindownload(pl,v)
				return
			end
		end
	end
	
	function downloader.notify()
		for _,pl in pairs(GetAllPlayers()) do
			for k,v in pairs(downloader.queue) do
				downloader.putplayerfile(pl,v)
			end
			downloader.updateplayer(pl)
		end
		for k,v in pairs(downloader.queue) do
			v.status = FILE_FINISHED
		end
	end
	
	function downloader.initplayer(pl)
		if(pl != nil) then
			local ptab = pl:GetTable()
			ptab.files = {}
			ptab.ready = true
			ptab.downloading = false
			ptab.currentdownload = nil
			print("Initialized Player: " .. pl:GetInfo().name .. " " .. #ptab.files .. " " .. pl:EntIndex() .. "\n")
			downloader.notify()
		end
	end
	hook.add("ClientReady","__downloader.lua",downloader.initplayer)
	hook.add("Think","__downloader.lua",function()
		if(#GetAllPlayers() != lastNumPlayers) then
			if(#GetAllPlayers() > lastNumPlayers) then
				downloader.notify()
			end
			lastNumPlayers = #GetAllPlayers()
		end
	end) --A crappy way to check for new players
	
	function SendScript(script) print("^1SendScript is Depricated\n") end
elseif(CLIENT) then
	local FILENAME = "Please Wait..."
	local CONTENTS = ""
	local LINECOUNT = 0
	local LINEITER = 0
	local QUEUE = {}

	local function draw2D()
		if(#QUEUE == 0) then return end
		if(DL_FILENAME != "") then
			local per = math.floor((LINEITER / LINECOUNT)*100)
			if(LINEITER == 0) then per = 0 end
			local text = "Downloading: " .. FILENAME .. "(" .. per .. "%)"
			draw.SetColor(1,1,1,1)
			draw.Text(320-(5*string.len(text)),240-5,text,10,10)
		end
		for k,v in pairs(QUEUE) do
			if(k != 1) then
				local text = v[1] .. " - " .. v[2] .. " lines"
				draw.SetColor(1,1,1,1)
				draw.Text(320-(5*string.len(text)),(240-15)+(10*k),text,10,10)
			end
		end
	end
	hook.add("Draw2D","scriptmanager2d",draw2D)
	
	local function localFile(f)
		return string.Replace(f,"/",".")
	end
	
	local function writeToFile()
		local rez = "lua/downloads/" .. localFile(FILENAME)
		print("Writing File: '" .. rez .. "'\n")
		local file = io.open(rez,"w")
		if(file != nil) then
			file:write(CONTENTS)
			file:close()
			local b,e = pcall(include,rez)
			if(!b) then
				debugprint("^1Script Downloader Error (Script Execution): " .. e .. "\n")
			end
		else
			debugprint("^1Script Downloader Error (Script Copy): Unable to write file: " .. rez .. "\n")
		end
	end
	
	local function include()
		local rez = "lua/downloads/" .. localFile(FILENAME)
		local b,e = pcall(include,rez)
		if(!b) then
			debugprint("^1Script Downloader Error (Script Execution): " .. e .. "\n")
		end
	end
	
	local function finished()
		if(#QUEUE > 0) then table.remove(QUEUE,1) end
		writeToFile()
		LINECOUNT = 0
		LINEITER = 0
		FILENAME = "Please Wait..."
	end

	local function HandleMessage(msgid)
		if(msgid == "__queuefile") then
			local name = base64.dec(message.ReadString())
			local lines = message.ReadShort()
			for k,v in pairs(QUEUE) do
				if(v[1] == name) then v[2] = lines return end
			end
			table.insert(QUEUE,{name,lines})
		elseif(msgid == "__fileheader") then
			local name = base64.dec(message.ReadString())
			local lines = message.ReadShort()
			local md5 = base64.dec(message.ReadString())
			--print("F_HEADER: " .. name .. " - " .. lines .. " lines.\n")
			CONTENTS = ""
			FILENAME = name
			LINECOUNT = lines
			LINEITER = 0
		elseif(msgid == "__fileline") then
			local str = base64.dec(message.ReadString())
			CONTENTS = CONTENTS .. str .. "\n"
			LINEITER = LINEITER + 1
			--print("F_LINE: " .. str .. " [X] " .. LINEITER .. "/" .. LINECOUNT .. "\n")
			if(LINEITER == LINECOUNT) then
				finished()
			end
		end
	end
	hook.add("HandleMessage","__downloader.lua",HandleMessage)
end