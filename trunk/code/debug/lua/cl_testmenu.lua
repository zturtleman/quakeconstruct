local sayings = {"I like pie","qconstruct is awesome","hello","woot","potato","nice shot","ouch","lol"}
local cheats = {"god","noclip","give all"}

local menutest = {}
local currmenu = ""

function menutest.scripts(side,dir,l,u)
	currmenu = "scripts"
	altmenu.textSize(10,20)
	altmenu.clearButtons()
	if(l > 0) then
		local sub = 5
		if(l-sub < 0) then
			sub = sub + (l-sub)
		end
		altmenu.addButton("/\\",menutest.scripts,side,dir,l-sub,u)
	else
		altmenu.addButton("^8/\\")
	end
	
	local c = 0
	for filename in lfs.dir(dir) do
		local attr = lfs.attributes(dir .. "/" .. filename)
		if (attr.mode == "directory" and filename != ".." and filename != ".") then
			if(c >= l and c < l+u) then
				altmenu.addButton(filename,menutest.scripts,side,dir .. "/" .. filename,0,u)
			end
			c = c + 1
		end
	end
	for filename in lfs.dir(dir) do
		local attr = lfs.attributes(dir .. "/" .. filename)
		if not(attr.mode == "directory") then
			if(string.GetExtensionFromFilename(filename) == "lua") then
				if(side == "client" and string.find(filename,"cl_")) then
					if(c >= l and c < l+u) then
					altmenu.addButton(filename,function() include(dir .. "/" .. filename) end)
					end
					c = c + 1
				end
				if(side == "server" and !string.find(filename,"cl_")) then
					if(c >= l and c < l+u) then
					local dirx = string.sub(dir,6,string.len(dir))
					local filex = string.sub(filename,0,string.len(filename)-4)
					
					altmenu.addButton(filename,function() ConsoleCommand("load " .. dirx .. "/" .. filex) end)
					end
					c = c + 1				
				end
			end
		end
	end
	if(c > (l+u)) then
		local add = 7
		if((l+u+add) > c) then
			add = add - ((l+u+add) - (c))
		end
		altmenu.addButton("\\/",menutest.scripts,side,dir,l+add,u)
	else
		altmenu.addButton("^8\\/")
	end
	if(dir == "./lua") then
		altmenu.addButton("<-(Back)",menutest.main)
	else
		local fname = string.GetFileFromFilename(dir)
		local bdir = string.sub(dir,0,string.len(dir)-(string.len(fname)))
		altmenu.addButton("<-(Back)",menutest.scripts,side,bdir,0,u)
	end
end

function menutest.speech()
	currmenu = "speech"
	altmenu.textSize(8,12)
	altmenu.clearButtons()
	for k,v in pairs(sayings) do
		altmenu.addButton("^2" .. v,function()
			ConsoleCommand("say " .. v)
		end)
	end
	altmenu.addButton("<-(Back)",menutest.main)
end

function menutest.cheats()
	currmenu = "cheats"
	altmenu.textSize(12,10)
	altmenu.clearButtons()
	for k,v in pairs(cheats) do
		altmenu.addButton("^2" .. v,function() 
			ConsoleCommand(v)
		end)
	end
	altmenu.addButton("<-(Back)",menutest.main)
end

function menutest.main()
	currmenu = "main"
	altmenu.textSize(10,12)
	altmenu.clearButtons()
	altmenu.addButton("^1Suicide",function() ConsoleCommand("kill") end)
	altmenu.addButton("Speech Menu",menutest.speech)
	altmenu.addButton("Cheats",menutest.cheats)
	altmenu.addButton("Client Scripts",menutest.scripts,"client","./lua",0,10)
	altmenu.addButton("Server Scripts",menutest.scripts,"server","./lua",0,10)
end
menutest.main()

local function open()
	--if(currmenu == "scripts") then
		--menutest.main()
	--end
end
hook.add("AltMenuOpen","cl_init",open)