ENT.Base = "lua_gpanel"

render.SetupRenderTarget(4,512,512)

local data = 
[[{
	{
		map $rendertarget 4
		alphaGen vertex
		rgbGen vertex
		tcMod transform 1 0 0 -1 0 0
	}
}]]
ENT.renderTarget = CreateShader("f",data)

function ENT:DrawForeground()
	local camera = self.net.camtarget or 0
	local cameraEnt = GetEntityByIndex(camera)
	if(cameraEnt == nil) then return end
	
	draw.SetColor(1,1,1,1)
	draw.Text(30,30,"RTCam: " .. camera .. " | " .. cameraEnt:Classname(),30,30)
	--draw.Text(30,60,"Position: " .. tostring(cameraEnt:GetPos()),20,30)
	
	draw.SetColor(1,1,1,1)
	draw.Rect(60,80,640-120,480-120,self.renderTarget)
	
	--print("RTCamera: " .. camera .. "\n")
end

function ENT:DrawRT()
	local camera = self.net.camtarget or 0
	local cameraEnt = GetEntityByIndex(camera)
	if(cameraEnt == nil or camera == 0) then 
		print("^1 NULL CAMERA!\n")
		return
	end

	render.CreateScene()
	
	_RT_ORIGIN = cameraEnt:GetPos()
	
	render.AddPacketEntities()
	render.AddLocalEntities()
	render.AddMarks()

	--[[reftest:SetPos(org + u/2)
	reftest:Render()
	reftest:SetPos(org - u/2)
	reftest:Render()
	reftest:SetPos(org + r/2)
	reftest:Render()
	reftest:SetPos(org - r/2)
	reftest:Render()]]
	
	
	local refdef = {}
	refdef.x = 0
	refdef.y = 0
	refdef.fov_x = 90
	refdef.fov_y = 90
	refdef.width = 640
	refdef.height = 480
	refdef.origin = cameraEnt:GetPos()
	refdef.angles = cameraEnt:GetAngles()
	refdef.flags = 0
	refdef.renderTarget = 4
	refdef.isRenderTarget = true
	render.RenderScene(refdef)
	
	_RT_ORIGIN = nil
end