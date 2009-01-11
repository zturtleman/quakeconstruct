panel = panel or nil
local Skin = {}
local shader = LoadShader("9slice1")
local softwaremask = true
local maskOn = false

function SkinCall(func,...)
	if(Skin[func]) then
		local b,e = pcall(Skin[func],Skin,unpack(arg))
		if(!b) then print(e .. "\n") end
		if(b and e) then return e end
	end
end

function SkinPanel(p)
	panel = p
end

function Skin:DefaultBG()
	return {.2,.25,.35,1}
end

function Skin:DefaultFG()
	return {.75,.8,.7,1}
end

function Skin:StartMask(...)
	if(softwaremask) then
		softmask.Set(unpack(arg))
	else
		draw.MaskRect(unpack(arg))
	end
	maskOn = true
end

function Skin:EndMask()
	if(softwaremask) then
		softmask.Reset()
	else
		draw.EndMask()
	end
	maskOn = false
end

function Skin:DoFG()
	sk.qcolor(panel.fgcolor)
end

function Skin:DoBG()
	sk.qcolor(panel.bgcolor)
end

function Skin:Text(...)
	if(softwaremask) then
		if(maskOn) then
			softmask.Text(unpack(arg))
		else
			draw.Text(unpack(arg))
		end
	else
		draw.Text(unpack(arg))
	end
end

function Skin:DrawBGRect(...)
	--drawNSBox(x,y,w,h,4,shader)
	if(softwaremask) then
		softmask.Rect(unpack(arg))
	else
		draw.Rect(unpack(arg))
	end
	RECT_DRAW = RECT_DRAW + 1
end

function Skin:DrawBevelRect(x,y,w,h,d)
	sk.coloradjust(nil,2*d)
	SkinCall("DrawBGRect",x,y,w,2)
	sk.restore()
	
	sk.coloradjust(nil,1*d)
	SkinCall("DrawBGRect",x,y,2,h)
	sk.restore()
	
	sk.coloradjust(nil,-1*d)
	SkinCall("DrawBGRect",x+(w-2),y,2,h)
	sk.restore()
	
	sk.coloradjust(nil,-2*d)
	SkinCall("DrawBGRect",x,y+(h-2),w,2)
	sk.restore()
end

function Skin:DrawNeon(x,y,w,h,i)
	sk.qcolor({.2,1,.1,.4})

	local i2 = i*2
	
	SkinCall("DrawBGRect",x+i,y+i,w-i2,1)
	SkinCall("DrawBGRect",x+i,y+i,1,h-i2)
	SkinCall("DrawBGRect",(x+(w-1))-i,y+i,1,h-i2)
	SkinCall("DrawBGRect",x+i,(y+(h-1))-i,w-i2,1)
end

function Skin:DrawBackground(d)
	local x,y = panel:GetPos()
	d = d or .04
	SkinCall("DrawBGRect",x,y,panel.w,panel.h)
	SkinCall("DrawBevelRect",x,y,panel.w,panel.h,d)
	--SkinCall("DrawNeon",x,y,panel.w,panel.h,-1)
end

function Skin:DrawButtonBackground(over,down)
	local nbg = {panel.bgcolor[1],panel.bgcolor[2],panel.bgcolor[3],panel.bgcolor[4]}
	
	if(down) then
		panel.bgcolor = sk.coloradjust(nbg,-.2)
		SkinCall("DrawBackground",-.1)
	elseif(over) then
		panel.bgcolor = sk.coloradjust(nbg,.1)
		SkinCall("DrawBackground",.1)
	else
		sk.qcolor(panel.bgcolor)
		SkinCall("DrawBackground")
	end
	
	panel.bgcolor[1] = nbg[1]
	panel.bgcolor[2] = nbg[2]
	panel.bgcolor[3] = nbg[3]
	panel.bgcolor[4] = nbg[4]
end

function Skin:DrawLabelForeground()
	local ts = panel:GetTextSize()
	local x,y = panel:GetPos()
	
	y = y + (panel.h/2) - (ts/2)	
	
	if(panel.align == 0) then
		x = x + (panel.w/2) - (ts * panel:StrLen())/2
	elseif(panel.align == 2) then
		x = x + (panel.w) - (ts * panel:StrLen())
		x = x - 2
	else
		x = x + 2
	end
	
	panel:DoFGColor()
	SkinCall("Text",x,y,panel.text,ts,ts)
end

function Skin:DrawModelPane()
	if(panel.model != nil) then
		render.CreateScene()

		panel:DrawModel()		

		local refdef = {}
		
		refdef.origin = panel.org

		local aim = VectorNormalize(refdef.origin)
		aim = vMul(aim,-1)
		aim = VectorToAngles(aim)

		refdef.angles = aim

		refdef.x = panel:GetX()
		refdef.y = panel:GetY()
		refdef.width = panel:GetWidth()
		refdef.height = panel:GetHeight()
		render.RenderScene(refdef)

		panel.rot = panel.rot + 1
	end
end

function Skin:DrawShadow()
	if(true) then return end
	panel:DoBGColor()
	sk.coloradjust(panel.bgcolor,-.3,.2)
	
	local x,y = panel:GetPos()
	sk.coloradjust(nil,0,.6)
	SkinCall("DrawBGRect",x-2,y-2,panel.w+4,panel.h+4)
	sk.coloradjust(nil,0,.4)
	SkinCall("DrawBGRect",x-4,y-4,panel.w+8,panel.h+8)
	sk.coloradjust(nil,0,.2)
	SkinCall("DrawBGRect",x-6,y-6,panel.w+12,panel.h+12)
end

function Skin:DrawTextArea()
	panel:DoFGColor()
	for k,v in pairs(panel.lines) do
		k = k * panel.spacing
		SkinCall("Text",panel:GetX(),(panel:GetY() + ((k-panel.spacing)*panel.th)),v,panel.tw,panel.th)
	end
	
	if((LevelTime() % 500) > 200) then
		SkinCall("Text",panel:GetX() + panel.caret[1]*panel.tw,panel:GetY() + panel.caret[2]*panel.th,"\t",panel.tw,panel.th)
	end
end