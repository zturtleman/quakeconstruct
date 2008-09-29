local Panel = {}

Panel.bgcolor = {1,0.2,0,.5}
Panel.fgcolor = {0,1,0,.5}

function Panel:Initialize()

	self.canvas = UI_Create("panel",self)
	self.scrollbar = UI_Create("scrollbar",self)
	self.scrollbar:SetSize(10,10)
	self.scrollbar.OnScroll = function(sb,v)
		self.canvas.y = -(self.canvas:GetHeight() - self:GetHeight())*v
	end
	
	self.canvas:SetSize(0,300)
	
	local btn = UI_Create("button",self.canvas)
	btn:SetPos(10,20)
	btn:SetSize(70,30)
	btn:SetText("'Ello!")
	btn:SetDelegate(self)
end

function Panel:DoLayout()
	self:Expand()
	self.canvas:SetSize(self:GetWidth(),self.canvas:GetHeight())
	self.scrollbar:DoLayout()
	
	if(self.canvas:GetHeight() > self:GetHeight()) then
		self.scrollbar:SetRange((self.canvas:GetHeight() - self:GetHeight()) / self:GetHeight())
	else
		self.scrollbar:SetRange(0)
	end
end

registerComponent(Panel,"listpane","panel")