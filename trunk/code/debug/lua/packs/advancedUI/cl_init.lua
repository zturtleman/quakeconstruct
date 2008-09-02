UI_Components = {}
UI_Active = {}
local toRegister = 0

P:include("cursor.lua")

function parentComponents()
	for k,v in pairs(UI_Components) do
		local base = v._mybase
		local name = v._myname
		if(base != nil and type(base) == "string" and UI_Components[base] and base != name) then
			v = table.Inherit( v, UI_Components[base] )
			print("Parented: " .. name .. " -> " .. base .. "\n")
		end
	end
end

function registerComponent(tab,name,base)
	if(UI_Components[name] == nil) then
		UI_Components[name] = tab
		tab._mybase = base
		tab._myname = name
	end
	print("Registered " .. name .. "\n")
end

function UI_Create(name)
	local tab = UI_Components[name]
	if(tab != nil) then
		local o = {}

		setmetatable(o,tab)
		tab.__index = tab
		
		table.insert(UI_Active,o)
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

local function draw()
	for k,v in pairs(UI_Active) do
		v:Draw()
		v:Think()
	end
	for k,v in pairs(table.Copy(UI_Active)) do
		if(v.removeme) then
			for _,other in pairs(UI_Active) do
				if(other:GetParent() == v) then other:Remove() end
				other:__removeChild(v)
			end
			table.remove(UI_Active,k)
		end
	end
end
hook.add("Draw2D","uidraw",draw)