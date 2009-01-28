local dropdowns = {}

if(menubar != nil) then menubar:Remove()
	menubar = nil
end
menubar = UI_Create("panel")

local lastx = 0
local template = UI_Create("button")
template:SetPos(0,20)
template:SetSize(100,15)
template:SetTextSize(8)		
template:SetText("<nothing here>")
template:TextAlignCenter()
template:Remove()

if(menubar != nil) then
	menubar.name = "base"
	menubar:SetPos(0,0)
	menubar:SetSize(640,20)
	menubar:CatchMouse(true)
	menubar:SetVisible(false)
end

local function makeDropdown(name)
	local p = UI_Create("panel")
	p.name = name
	p:SetVisible(false)
	
	local b = UI_Create(template,menubar)
	b.DoLayout = function(self)
		local h = self:GetParent():GetHeight()
		self:SetSize(self:GetWidth(),h)
	end
	b.DoClick = function(self)
		p:SetVisible(true)
	end
	b.OtherClick = function(self,other)
		if(other != p) then
			p:SetVisible(false)
		end
	end
	b:SetText(name)
	b:SetPos(lastx,0)
	b:ScaleToContents()
	lastx = b:GetX() + b:GetWidth()
	
	p:SetPos(b:GetX(),20)
	p:SetSize(100,5)
	
	p:SetDelegate(menubar)
	p.ShouldMask = function() return false end
	
	p.lasty = 0
	dropdowns[name] = p
	return p
end

local function insertItem(d,name,func)
	local b = UI_Create(template,d)
	b.name = "dropdown_item"
	if(func != nil) then
		b.DoClick = function(self) pcall(func,name) end
	end
	b:SetText(name)
	b:SetPos(3,d.lasty+3)
	b:ScaleToContents()
	if(b:GetWidth() > d:GetWidth()) then
		d:SetSize(b:GetWidth(),d:GetHeight())
	else
		b:SetSize(d:GetWidth()-6,b:GetHeight()-6)
	end
	local h = b:GetHeight()
	d:SetSize(d:GetWidth(),d:GetHeight() + h)
	d.lasty = d.lasty + h
end

local t = makeDropdown("test")

insertItem(t,"test1")
insertItem(t,"test2")
insertItem(t,"test3")
insertItem(t,"test4")

local function keyed(key,state)
	if(key == K_ALT) then
		menubar:SetVisible(state)
	end
end
hook.add("KeyEvent","cl_menubar",keyed)