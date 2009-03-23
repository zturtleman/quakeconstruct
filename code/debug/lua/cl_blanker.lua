--local shader = LoadShader("flareShader")
local mx,my = 0,0
local lmx,lmy = 0,0
local lx,ly = 0,0
local cx,cy = 0,0
local function drawStuff()
	if(MouseDown()) then
		draw.SetColor(1,1,1,1)
		draw.Line(cx,cy,lx,ly,nil,2)
	end
	--ly = ly + (my - ly)*.1
	--lx = lx + (mx - lx)*.1
	lx,ly = cx,cy
	cx = cx + (mx - cx)*.1
	cy = cy + (my - cy)*.1
end

local function moused(x,y)
	mx = mx + x
	my = my + y
	
	if(mx > 640) then mx = 640 end
	if(mx < 0) then mx = 0 end
	
	if(my > 480) then my = 480 end
	if(my < 0) then my = 0 end
end
hook.add("MouseEvent","cl_blanker",moused)

local wmodel = LoadModel("*0")
local clx = 0
local function d3d()
	draw.SetColor(0,0,0,1)
	
	if(KeyIsDown(K_SPACE)) then
		draw.Rect(0,0,640,480)
	end
	
	draw.Rect(lmx-1,lmy-1,2,2)
	
	draw.SetColor(1,1,1,1)
	draw.Rect(mx-1,my-1,2,2)
	
	lmx,lmy = mx,my
	
	drawStuff()
	
	local ref = RefEntity()
	ref:SetModel(wmodel)
	ref:SetShader(0)
	ref:Scale(Vector(1,1,1))
	--ref:Render()
	
	for k,v in pairs(GetEntitiesByClass("item")) do v:CustomDraw(true) end
end
hook.add("Draw3D","cl_blanker",d3d)

local function UserCmd(pl,angle,fm,rm,um,buttons,weapon)
	SetUserCommand(Vector(),0,0,0,0,0)
end
hook.add("UserCommand","cl_blanker",UserCmd)

local function noNuthin(str)
	--if(str == "WORLD") then return false end
	return false
end
hook.add("ShouldDraw","cl_blanker",noNuthin);