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

local function getFileMD5(filename)
	return fileMD5(filename,function(l,n) return (fixLine(l) != nil) end)
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
		o.current = 0
		o.pendingnotify = false
		o.queue = {}
		
		ptab.stream = o
		
		return o;
	end

	function getPlayerStream(client)
		return ptab.stream
	end

	function DLStream:GetFiles()
		return self.queue
	end

	function DLStream:SendFileHeader(file)
		self:SetStatus(STREAM_WCM)
	end

	function DLStream:SendFileData(file)

	end

	function DLStream:GetNextFile()
		local nextfile = nil
		for k,v in pairs(self.queue) do
			if(v.status == FILE_PENDING) then
				nextfile = v
			end
		end
		return nextfile
	end
	
	function DLStream:SendNextFile()
		if(self.status == STREAM_IDLE) then
			self.pendingnotify = true
			print("^2Cannot send files yet, stream is busy.\n")
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
	
	function DLStream:SetStatus(s)
		self.status = s
		if(self.status == STREAM_IDLE and self.pendingnotify == true) then
			self.pendingnotify = false
			self:Notify()
		end
	end

	function DLStream:AddFile(file)
		if(!table.HasValue(self.queue,file)) then
			local exist = getFileByName(file,self.queue)
			if(exist) then
				exist.status = FILE_PENDING
				exist.md5 = file.md5
				exist.lines = file.lines
				print("File updated in player stream: '" .. file.name .. "'\n")
				return true
			end
			file.status = FILE_PENDING
			table.insert(self.queue,file)
			print("File added to player stream: '" .. file.name .. "'\n")
			return true
		else
			print("Did nothing with file: '" .. file.name .. "'\n")
		end
		return false
	end

	function DLStream:ClientAction(...)

	end

	function DLStream:Notify()
		self:SendNextFile()
	end
--************
--MASTER QUEUE
--************
	local FQueue = {}

	local function parseFile(filename)
		if(filename != nil and type(filename) == "string") then
			file = io.open(filename, "r")
			if(file != nil) then
				local md5sum = fileMD5(file,function(l,n) return (fixLine(l) != nil) end)
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
				return newFile(filename,md5sum,flines)
			else
				error("File not found: '" .. filename .. "'.")
				return
			end
		else
			error("String expected got '" .. type(filename) .. "'.")
			return
		end
	end

	local function AddFileToQueue(file)
		local file = parseFile(file)
		if(file == nil) then return end
		if(!table.HasValue(FQueue,file)) then
			local exist = getFileByName(file,FQueue)
			if(exist) then
				exist.status = FILE_IDLE
				exist.md5 = md5sum
				exist.lines = flines
				debugprint("File updated in queue: '" .. file.name .. "'\n")
				downloader.notify(force)
				return 
			end
			table.insert(FQueue,file)
			debugprint("File added to queue: '" .. file.name .. "'\n")
			downloader.notify()
		else
			debugprint("Did nothing with file: '" .. file.name .. "'\n")
		end
	end

	local function pushQueueToStream(stream)
		local doNotify = false
		for k,v in pairs(FQueue) do
			if(stream:AddFile(v)) then doNotify = true
		end
		if(doNotify) then stream:Notify()
	end
--*********
--PLAYER IO
--*********
	local function message(str,pl)
		local args = string.Explode(str," ")
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
			local ptab = pl:GetTable()
			newStream(pl)
			print("Initialized Player: " .. pl:GetInfo().name .. " " .. #ptab.files .. " " .. pl:EntIndex() .. "\n")
			downloader.notify()
		end
	end
	hook.add("ClientReady","__downloader.lua",downloader.initplayer)

	--****
	--MAIN
	--****
	function downloader.add(filename)
		AddFileToQueue(filename)
	end

	function downloader.notify()
		for k,v in pairs(GetAllPlayers()) do
			local stream = getPlayerStream(v)
			if(stream != nil) then
				pushQueueToStream(stream)
			end
		end
	end
	downloader.Add = downloader.add
end