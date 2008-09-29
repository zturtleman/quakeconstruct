UI_Components = {}
UI_Active = {}
local toRegister = 0
local nxtID = 0
local white = LoadShader("white")

P:include("cursor.lua")

local letters = string.alphabet

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

local function getNewId()
	local incr = 0
	for i=0, (#letters*2) + 10 do
		local f = false
		for k,v in pairs(UI_Active) do
			if(string.len(v.ID) == 1) then
				if(v.rlID == incr) then 
					f = true
					break 
				end
			end
		end
		if(f == false) then
			return incr
		else
			incr = incr + 1
		end
	end
end

local function correctId(id)
	if(id >= 10) then
		local i = id - 9
		if(i > #letters) then
			i = i - #letters
			if(i > #letters) then
				i=1
				id = 0
			end			
			return string.upper(letters[i])
		else
			return letters[i]
		end
	end
	return id
end

local function doPanel(o,parent,force)
	local id = getNewId()
	o.rlID = id
	o.ID = tostring(correctId(id))
	
	o.isPanel = true
	
	if(parent != nil) then
		local rparent = parent
		if(parent:GetContentPane() != nil and !force) then
			parent = parent:GetContentPane()
		end
		o.parent = parent
		o.ID = parent.ID .. correctId(o.parent.cc)
		o.parent.cc = o.parent.cc + 1
		rparent:OnChildAdded(o)
	end
	
	local level = string.len(o.ID)
	if(level == 1) then
		nxtID = nxtID + 1
	end
	
	currentInit = name
	o:Initialize()
	currentInit = nil
	
	print("Create ID: " .. o.ID .. " -> " .. level .. "\n")
end

function PaintSort()
	table.sort(UI_Active,function(a,b) return a.ID < b.ID end)
end

function UI_Create(name,parent,force)
	if(type(name) == "table" and name.isPanel) then
		local n = table.Copy(name)
		
		doPanel(n,parent,force)
		
		table.insert(UI_Active,n)
		
		n:DoLayout()
		
		PaintSort()
		
		return n
	end
	if(currentInit == name) then
		UI_ERROR("A " .. name .. " attempted to create itself in it's 'Initialize' function.")
		return nil
	end
	local tab = UI_Components[name]
	if(tab != nil) then
		local o = {}

		setmetatable(o,tab)
		tab.__index = tab
		
		o.type = name
		doPanel(o,parent,force)
		
		table.insert(UI_Active,o)
		
		o:DoLayout()
		
		PaintSort()
		
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
	local px,py,pw,ph = p:GetMaskedRect()
	if(x > px and x < px + pw and y > py and y < py + ph) then
		return true
	else
		return false
	end
end

local function mDown()
	local mx = GetMouseX()
	local my = GetMouseY()
	for i=0, #UI_Active-1 do
		local v = UI_Active[#UI_Active - i]
		if(v:IsVisible() and panelCollide(v,mx,my) and v.__wasPressed != true) then
			v:MousePressed(mx,my)
			v.__wasPressed = true
			return
		end
	end
	PaintSort()
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
	--table.sort(UI_Active,function(a,b) return a.ID > b.ID end)
	for i=0, #UI_Active-1 do
		local v = UI_Active[#UI_Active - i]
		v.__mouseInside = false
	end
	for i=0, #UI_Active-1 do
		local v = UI_Active[#UI_Active - i]
		if(v:IsVisible() and panelCollide(v,mx,my)) then
			v.__mouseInside = true
			PaintSort()
			return
		end
	end
	--PaintSort()
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
		PaintSort()
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

local thinktime = 0
local drawtime = 0
local sorttime = 0
local collect = false

local function drawx()
	checkMouse()

	t = ticks()
	for k,v in pairs(UI_Active) do
		if(v:IsVisible() and v:ShouldDraw()) then
			v:MaskMe()
			v:Draw()
			v:EndMask()
		end
	end
	t = (ticks()) - t
	drawtime = t
	
	t = ticks()
	for k,v in pairs(UI_Active) do
		if(v:IsVisible() and v:ShouldDraw()) then
			if(v.parent and v.parent.valid != true) then
				v:DoLayout()
				v.parent.valid = true
				v.parent:Think()
			end
			v:Think()
			checkRemove(v)
		end
		if(v.rmvx) then collect = true end
	end
	t = (ticks()) - t
	thinktime = t
	
	if(collect) then
		garbageCollect()
	end
end

local function profd()
	local dtime = ProfileFunction(drawx)
	draw.SetColor(1,1,1,1)
	draw.Text(0,300,"TotalTime: " .. dtime,12,12)
	draw.Text(0,312,"ThinkTime: " .. thinktime,12,12)
	draw.Text(0,324,"DrawTime: " .. drawtime,12,12)
	draw.Text(0,336,"SortTime: " .. sorttime,12,12)
end
hook.add("Draw2D","uidraw",profd)