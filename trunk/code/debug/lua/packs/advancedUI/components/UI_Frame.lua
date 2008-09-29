local Panel = {}
Panel.bgcolor = {0.3,0.3,0.3,.8}

function Panel:Initialize()
	self.contentPane = UI_Create("panel",self)
	
	self.dragbar = UI_Create("dragbutton",self,true)
	self.dragbar:AffectParent(true)
	self.dragbar:SetText("Untitled")
	self.dragbar:SetTextSize(8)
	
	self.close = UI_Create("button",self,true)
	self.close:SetText("X")
	self.close.DoClick = function()
		self:Remove()
	end
	
	self.dragbar2 = UI_Create("dragbutton",self,true)
	self.dragbar2:SetSize(12,10)
	self.dragbar2:LockCenter(true)
	self.dragbar2.Affect = function(db,dx,dy)
		--db.x = db.x + dx
		--db.y = db.y + dy
	
		if(db.x < self.dragbar:TextWidth() + 5) then
			db.x = self.dragbar:TextWidth() + 5
		end
		if(db.y < 20) then 
			db.y = 20
		end
	
		self:SetSize(db.x+12,db.y+10)
		self:InvalidateLayout()
	end
	
	self:PositionBar()
	self:AlignContentPane()
end

function Panel:SetTitle(t)
	self.dragbar:SetText(t)
end

function Panel:AlignContentPane()
	self.contentPane:SetPos(2,12)
	self.contentPane:SetSize(self:GetWidth()-4,self:GetHeight()-20)
end

function Panel:GetContentPane()
	return self.contentPane
end

function Panel:PositionBar()
	self.dragbar:SetPos(0,0)
	self.dragbar:SetSize(self:GetWidth(),12)
	self.close:SetSize(20,12)
	
	self.dragbar2:SetPos(self:GetWidth() - self.dragbar2:GetWidth(),
						 self:GetHeight() - self.dragbar2:GetHeight())
						 
	self.close:SetPos(self:GetWidth() - self.close:GetWidth(),0)
end

function Panel:SetSize(w,h)
	self.BaseClass.SetSize(self,w,h)
	self:PositionBar()
	self:AlignContentPane()
end

function Panel:ConstrainToScreen(b)
	self.dragbar:ConstrainToScreen(b)
end

registerComponent(Panel,"frame","panel")