--Qconstruct markup language

local tags = {}

function newTag(macro,...)
	local tag = {}
	tag.args = unpack(arg)
	tag.macro = macro
	table.insert(tags,tag)
end

newTag("link","text","dest")
newTag("image","src","w","h")
newTag("font","w","h")

function doArg(argdata)
	argdata = string.Explode('=',argdata)
	if(#argdata != 2) then error("Malformed Argument.\n") end
	return argdata[1],argdata[2]
end

function doTag(tagdata)
	local tagargs = {}
	local spc = string.find(tagdata," ")
	local name = string.sub(tagdata,2,string.len(tagdata))
	
	if(spc != nil) then
		name = string.sub(tagdata,2,spc-1)
		local remain = string.sub(tagdata,spc+1,string.len(tagdata))
		remain = string.Replace(remain,' ','')
		remain = string.Explode(',',remain)
		
		--print("^2Got Tag: '" .. tagdata .. "' " .. name .. ".\n")
		for i=1,#remain do
			local k,v = doArg(remain[i])
			tagargs[k] = v
		end	
	end
	
	local tag = {}
	tag.name = name
	tag.args = tagargs
	return tag
end

function parseChunk(chunk,callback,callback_char)
	local intag = false
	local tab = string.ToTable(chunk)
	local tagtemp = ""
	for i=1, #tab do
		local ch = tab[i]
		if(ch == "[") then
			if(intag == false) then
				intag = true
			else
				error("Tag MisMatch.\n")
			end
		elseif(ch == "]") then
			if(intag == true) then
				intag = false
				local tag = doTag(tagtemp)
				if(tag != nil) then
					local b,e = pcall(callback,tag)
					if(!b) then error("QML: " .. e .. "\n") end
				end
				tagtemp = ""
			else
				error("Tag MisMatch.\n")
			end
		elseif(!intag) then
			if(callback_char != nil) then
				local b,e = pcall(callback_char,ch)
				if(!b) then error("QML: " .. e .. "\n") end
			end
		end
		if(intag) then tagtemp = tagtemp .. ch end
	end
end

function stream(filename,callback,callback_char)
	file = io.open(filename, "r")
	if(file != nil) then
		local lines = 0
		local content = ""
		for line in file:lines() do
			content = content .. line .. "\n"
		end
		parseChunk(content,callback,callback_char)
		file:close()
	else
		error("File not found: '" .. filename .. "'.")
		return
	end
end

stream("lua/includes/markuptest.qml",
function(tag) 
	print("[^2" .. tag.name .. "^7]->\n") 
end,
function(ch) 
	print(ch) 
end)