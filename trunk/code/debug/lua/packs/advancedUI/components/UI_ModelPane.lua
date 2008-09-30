local Panel = {}
Panel.model = nil
Panel.org = Vector(0,0,0)

function Panel:Initialize()
	self.ref = RefEntity()
	self.rot = 0
end

function Panel:SetModel(mdl)
	if(type(mdl) == "string") then
		self.model = LoadModel(mdl)
	elseif(type(mdl) == "number") then
		self.model = mdl
	end
	self.ref:SetModel(self.model)
end

function Panel:SetSkin(skin)
	self.skin = skin
end

function Panel:SetCamOrigin(org)
	self.org = org
end

function Panel:DoLayout()
	self:Expand()
end

function Panel:PositionModel(ref)
	ref:SetAngles(Vector(0,self.rot,0))
end

function Panel:DrawModel()
	self.ref:Render()
	self:PositionModel(self.ref)
	if(self.skin) then
		self.ref:SetSkin(self.skin)
	end
end

function Panel:DrawBackground()
	if(self.model != nil) then
		render.CreateScene()

		self:DrawModel()		

		local refdef = {}
		
		refdef.origin = self.org

		local aim = VectorNormalize(refdef.origin)
		aim = vMul(aim,-1)
		aim = VectorToAngles(aim)

		refdef.angles = aim

		refdef.x = self:GetX()
		refdef.y = self:GetY()
		refdef.width = self:GetWidth()
		refdef.height = self:GetHeight()
		render.RenderScene(refdef)

		self.rot = self.rot + 1
	end
end

registerComponent(Panel,"modelpane","panel")