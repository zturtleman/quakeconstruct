configurator = {}

local tabmaxw = 0
local ptemp = {}
local main = nil
local tabBar = nil
local currTab = "Main"
local layout = nil

local sliderTemplate = UI_Create("valuebar")
sliderTemplate:SetSize(18,18)
sliderTemplate:Remove()

local seperatorTemplate = UI_Create("label")
seperatorTemplate:SetSize(22,22)
seperatorTemplate:Remove()

local function sliderMoved(tab,v)
	print("Value For: " .. tab[3] .. " [" .. v .. "]\n")
	SendString("cnfvar " .. tab[3] .. " " .. v .. "")
end

local sliders = {
	["Weapons"] = {
		{"slider","Delay%","wp_delay",10,1000,100,"int",10},
		{"slider","Damage%","wp_damage",10,1000,100,"int",10}
	}
}

local function slider(list,tab)
	--[[panel.DoLayout = function()
		panel:SetSize(par:GetWidth(),18)
	end]]
	
	local panel = list:AddPanel(sliderTemplate,true)
	
	local step = tab[8]
	
	panel:SetTitle(tab[2])
	panel:SetMax(tab[5])
	panel:SetMin(tab[4])
	panel.FormatValue = function(self,v)
		if(step) then
			v = v / step
			v = math.floor(v)*step
		end
		if(tab[7] == "int") then
			return math.floor(v)
		elseif(tab[7] == "lowerfloat") then
			if(v > 1) then return math.floor(v) end
			v = v * 10
			v = math.floor(v)/10
			return v
		else
			return v
		end
	end
	panel.OnValue = function(s,v)
		sliderMoved(tab,v)
	end
	panel:CatchMouse(true)
	panel:SetValue(tab[6])
	
	list:DoLayout()
	
	return panel
end

local function seperator(list,label)
	local panel = list:AddPanel(seperatorTemplate,true)
	
	panel:SetText(label)
	
	list:DoLayout()
end

local function addPanel(class)
	local panel = UI_Create(class or "panel",main)
	--panel:CatchMouse(true)
	--panel:SetVisible(true)
	table.insert(ptemp,panel)
	return panel
end

local function populate(panel)
	--local list = UI_Create("listpane",panel)
	--list:CatchMouse(true)
	--list:DoLayout()
	local group = sliders[currTab]
	
	if(group != nil) then
		for k,v in pairs(group) do
			if(v[1] == "slider") then slider(panel,v) end
			if(v[1] == "group") then seperator(panel,v[2]) end
		end
	end
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
	
	local contents = addPanel()--addPanel()
	contents:SetPos(0,32)
	contents.DoLayout = function(self)
		self:SetSize(main:GetWidth()-4,main:GetHeight() - 62)
	end
	contents:DoLayout()
	
	local list = UI_Create("listpane",contents)
	--list:CatchMouse(true)
	--list:SetVisible(true)
	
	populate(list)
end

function configurator.open()
	if(configurator_panel == nil) then
		configurator_panel = UI_Create("frame")
		local panel = configurator_panel
		if(panel != nil) then
			local w,h = 640,480
			local pw,ph = w/2,h/2
			panel:SetPos((w/2) - pw/2,(h/2) - ph/2)
			panel:SetSize(pw,ph)
			panel:SetTitle("Configurator")
			panel:CatchMouse(true)
			panel:SetVisible(false)
			panel:RemoveOnClose(false)
			layout(panel)
		end
	else
		configurator_panel:SetVisible(true)
	end
end
if(addToAltMenu) then
	addToAltMenu("Configurator",configurator.open)
end
concommand.add("openconfig",configurator.open)

configurator.open()
print("BLAH\n")