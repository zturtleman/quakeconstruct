local Panel = {}

Panel.parent = nil
Panel.x = 0
Panel.y = 0
Panel.w = 0
Panel.h = 0
Panel.bgcolor = {0.5,0.5,0.5,.8}
Panel.fgcolor = {1,1,1,.8}
Panel.shader = LoadShader("flareShader")
Panel.pset = false
Panel.visible = true
Panel.constToParent = false
Panel.valid = true
Panel.removeme = false
Panel.rmvx = 0

function Panel:Initialize()

end

function Panel:DoFGColor()
	local b = self.fgcolor
	draw.SetColor(b[1],b[2],b[3],b[4])
end

function Panel:DoBGColor()
	local b = self.bgcolor
	draw.SetColor(b[1],b[2],b[3],b[4])
end

function Panel:DrawBackground()
	local x,y = self:GetPos()
	self:DoBGColor()
	draw.Rect(x,y,self.w,self.h)
	
	--if(self:MouseOver()) then
		--draw.Rect(x,y,self.w,self.h)
	--end
	
	--drawNSBox(100,100,10,10,2,self.shader)
end

function Panel:MaskMe()
	if(self.parent) then
		draw.MaskRect(
		self.parent:GetX(),
		self.parent:GetY(),
		self.parent:GetWidth(),
		self.parent:GetHeight())
	end
end

function Panel:Draw()
	self:DrawBackground()
	--self:DrawChildren()
end

function Panel:ConstrainToParent(b)
	self.constToParent = b
end

function Panel:EndMask()
	draw.EndMask()
end

function Panel:Think()

end

function Panel:SetBGColor(r,g,b,a)
	self.bgcolor = {r,g,b,a}
end

function Panel:SetFGColor(r,g,b,a)
	self.fgcolor = {r,g,b,a}
end

function Panel:GetParent()
	return self.parent
end

function Panel:SetPos(x,y)
	self.x = x
	self.y = y
	
	if(self.constToParent and self.parent) then
		if(self.x < 0) then self.x = 0 end
		if(self.y < 0) then self.y = 0 end
		
		if(self.x + self.w > self.parent:GetWidth()) then 
			self.x = self.parent:GetWidth() - self.w 
		end
		if(self.y + self.h > self.parent:GetHeight()) then 
			self.y = self.parent:GetHeight() - self.h 
		end
	end
end

function Panel:GetX()
	if(self.parent) then
		return self.x + self.parent:GetX()
	end
	return self.x
end

function Panel:GetY()
	if(self.parent) then
		return self.y + self.parent:GetY()
	end
	return self.y
end

function Panel:GetPos()
	return self:GetX(), self:GetY()
end

function Panel:SetSize(w,h)
	self.w = w
	self.h = h
	self:DoLayout()
	self:InvalidateLayout()
end

function Panel:GetWidth() return self.w end
function Panel:GetHeight() return self.h end

function Panel:GetSize()
	return self:GetWidth(), self:GetHeight()
end

function Panel:OnRemove() end

function Panel:Remove()
	self:OnRemove()
	self.removeme = true
	self.rmvx = 1
end

function Panel:SetVisible(b)
	self.visible = b
end

function Panel:GetContentPane() return nil end
function Panel:MouseOver() return self.__mouseInside end
function Panel:MouseDown() return self.__wasPressed end
function Panel:MousePressed(x,y) end
function Panel:MouseReleased(x,y) end
function Panel:MouseReleasedOutside(x,y) end
function Panel:DoLayout() end

function Panel:InvalidateLayout()
	self.valid = false
end

function Panel:IsVisible()
	if(self.parent) then
		return self.parent:IsVisible()
	end
	return self.visible
end

function Panel:ScaleToContents() end

function Panel.__eq(p1,p2)
	return p1.ID == p2.ID
end

registerComponent(Panel,"panel")