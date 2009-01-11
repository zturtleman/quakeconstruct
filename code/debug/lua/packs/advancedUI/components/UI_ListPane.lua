local Panel = {}

Panel.bgcolor = {1,0.2,0,.5}
Panel.fgcolor = {0,1,0,.5}

function Panel:Initialize()

	self.panes = {}
	self.np = 1
	self.canvas = UI_Create("panel",self)
	self.canvas.ShouldDraw = function() return false end
	self.scrollbar = UI_Create("scrollbar",self)
	self.scrollbar:SetSize(12,12)
	self.scrollbar.OnScroll = function(sb,v)
		self.canvas.y = -(self.canvas:GetHeight() - self:GetHeight())*v
	end
	
	self.canvas:SetSize(0,0)
	
	--local btn = UI_Create("button")
	--btn:SetPos(0,20)
	--btn:SetSize(100,20)
	--btn:SetText("'Ello!")
	
	--for i=0, 12 do
		--self:AddPanel(btn,true)
	--end
	--Timer(4,self.Clear,self)
end

function Panel:Draw() end

function Panel:Clear()
	self.canvas:SetSize(0,0)
	self.scrollbar:SetRange(0)
	self.scrollbar:DoLayout()
	for k,v in pairs(self.panes) do
		v[1]:Remove()
	end
end

function Panel:AddPanel(add,autoscale)
	local pane = UI_Create(add,self.canvas,true)
	pane.rmvx = 0
	pane.removeme = false
	
	add:Remove()
	
	pane:SetDelegate(self)
	pane:SetPos(pane:GetLocalX(),self.canvas:GetHeight())
	
	local fh = pane:GetLocalY() + pane:GetHeight()
	if(fh > self.canvas:GetHeight()) then
		self.canvas:SetSize(self.canvas:GetWidth(),fh)
	end
	
	table.insert(self.panes,{pane,autoscale})
	return pane
end

function Panel:OnRemove()
	self.BaseClass.OnRemove(self)
	self.panes = nil
end

function Panel:DoLayout()
	if(self:GetParent()) then
		self:Expand()
	end
	self.canvas:SetSize(self:GetWidth() - self.scrollbar:GetWidth(),self.canvas:GetHeight())
	self.scrollbar:DoLayout()
	
	if(self.canvas:GetHeight() > self:GetHeight()) then
		self.scrollbar:SetRange((self.canvas:GetHeight() - self:GetHeight()) / self:GetHeight())
	else
		self.scrollbar:SetRange(0)
	end
	
	for k,v in pairs(self.panes) do
		local pane = v[1]
		local scale = v[2]
		if(scale) then
			pane:SetSize(self.canvas:GetWidth(),pane:GetHeight())
		end
	end
end

registerComponent(Panel,"listpane","panel")