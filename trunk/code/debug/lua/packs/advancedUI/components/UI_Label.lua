local Panel = {}
Panel.text = ""
Panel.textsize = 10

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

function Panel:ScaleToContents()
	local ts = self.textsize
	local sw = (ts * string.len(self.text)) + 10
	local sh = ts + 10
	self:SetSize(sw,sh)
end

function Panel:TextWidth()
	local ts = self.textsize
	local sw = (ts * string.len(self.text))
	return sw
end

function Panel:Draw()
	local ts = self.textsize
	local x,y = self:GetPos()
	self:DrawBackground()
	
	x = x + (self.w/2) - (ts * string.len(self.text))/2
	y = y + (self.h/2) - (ts/2)
	
	self:DoFGColor()
	draw.Text(x,y,self.text,ts,ts)
end

registerComponent(Panel,"label","panel")