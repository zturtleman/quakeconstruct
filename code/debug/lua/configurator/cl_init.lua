configurator = {}

local tabmaxw = 0
local ptemp = {}
local main = nil
local tabBar = nil
local currTab = "Main"
local layout = nil

local function slider(par)
	local panel = UI_Create("valuebar",par)
	panel:SetMax(100)
	panel:SetMin(40)
	panel.FormatValue = function(self,v) return "" .. v end
	panel.DoLayout = function()
		panel:SetSize(par:GetWidth(),18)
	end
	
	return panel
end

local function addPanel()
	local panel = UI_Create("panel",main)
	panel:CatchMouse(true)
	panel:SetVisible(true)
	table.insert(ptemp,panel)
	return panel
end

local function populate(panel)
	local s = slider(panel)
	s:SetSize(panel:GetWidth(),20)
end

local function addTab(name)
	local tab = UI_Create("button",tabBar)
	tab.DoClick = function()
		currTab = name
		layout(main)
	end
	tab:SetPos(tabmaxw,0)
	tab:SetText(name)
	tab:ScaleToContents()
	tab:SetSize(tab:GetWidth(),32)
	tabmaxw = tabmaxw + tab:GetWidth()
end

layout = function(panel)
	for k,v in pairs(ptemp) do
		v:Remove()
	end
	ptemp = {}
	tabmaxw = 0
	
	main = panel
	tabBar = addPanel()
	tabBar:SetPos(0,0)
	tabBar.DoLayout = function(self)
		self:SetSize(main:GetWidth(),32)
	end
	addTab("Main")
	addTab("Weapons")
	
	local contents = addPanel()
	contents:SetPos(0,32)
	contents:SetSize(main:GetWidth(),main:GetHeight() - 32)
	contents.DoLayout = function(self)
		self:SetSize(main:GetWidth(),main:GetHeight() - 32)
	end
	
	populate(contents)
end

function configurator.open()
	local panel = UI_Create("frame")
	if(panel != nil) then
		local w,h = 640,480
		local pw,ph = w/2,h/2
		panel:SetPos((w/2) - pw/2,(h/2) - ph/2)
		panel:SetSize(pw,ph)
		panel:SetTitle("Configurator")
		panel:CatchMouse(true)
		panel:SetVisible(true)
		layout(panel)
	end
end
addToAltMenu("Configurator",configurator.open)

configurator.open()
print("BLAH\n")