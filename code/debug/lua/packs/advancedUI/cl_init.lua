UI_Components = {}
UI_Active = {}
local toRegister = 0
local nxtID = 0

P:include("cursor.lua")

function UI_ERROR(txt)
	print("^1UI ERROR: " .. txt .. "\n")
end

function parentComponents()
	local finished = false
	local nl = true
	local maxiter = 100
	local i = 0
	local lc = 0
	while(nl == true and i < maxiter) do
		nl = false
		for k,v in pairs(UI_Components) do
			if(!v.__loaded) then
				local base = v._mybase
				local name = v._myname
				--if(base == nil) then base = "panel" end
				if(type(base) == "string" and UI_Components[base] and base != name) then
					if(UI_Components[base].__loaded == true) then
						v = table.Inherit( v, UI_Components[base] )
						print("Parented: " .. name .. " -> " .. base .. "\n")
						lc = lc + 1
						v.__loaded = true
					else
						nl = true
					end
				else
					lc = lc + 1
					v.__loaded = true
				end
			end
		end
		i = i + 1
	end
	print("Loaded " .. lc .. " components with " .. i .. " iterations.\n")
end

function registerComponent(tab,name,base)
	if(UI_Components[name] == nil) then
		UI_Components[name] = tab
		tab._mybase = base
		tab._myname = name
	end
	print("Registered " .. name .. "\n")
end

local currentInit = nil

function UI_EnableCursor(b)
	local hold = false
	for k,v in pairs(UI_Active) do
		if(v.catchm and v.removeme == false) then hold = true end
	end
	if(b != true and hold) then return end
	EnableCursor(b)
end

function UI_Create(name,parent,force)
	if(currentInit == name) then
		UI_ERROR("A " .. name .. " attempted to create itself in it's 'Initialize' function.")
		return nil
	end
	local tab = UI_Components[name]
	if(tab != nil) then
		local o = {}

		setmetatable(o,tab)
		tab.__index = tab
		
		o.ID = tostring(nxtID)
		
		if(parent != nil) then
			if(parent:GetContentPane() != nil and !force) then
				parent = parent:GetContentPane()
			end
			o.parent = parent
			o.ID = parent.ID .. o.parent.cc
			o.parent.cc = o.parent.cc + 1
		end
		
		local level = string.len(o.ID)
		if(level == 1) then
			nxtID = nxtID + 1
		end
		
		currentInit = name
		o:Initialize()
		currentInit = nil
		
		print("Create ID: " .. o.ID .. " -> " .. level .. "\n")
		
		table.insert(UI_Active,o)
		
		o:DoLayout()
		
		return o
	end
end

local function loadComponents()
	local list = findFileByType("lua","./lua/packs/advancedUI/components")
	toRegister = #list
	for k,v in pairs(list) do
		include(v)
	end
	parentComponents()
end
loadComponents()

local function panelCollide(p,x,y)
	local px,py = p:GetPos()
	local pw,ph = p:GetSize()
	if(x > px and x < px + pw and y > py and y < py + ph) then
		return true
	else
		return false
	end
end

local function mDown()
	local mx = GetMouseX()
	local my = GetMouseY()
	table.sort(UI_Active,function(a,b) return a.ID > b.ID end)
	for k,v in pairs(UI_Active) do
		if(v:IsVisible() and panelCollide(v,mx,my) and v.__wasPressed != true) then
			v:MousePressed(mx,my)
			v.__wasPressed = true
			return
		end
	end
end
hook.add("MouseDown","uimouse",mDown)

local function mUp()
	local mx = GetMouseX()
	local my = GetMouseY()
	for k,v in pairs(UI_Active) do
		if(v:IsVisible() and v.__wasPressed == true) then
			if(panelCollide(v,mx,my)) then
				v:MouseReleased(mx,my)
			else
				v:MouseReleasedOutside(mx,my)
			end
			v.__wasPressed = false
		end
	end
end
hook.add("MouseUp","uimouse",mUp)

local function checkMouse()
	local mx = GetMouseX()
	local my = GetMouseY()
	table.sort(UI_Active,function(a,b) return a.ID > b.ID end)
	for k,v in pairs(UI_Active) do
		v.__mouseInside = false
	end
	for k,v in pairs(UI_Active) do
		if(v:IsVisible() and panelCollide(v,mx,my)) then
			v.__mouseInside = true
			return
		end
	end
end

local function garbageCollect()
	if(#UI_Active > 0) then
		table.sort(UI_Active,function(a,b) return a.rmvx > b.rmvx end)
		if(UI_Active[1] == nil) then
			UI_Active = {}
			UI_ERROR("Invalid UI index, cleared table.\n")
		end
		
		while(UI_Active[1] != nil and UI_Active[1].rmvx == 1) do
			table.remove(UI_Active,1)
		end
	end
end

local function checkRemove(v)
	if(v.removeme) then
		for _,other in pairs(UI_Active) do
			if(other != v) then
				if(other:GetParent() == v and other.removeme != true) then
					other:Remove()
					didrmv = true
				end
			end
		end
	end
end

local function draw()
	checkMouse()
	table.sort(UI_Active,function(a,b) return a.ID < b.ID end)
	for k,v in pairs(UI_Active) do
		if(v:IsVisible() and v:ShouldDraw()) then
			v:MaskMe()
			v:Draw()
			v:EndMask()
		end
	end
	for k,v in pairs(UI_Active) do
		if(v:IsVisible() and v:ShouldDraw()) then
			if(v.parent and v.parent.valid != true) then
				v:DoLayout()
				v.parent.valid = true
			end
			v:Think()
			checkRemove(v)
		end
	end
	
	garbageCollect()
end
hook.add("Draw2D","uidraw",draw)