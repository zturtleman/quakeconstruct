if(downloader == nil) then downloader = {} end

if(SERVER) then
	message.Precache("__fileheader")
	message.Precache("__fileline")
	message.Precache("__queuefile")
	message.Precache("__runfile")
end

--******
--CONFIG
--******

DOWNLOAD_BUFFER_SIZE = 256

--*********
--FILE UTIL
--*********
FILE_IDLE = 0
FILE_PENDING = 1
FILE_DOWNLOADING = 2
FILE_FINISHED = 3
FILE_FAILED = 4
FILE_PENDINGEXECUTION = 5

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

local function fixLine(line)
	if(string.find(line,"//__DL_BLOCK")) then block = true return end
	if(string.find(line,"//__DL_UNBLOCK")) then block = false return end
	if(line == "--[[") then block = true return end
	if(line == "]]") then block = false return end
	if(block == true) then return nil end
	if(line != "" and line != " " and line != "\n") then
		line = string.Replace(line,"\t","")
		line = string.Replace(line,"\r","")
		line = string.Replace(line,"\n","")
		if(line != "" and line != " " and line != "\n") then
			return line .. "\n" --"_NL_"
		end
	end	
	return nil
end

local function cleanFilename(f)
	local out = string.lower(f)
	if(!string.find(out,".lua")) then
		out = out .. ".lua"
	end

	local ex = string.Explode("/",out)
	return ex[#ex]
end
--***********
--FILE STREAM
--***********
if(SERVER) then
	DLStream = {}

	STREAM_IDLE = 1
	STREAM_WCM = 2
	STREAM_DOWNLOADING = 3

	function newStream(client)
		local o = {}
		local ptab = client:GetTable()

		setmetatable(o,DLStream)
		DLStream.__index = DLStream
		
		o.client = client
		o.clientID = client:EntIndex()
		o.status = STREAM_IDLE
		o.current = nil
		o.pendingnotify = false
		o.queue = {}
		
		ptab.stream = o
		
		return o;
	end

	function getPlayerStream(client)
		local ptab = client:GetTable()
		return ptab.stream
	end

	function DLStream:GetFiles()
		return self.queue
	end

	function DLStream:SendFileHeader(file)
		local msg = self:Message("__fileheader")
		message.WriteString(msg,base64.enc(file.name))
		message.WriteShort(msg,#file.lines)
		message.WriteString(msg,base64.enc(file.md5))
		SendDataMessage(msg)
		self:SetStatus(STREAM_WCM)
		self.current = file
	end
	
	function DLStream:SendLine(line)
		local msg = self:Message("__fileline")
		message.WriteString(msg,base64.enc(line) or "")
		SendDataMessage(msg)
	end

	function DLStream:SendFileData()
		local filex = self.current
		filex.status = FILE_DOWNLOADING
		self:SetStatus(STREAM_DOWNLOADING)
		if(filex.lines != nil) then
			local lines = 0
			for _,line in pairs (filex.lines) do
				Timer(.1*lines,self.SendLine,self,line)
				lines = lines + 1
			end
			Timer((.1*lines) + 0.2,self.FinishedFile,self)
		else
			self.current.status = FILE_FAILED
			self:Notify()
		end
	end
	
	function DLStream:GetNextFile()
		local nextfile = nil
		for i=1, #self.queue do
			local v = self.queue[i]
			if(v.status == FILE_PENDING) then
				nextfile = v
			end
		end
		return nextfile
	end
	
	function DLStream:SendNextFile()
		if(self.status != STREAM_IDLE) then
			self.pendingnotify = true
			debugprint("^2Cannot send files yet, stream is busy.\n")
			return
		end
		local file = self:GetNextFile()
		if(file != nil) then
			self:SendFileHeader(file)
		else
			self:SetStatus(STREAM_IDLE)
			return
		end
	end
	
	function DLStream:ExecuteFile(file)
		local msg = self:Message("__runfile")
		message.WriteString(msg,base64.enc(file.name))
		SendDataMessage(msg)
	end
	
	function DLStream:DropFile()
		self:FinishedFile()
	end
	
	function DLStream:SetStatus(s)
		self.status = s
		if(self.status == STREAM_IDLE and self.pendingnotify == true) then
			self.pendingnotify = false
			self:Notify()
		end
	end
	
	function DLStream:Message(s)
		return Message(self.client,s)
	end

	function DLStream:AddFile(file)
		if(!table.HasValue(self.queue,file)) then
			local exist = getFileByName(file,self.queue)
			if(exist) then
				if(exist.status != FILE_PENDING) then
					local msg = self:Message("__queuefile")
					message.WriteString(msg,base64.enc(file.name))
					message.WriteShort(msg,#file.lines)
					SendDataMessage(msg)
				end
			
				exist.status = FILE_PENDING
				exist.md5 = file.md5
				exist.lines = file.lines
				debugprint("File updated in player stream: '" .. file.name .. "'\n")
				return true
			end
			file.status = FILE_PENDING
			table.insert(self.queue,file)
			
			local msg = self:Message("__queuefile")
			message.WriteString(msg,base64.enc(file.name))
			message.WriteShort(msg,#file.lines)
			SendDataMessage(msg)
			
			debugprint("File added to player stream: '" .. file.name .. "'\n")
			return true
		else
			debugprint("Did nothing with file in stream: '" .. file.name .. "'\n")
		end
		return false
	end

	function DLStream:ClientAction(...)
		if(self.status == STREAM_WCM) then
			debugprint("Got Client Action: " .. arg[1] .. "\n")
			if(arg[1] == "accept") then
				self:SendFileData()
			elseif(arg[1] == "cancel") then
				self:DropFile()
			end
		end
	end

	function DLStream:FinishedFile()
		debugprint(self.current.name .. "\n")
		self.current.status = FILE_FINISHED
		self.current = nil
		self:SetStatus(STREAM_IDLE)
		self:Notify()
	end
	
	function DLStream:Notify()
		self:SendNextFile()
	end
--************
--MASTER QUEUE
--************
	local FQueue = {}

	local function parseFileLines(file)
		if(file != nil) then
			local flines = {}--countFileLines(filename,function(l,n) return (fixLine(l) != nil) end)
			local lines = 0
			local buffer = ""
			for line in file:lines() do
				local fixed = fixLine(line)
				if(fixed != nil) then
					for k,v in pairs(string.ToTable(fixed)) do
						buffer = buffer .. v
						if(string.len(buffer) > DOWNLOAD_BUFFER_SIZE) then
							table.insert(flines,buffer)
							buffer = ""
						end
					end
				end
			end
			if(string.len(buffer) > 0) then
				table.insert(flines,buffer)
			end
			file:close()
			return flines
		else
			error("File not found: '" .. filename .. "'.")
			return
		end
	end

	local function AddFileToQueue(filename)
		if(filename == nil or type(filename) != "string") then
			error("String expected got '" .. type(filename) .. "'.") 
			return 
		end
		iofile = io.open(filename, "r")
		if(iofile == nil) then return end
		local md5sum = fileMD5(iofile,function(l,n) return (fixLine(l) != nil) end)
		
		local file = newFile(filename,md5sum)
		
		if(!table.HasValue(FQueue,file)) then
			local exist = getFileByName(file,FQueue)
			if(exist) then
				exist.status = FILE_IDLE
				exist.md5 = file.md5
				exist.lines = parseFileLines(iofile)
				debugprint("File updated in queue: '" .. file.name .. "'\n")
				downloader.notify()
				return 
			end
			file.lines = parseFileLines(iofile)
			table.insert(FQueue,file)
			debugprint("File added to queue: '" .. file.name .. "'\n")
			downloader.notify()
		else
			local exist = getFileByName(file,FQueue)
			debugprint("File set to FILE_PENDINGEXECUTION: '" .. exist.name .. "'\n")
			exist.status = FILE_PENDINGEXECUTION
			downloader.notify()
		end
	end
	
	local function clearExecutingFiles()
		for k,v in pairs(FQueue) do
			if(v.status == FILE_PENDINGEXECUTION) then
				v.status = FILE_IDLE
			end
		end
	end

	local function pushQueueToStream(stream)
		local doNotify = false
		for k,v in pairs(FQueue) do
			if(v.status == FILE_PENDINGEXECUTION) then
				stream:ExecuteFile(v)
			else
				if(stream:AddFile(v:Copy())) then doNotify = true end
			end
		end
		if(doNotify) then stream:Notify() end
	end
--*********
--PLAYER IO
--*********
	local function message(str,pl)
		local args = string.Explode(" ",str)
		if(args[1] == "_downloadaction") then
			table.remove(args,1)
			local stream = getPlayerStream(pl)
			if(stream != nil) then
				stream:ClientAction(unpack(args))
			end
		end
	end
	hook.add("MessageReceived","__downloader.lua",message)

	function downloader.initplayer(pl)
		if(pl != nil) then
			local ptab = newStream(pl)
			debugprint("Initialized Player: " .. pl:GetInfo().name .. " " .. #ptab:GetFiles() .. " " .. pl:EntIndex() .. "\n")
			downloader.notify()
		end
	end
	hook.add("ClientReady","__downloader.lua",downloader.initplayer)

--****
--MAIN
--****
	function downloader.add(filename)
		if(!fileExists(filename)) then filename = filename .. ".lua" end
		if(!fileExists(filename)) then filename = "lua/" .. filename end
		print(filename .. "\n")
		AddFileToQueue(filename)
	end

	function downloader.notify()
		for k,v in pairs(GetAllPlayers()) do
			local stream = getPlayerStream(v)
			if(stream != nil) then
				pushQueueToStream(stream)
			end
		end
		clearExecutingFiles()
	end
	downloader.Add = downloader.add
end

if(CLIENT) then
	local FILENAME = "Please Wait..."
	local CONTENTS = ""
	local LINECOUNT = 0
	local LINEITER = 0
	local QUEUE = {}
	local frame = nil
	local flist = nil
	local template = nil
	local queuebuttons = {}
	local start = false
	
	local function makeFrame()
		queuebuttons = {}
		frame = UI_Create("frame")
		local w,h = 640,480
		local pw,ph = w/1.5,h/3
		frame.name = "base"
		frame:SetPos((w/2) - pw/2,460 - ph)
		frame:SetSize(pw,ph)
		frame:SetTitle("Awaiting Files...")
		--frame:CatchMouse(true)
		frame:SetVisible(true)
		frame:EnableCloseButton(false)
		
		flist = UI_Create("listpane",frame)
		flist.name = "base->listpane"
		
		if(template != nil) then return end
		
		template = UI_Create("label")
		template:SetSize(100,15)
		template:SetTextSize(6)
		template:SetText("<nothing here>")
		template:TextAlignCenter()
		template:Remove()
	end

	local function update()
		local per = math.floor((LINEITER / LINECOUNT)*100)
		if(LINEITER <= 0) then per = 0 end
		if(LINECOUNT <= 0) then per = 0 end
		if(frame != nil) then frame:SetTitle("Downloading...") else return end
		local text2 = FILENAME .. "(" .. per .. "%) [" .. LINECOUNT .. " chunks]"
		
		if(#queuebuttons > #QUEUE) then 
			flist:Clear()
			queuebuttons = {}
		end
		
		while(#queuebuttons < #QUEUE) do
			template:SetFGColor(1,1,1,.6)
			template:SetText("")
			local pane = flist:AddPanel(template,true)
			table.insert(queuebuttons,pane)
		end
		
		for k,v in pairs(QUEUE) do
			local panel = queuebuttons[k]
			if(panel != nil) then
				if(k != 1) then
					local text = v[1] .. "[-" .. v[2] .. "-]"
					panel:SetFGColor(1,1,1,.6)
					panel:SetText(text)
				else
					panel:SetFGColor(1,1,1,1)
					panel:SetText(text2)
				end
			end
		end
	end
	
	local function localFile(f)
		return string.Replace(f,"/",".")
	end
	
	local function includeFile(name)
		local rez = "lua/downloads/" .. localFile(name)
		if(!CallHook("FileDownloaded",rez)) then
			debugprint("Execute: " .. rez .. "\n")
			local b,e = pcall(include,rez)
			if(!b) then
				debugprint("^1Script Downloader Error (Script Execution): " .. e .. "\n")
			end
		end
	end
	
	local function writeToFile()
		local rez = "lua/downloads/" .. localFile(FILENAME)
		--print("Writing File: '" .. rez .. "'\n")
		--CONTENTS = string.Replace(CONTENTS,"_NL_","\n")
		local file = io.open(rez,"w")
		if(file != nil) then
			file:write(CONTENTS)
			file:close()
			includeFile(FILENAME)
		else
			debugprint("^1Script Downloader Error (Script Copy): Unable to write file: " .. rez .. "\n")
		end
	end
	
	local function finished()
		if(#QUEUE > 0) then table.remove(QUEUE,1) end
		if(#QUEUE == 0 and frame != nil) then 
			frame:Close()
			frame = nil
			flist = nil
		end
		--print("FINISHED!\n");
		if(CONTENTS != "") then writeToFile() end
		LINECOUNT = 0
		LINEITER = 0
		FILENAME = "Please Wait..."
		start = false
	end

	local function checkMD5(f1,md5)
		local fmd5 = fileMD5(f1,function(l,n) return (fixLine(l) != nil) end)
		fmd5 = base64.dec(base64.enc(fmd5))
		print("^3" .. base64.enc(fmd5) .. "\n")
		print("^3" .. base64.enc(md5) .. "\n")
		if(fmd5 == md5) then return true end
		return false	
	end
	
	local function checkForFile(FILENAME,md5)
		local fn1 = string.Replace(FILENAME,"/",".")
		if(checkMD5("lua/downloads/" .. fn1,md5)) then return true end
		--if(checkMD5(FILENAME,md5)) then return true end
		return false
	end
	
	local function HandleMessage(msgid,tab)
		if(msgid == "__queuefile") then
			local name = base64.dec(message.ReadString() or "")
			local lines = message.ReadShort()
			for k,v in pairs(QUEUE) do
				if(v[1] == name) then v[2] = lines return end
			end
			table.insert(QUEUE,{name,lines})
			update()
			--print("F_QUEUE: " .. name .. " - " .. lines .. " lines.\n")
		elseif(msgid == "__fileheader") then
			if(#tab == 0 and start) then
				--print("CL_FINISH\n")
				finished()
				return
			end
			start = true
			local name = base64.dec(message.ReadString() or "")
			local lines = message.ReadShort()
			local md5 = base64.dec(message.ReadString() or "")
			--print("F_HEADER: " .. name .. " - " .. lines .. " lines.\n")
			CONTENTS = ""
			FILENAME = name
			LINECOUNT = lines
			LINEITER = 0
			if(checkForFile(FILENAME,md5)) then
				--print("F_SENT_CANCEL\n")
				SendString("_downloadaction cancel")
				includeFile(FILENAME) --FIX THIS OMG! -Hxrmn
				finished()
			else
				if(frame == nil) then
					makeFrame()
					update()
				end
				--print("F_SENT_ACCEPT\n")
				SendString("_downloadaction accept")
			end
		elseif(msgid == "__fileline") then
			local str = base64.dec(message.ReadString() or "")
			CONTENTS = CONTENTS .. str -- .. "\n"
			LINEITER = LINEITER + 1
			--print("F_LINE: " .. str .. " [X] " .. LINEITER .. "/" .. LINECOUNT .. "\n")
			update()
			if(LINEITER == LINECOUNT) then
				finished()
			end
		elseif(msgid == "__runfile") then
			local name = base64.dec(message.ReadString() or "")
			--FILENAME = name
			--print("F_EXECUTE: " .. name .. "\n")
			includeFile(name)
		end
	end
	hook.add("HandleMessage","__downloader.lua",HandleMessage)
end