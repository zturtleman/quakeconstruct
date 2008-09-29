local function draw2d()
	if(MouseFocused()) then
		draw.SetColor(1,1,1,.6)
		if(MouseDown()) then draw.SetColor(1,.7,.7,.8) end
		draw.Rect(GetXMouse()-5,GetYMouse()-5,10,10)
	end
end
hook.add("Draw2D","UIcursor",draw2d,999)