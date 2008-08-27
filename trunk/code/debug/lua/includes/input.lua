mouseDown = false
local function keyed(key,state)
	if(key == K_MOUSE1) then
		if(state == false) then
			if(mouseDown != state) then
				mouseDown = state
				CallHook("MouseUp")
			end
		else
			if(mouseDown != state) then
				mouseDown = state
				CallHook("MouseDown")
			end
		end
	end
end
hook.add("KeyEvent","input",keyed)