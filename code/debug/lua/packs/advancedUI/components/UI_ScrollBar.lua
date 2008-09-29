local Panel = {}

function Panel:Initialize()

	self.bgcolor = {.4,.4,.4,1}
	self.range = 0
	self.wo = false
	self.dragbar = UI_Create("dragbutton",self,true)
	self.dragbar:SetSize(self:GetWidth(),50)
	self.dragbar.bgcolor = {.7,.7,.7,1}
	self.dragbar:SetPos(0,0)
	self.dragbar:LockCenter(true)
	self.dragbar:ConstrainToParent(true)
	self.dragbar.Affect = function(db,dx,dy)
		if(db.y < 0) then 
			db.y = 0
		end
		
		if(db.y > self:GetHeight() - db:GetHeight()) then 
			db.y = self:GetHeight() - db:GetHeight()
		end
		
		if(self:BarScale() < 1) then
			self:OnScroll(self:Value())
		else
			self:OnScroll(0)
		end
	end
	
end

function Panel:BarScale()
	if(self.range <= 0) then return 1 end
	
	return 1 / (self.range + 1)
	
end

function Panel:Value()
	return (self.dragbar.y / self.dragbar:GetHeight()) / self.range
end

function Panel:SetRange(desired)
	self.range = desired
end

function Panel:SetSize(w,h)
	self.BaseClass.SetSize(self,w,h)
	self.dragbar:SetSize(self:GetWidth(),self.dragbar:GetHeight())
end

function Panel:OnScroll(v)

end

function Panel:DoLayout()
	local par = self:GetParent()
	if(par) then
		self:SetPos(par:GetWidth() - self:GetWidth(),0)
		self:SetSize(self:GetWidth(),par:GetHeight())
		
		if(self.dragbar.y < 0) then
			self.dragbar:SetPos(0,0)
		end
		if(self.dragbar.y > self:GetHeight() - self.dragbar:GetHeight()) then
			self.dragbar:SetPos(0,self:GetHeight() - self.dragbar:GetHeight())
		end
	end
	--print(self.dragbar.y .. " " .. self.dragbar:GetWidth() .. "\n")
	
	if(self.wo) then
		self.wo = false
		self:OnScroll(0)
	end
	
	if(self:BarScale() < 1) then
		self.dragbar:SetVisible(true)
		self.dragbar:SetSize(self.dragbar:GetWidth(),self:GetHeight()*self:BarScale())
		self:OnScroll(self:Value())
	else
		self.dragbar:SetVisible(false)
		self:OnScroll(0)
		self.wo = true
	end
end

registerComponent(Panel,"scrollbar","panel")