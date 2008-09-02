local mx = 0
local my = 0
local cursorOn = false

local function moused(x,y)
	mx = mx + x
	my = my + y
	
	if(mx > 640) then mx = 640 end
	if(mx < 0) then mx = 0 end
	
	if(my > 480) then my = 480 end
	if(my < 0) then my = 0 end
end
hook.add("MouseEvent","cl_menu",moused)

function GetXMouse()
	return mx
end

function GetYMouse()
	return my
end

function EnableCursor(b)
	if(b) then
		util.LockMouse(true)
		cursorOn = true
	else
		util.LockMouse(false)
		cursorOn = false
	end
end