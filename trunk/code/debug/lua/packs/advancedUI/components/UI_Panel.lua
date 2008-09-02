local Panel = {}

Panel.children = {}
Panel.parent = nil
Panel.x = 0
Panel.y = 0
Panel.w = 0
Panel.h = 0
Panel.bgcolor = {0.5,0.5,0.5,.8}
Panel.fgcolor = {1,1,1,.8}

function Panel:DrawBackground()
	local b = self.bgcolor
	draw.SetColor(b[1],b[2],b[3],b[4])
	draw.Rect(self.x,self.y,self.w,self.h)
end

function Panel:Draw()
	self:DrawBackground()
end

function Panel:Think()
	
end

function Panel:__addChild(child)
	table.insert(self.children,child)
end

function Panel:__removeChild(child)
	for k,v in pairs(table.Copy(self.children)) do
		if(v == child) then
			table.remove(self.children,k)
		end
	end
end

function Panel:SetBGColor(r,g,b,a)
	self.bgcolor = {r,g,b,a}
end

function Panel:SetFGColor(r,g,b,a)
	self.fgcolor = {r,g,b,a}
end

function Panel:SetParent(panel)
	if(self.parent) then self.parent:__removeChild(self) end
	self.parent = panel
	if(self.parent) then self.parent:__addChild(self) end
end

function Panel:GetParent()
	return self.parent
end

function Panel:SetPos(x,y)
	if(self.parent) then
		x = x + parent.x
		y = y + parent.y
	end
	self.x = x
	self.y = y
end

function Panel:GetPos()
	return self.x, self.y
end

function Panel:SetSize(w,h)
	self.w = w
	self.h = h
end

function Panel:GetSize()
	return self.w, self.h
end

function Panel:Remove()
	self.removeme = true
end

registerComponent(Panel,"panel")