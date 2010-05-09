configurator = {}

local tabmaxw = 0
local ptemp = {}
local main = nil
local tabBar = nil
local currTab = "Server"
local layout = nil

local sliderTemplate = UI_Create("valuebar")
sliderTemplate:SetTextSize(8,8)
sliderTemplate:SetSize(16,16)
sliderTemplate:Remove()

local seperatorTemplate = UI_Create("label")
seperatorTemplate:SetSize(22,22)
seperatorTemplate:Remove()

local function sliderMoved(tab,v)
	print("Value For: " .. tab[3] .. " [" .. v .. "]\n")
	SendString("cnfvar " .. tab[3] .. " " .. v .. "")
end

local SL_TYPE = 1
local SL_LABEL = 2
local SL_VAR = 3
local SL_MIN = 4
local SL_MAX = 5
local SL_DEF = 6
local SL_FMT = 7
local SL_STEP = 8
local SL_COMP = 9

local sliders = {
	["Pickups"] = {
		{"group","Quantities:"},
		{"slider","Pickup Multiplier","pk_multiplier",0,10,1,"lowerfloat",nil},
		{"slider","Ammo Multiplier","pk_mult_ammo",0,10,1,"lowerfloat",nil},
		{"slider","Armor Multiplier","pk_mult_armor",0,10,1,"lowerfloat",nil},
		{"slider","Health Multiplier","pk_mult_health",0,10,1,"lowerfloat",nil},
		{"slider","Powerup Multiplier","pk_mult_powerup",0,10,1,"lowerfloat",nil},
		{"slider","Weapon Multiplier","pk_mult_weapon",0,10,1,"lowerfloat",nil},
	},
	["Hazards"] = {
		{"group","Damage%:"},
		{"slider","Water","hz_damage_water",0,1000,100,"int",10},
		{"slider","Slime","hz_damage_slime",0,1000,100,"int",10},
		{"slider","Lava","hz_damage_lava",0,1000,100,"int",10},
		{"slider","Crushers","hz_damage_crush",0,1000,100,"int",10},
		{"slider","Falling","hz_damage_falling",0,1000,100,"int",10},
	},
	["Weapons"] = {
		{"group","Global:"},
		{"slider","Delay%","wp_delay",0,1000,100,"int",10},
		{"slider","Damage%","wp_damage",0,1000,100,"int",10},
		{"slider","Quad Factor","-g_quadfactor",1,10,3,"int",1},
		{"group","Specific:"},
	},
	["Server"] = {
		{"group","Map:"},
		{"slider","Frag Limit","-fraglimit",0,500,20,"int",5},
		{"slider","Time Limit","-timelimit",0,120,0,"int",5},
		{"slider","Gravity","-g_gravity",0,1500,800,"int",50},
		{"group","Player:"},
		{"slider","Force Respawn","-g_forcerespawn",0,100,20,"int",1},
		{"slider","Speed","-g_speed",0,1000,320,"int",20},
		{"slider","Starting Health","g_starthp",1,1000,125,"int",5},
		{"slider","Maximum Health","g_maxhp",0,1000,100,"int",5},
	},
}

local nxt = WP_GAUNTLET
local function weapVars(name)
	table.insert(sliders["Weapons"],{"slider",name .. " Delay%","wp_cw" .. nxt .. "_delay",0,1000,100,"int",10})
	table.insert(sliders["Weapons"],{"slider",name .. " Damage%","wp_cw" .. nxt .. "_damage",0,1000,100,"int",10})
	nxt = nxt + 1
end

weapVars("Gauntlet")
weapVars("MachineGun")
weapVars("Shotgun")
weapVars("GrenadeLauncher")
weapVars("RocketLauncher")
weapVars("LightningGun")
weapVars("Railgun")
weapVars("PlasmaGun")
weapVars("BFG10K")

local function message(str,pl)
	local args = string.Explode(" ",str)
	if(args[1] == "rcnfvar") then
		local var = args[2]
		local val = tonumber(args[3])
		if(val == nil) then return end
		
		print("Got Value " .. var .. " = " .. val .. "\n")
		
		for k,v in pairs(sliders) do
			for _,sl in pairs(v) do
				if(sl[SL_TYPE] == "slider" and sl[SL_VAR] == var) then
					local panel = sl[SL_COMP]
					if(panel != nil) then
						local fnc = panel.OnValue
						panel:SetValue(val,true)
						print("Set Value " .. var .. " = " .. val .. "\n")
					else
						print("Panel was nil\n")
					end
				end
			end
		end
	end
end
hook.add("MessageReceived","configurator",message)

local function slider(list,tab)
	--[[panel.DoLayout = function()
		panel:SetSize(par:GetWidth(),18)
	end]]
	
	local panel = list:AddPanel(sliderTemplate,true)
	
	local step = tab[SL_STEP]
	
	panel:SetTitle(tab[SL_LABEL])
	panel:SetMax(tab[SL_MAX])
	panel:SetMin(tab[SL_MIN])
	panel.FormatValue = function(self,v)
		if(step) then
			v = v / step
			v = math.floor(v)*step
		end
		if(tab[SL_FMT] == "int") then
			return math.floor(v)
		elseif(tab[SL_FMT] == "lowerfloat") then
			if(v > 1) then return math.floor(v) end
			v = v * 10
			v = math.floor(v)/10
			return v
		elseif(tab[SL_FMT] == "float") then
			v = v * 10
			v = math.floor(v)/10
			return v
		end
	end
	
	panel:SetValue(tab[SL_DEF],true)
	panel.OnValue = function(s,v)
		sliderMoved(tab,v)
	end
	panel:CatchMouse(true)
	
	list:DoLayout()
	
	SendString("gcnfvar " .. tab[SL_VAR])
	tab[SL_COMP] = panel
	
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
			if(v[1] == "group") then seperator(panel,v[SL_LABEL]) end
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
	for k,v in pairs(sliders) do
		addTab(k)
	end
	
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

configurator_panel = nil
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