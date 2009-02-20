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

function doMarkupFile(filename)
	local frame = UI_Create("frame")
	frame:SetPos(10,10)
	frame:SetSize(620,460)
	frame:SetTitle("QML - " .. filename)
	frame:CatchMouse(true)
	frame:SetVisible(true)

	local editpane = UI_Create("editpane",frame)
	local template = UI_Create("panel",editpane)
	if(editpane) then
		--template.Draw = function() end
		template:SetPos(0,10)
		template:SetSize(10,10)
		editpane:SetContent(template)
	end

	local cx = 0
	local cy = 2
	local cw = 0
	local ch = 0

	function makeLabel(size)
		local clabel = UI_Create("label",template)
		clabel:SetPos(cx,cy)
		clabel:SetTextSize(size or 6,8)
		clabel:TextAlignLeft()
		clabel:SetText("")
		clabel:SetDelegate(editpane)
		return clabel
	end

	function makeButton(size,func)
		local clabel = UI_Create("button",template)
		clabel.DoClick = func or function() end
		clabel:SetPos(cx,cy)
		clabel:SetTextSize(size or 6,8)
		clabel:TextAlignCenter()
		clabel:SetText("")
		clabel:SetDelegate(editpane)
		return clabel
	end

	local cl = makeLabel()
	
	function resize()
		if(cx > cw) then cw = cx end
		if(cw > template:GetWidth()) then
			template:SetSize(cw,template:GetHeight())
		end
		if(cy + ch > template:GetHeight()) then
			template:SetSize(template:GetWidth(),cy + ch)
		end
	end

	function maxs(panel)
		local w,h = panel:GetSize()
		if(h > ch) then ch = h end
		resize()
	end

	function append(str)
		cl:SetText(cl:GetText() .. str)
		cl:ScaleToContents()
		maxs(cl)
	end

	function appendPanel(panel)
		cx = cx + panel:GetWidth()
		maxs(panel)
	end
	
	function finishLabel()
		if(cl != nil) then
			cx = cx + cl:GetWidth()
		end
		maxs(cl)
	end

	function newLine()
		cy = cy + ch
		cx = 0
	end
	
	function onLink(file)
		frame:Remove()
		doMarkupFile(file)
	end
	
	function onMacro(t)
		if(t == "closewindow") then frame:Close() end
	end

	function link(args)
		local btn = makeButton(nil,function() onLink(args['dest']) end)
		btn:SetText(args['text'])
		btn:ScaleToContents()
		btn:SetFGColor(0,.4,.8,1)
		appendPanel(btn)
	end
	
	function macro(args)
		local btn = makeButton(nil,function() onMacro(args['dest']) end)
		btn:SetText(args['text'])
		btn:ScaleToContents()
		btn:SetFGColor(0,.8,.4,1)
		appendPanel(btn)
	end

	stream(filename,
	function(tag)
		finishLabel()
		if(tag.name == "newline") then newLine() end
		if(tag.name == "link") then link(tag.args) end
		if(tag.name == "macro") then macro(tag.args) end
		cl = makeLabel()
	end,
	function(ch)
		if(ch == "\n" or ch == "\t" or ch == "\r") then return end
		append(ch)
	end)
	
	finishLabel()
	resize()
	
	return frame
end

doMarkupFile("lua/includes/markuptest.qml")