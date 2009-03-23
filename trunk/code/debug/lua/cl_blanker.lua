--local shader = LoadShader("flareShader")
local wmodel = LoadModel("*0")
local function d3d()
	draw.SetColor(0,0,0,1)
	draw.Rect(0,0,640,480)
	
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

local function noWorld(str)
	if(str == "WORLD") then return true end
	return false
end
hook.add("ShouldDraw","cl_blanker",noWorld);