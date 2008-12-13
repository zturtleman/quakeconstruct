downloader = {}
downloader.queue = {}

FILE_PENDING = 1
FILE_DOWNLOADING = 2
FILE_FINISHED = 3

DLFile = {}

function DLFile:_eq(a,b)
	if(a.isfile != true or b.isfile != true) then return false end
	return (a.name == b.name and a.md5 == b.md5)
end

function newFile(name,md5)
	local o = {}

	setmetatable(o,DLFile)
	DLFile.__index = DLFile
	
	o.name = name
	o.md5 = md5
	o.status = FILE_PENDING
	
	return o;
end

function getFileByName(file,tab)
	for k,v in pairs(tab) do
		if(v.name == file.name) then return v end
	end
	return nil
end

if(SERVER) then
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

	function downloader.add(file)
		if(file != nil and type(file) == "string") then
			if(fileExists(file)) then
				if(!table.HasValue(downloader.queue,file)) then
					local md5sum = fileMD5(file)
					table.insert(downloader.queue,newFile(file,md5sum))
					print("File added to queue: '" .. file .. "'\n")
					downloader.notify()
				end
			else
				error("File not found: '" .. file .. "'.\n")
			end
		else
			error("String expected got '" .. type(file) .. "'.\n")
		end
	end
	
	function downloader.playerready(pl)
		if(pl == nil) then return false end
		if(pl:GetTable() == nil) then return false end
		if(pl:GetTable().ready != true) then return false end
		return true
	end
	
	function downloader.putplayerfile(pl,filex)
		local ptab = pl:GetTable()
		local fqueue = ptab.files
		if(!downloader.playerready(pl)) then return end
		if(!table.HasValue(ptab.files,filex)) then
			local pfile = getFileByName(filex,ptab.files)
			if(pfile != nil) then
				pfile.status = FILE_PENDING
			else
				table.insert(ptab.files,filex)
			end
		end
	end
	
	function downloader.notify()
		for _,pl in pairs(GetAllPlayers()) do
			for k,v in pairs(downloader.queue) do
				downloader.putplayerfile(pl,v)
			end
		end
	end
	
	function downloader.initplayer(pl)
		if(pl != nil) then
			local ptab = pl:GetTable()
			ptab.files = {}
			ptab.ready = true
			print("Initialized Player: " .. pl:GetInfo().name .. "\n")
		end
	end
	hook.add("ClientReady","downloader.lua",downloader.initplayer)
	
	function SendScript(script) print("^1SendScript is Depricated\n") end
elseif(CLIENT) then

end