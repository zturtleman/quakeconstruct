local Panel = {}
Panel.text = ""
Panel.textsize = 10
Panel.align = 0

function Panel:Initialize()

end

function Panel:SetText(t)
	if(type(t) == "string") then
		self.text = t
	end
end

function Panel:GetText()
	return self.text
end

function Panel:SetTextSize(s)
	self.textsize = s
end

function Panel:GetTextSize()
	return self.textsize
end

function Panel:TextAlignLeft()
	self.align = 1
end

function Panel:TextAlignRight()
	self.align = 2
end

function Panel:TextAlignCenter()
	self.align = 0
end

function Panel:MaskMe()
	local par = self:GetDelegate()
	if(par) then
		local w,h = par:GetSize()
		if(w < 0) then w = 0 end
		if(h < 0) then h = 0 end
		if(self:TouchingEdges(par) or self.w < self:TextWidth()) then
			draw.MaskRect(
			par:GetX(),
			par:GetY(),
			w,
			h)
			return true
		end
	end
	return false
end

function Panel:StrLen()
	return string.len(fixcolorstring(self.text))
end

function Panel:ScaleToContents()
	local ts = self.textsize
	local sw = (ts * self:StrLen()) + 10
	local sh = ts + 10
	self:SetSize(sw,sh)
end

function Panel:TextWidth()
	local ts = self.textsize
	local sw = (ts * self:StrLen())
	return sw
end

function Panel:Draw()
	self:DrawBackground()
	SkinCall("DrawLabelForeground")
end

registerComponent(Panel,"label","panel")