local lerp = 0

--local panel = UI_Create("frame")
 
--[[if(panel != nil) then
	panel.name = "base"
	panel:SetPos(0,400)
	panel:SetSize(640,80)
	panel:SetTitle("Lerp Test")
	panel:CatchMouse(true)
	panel:SetVisible(true)
	panel.OnRemove = function(self)
		hook.remove("Draw3D","cl_lerptest")
	end
	
	local list = UI_Create("listpane",panel)
	
	local slide = UI_Create("slider")
	slide:SetTitle("Model Lerp")
	slide.OnValue = function(s,v)
		lerp = v
	end
	list:AddPanel(slide,true)
end]]

local lp = Vector(652,1872,28)
local frames = 34
local seq = Sequence(35,28)
seq = Sequence(0,34)
--seq = Sequence(64,30)
local legs,torso,head = LoadCharacter("sorlag","armored")
PlaySound(lp,LoadSound("sound/player/sorlag/death1.wav"))
local start = LevelTime()
local delay = (1000*seq:GetLength())/20 --1 Second * Number Of Frames / Frames Per Second
local endt = LevelTime() + delay 

local function d3d()
	local tw = (endt - LevelTime()) / delay
	lerp = 1-tw
	
	if(lerp > 1) then lerp = 1 end
	seq:SetRef(legs)
	seq:SetLerp(lerp)
	seq:SetRef(torso)
	seq:SetLerp(lerp)

	legs:SetPos(lp)
	legs:Render()
	
	torso:SetAngles(Vector())
	torso:PositionOnTag(legs,"tag_torso")
	torso:Render()
	
	head:SetAngles(Vector())
	head:PositionOnTag(torso,"tag_head")
	head:Render()
end
hook.add("Draw3D","cl_lerptest",d3d)