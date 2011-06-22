function WEAPON:Register()
	self.gun = LoadModel("models/weapons2/deagle/deagle.md3")
	self.ref = RefEntity()
	self.ref:SetModel(self.gun)
	self.fire = LoadSound("sound/weapons/deagle/fire.wav")
	self.deploy = LoadSound("sound/weapons/deagle/deploy.wav")
	self.flash = LoadModel("models/weapons2/deagle/deagle_flash.md3")
	self.flashRef = RefEntity()
	self.flashRef:SetModel(self.flash)
	self.registered = true
end

function WEAPON:CheckPL(pl)
	local id = pl:EntIndex()
	self.players[id] = self.players[id] or {}
	return self.players[id]
end

function WEAPON:Init()
	self.flashTime = 0
	self.players = {}
end

function WEAPON:Draw(parent,player,team,renderfx)
	if not (self.registered) then return end
	self.ref:SetRenderFx(parent:GetRenderFx())
	self.ref:SetAngles(Vector(0,0,0))
	self.ref:PositionOnTag(parent,"tag_weapon")
	self.ref:SetLightingOrigin(parent:GetPos())
	self.ref:Render()
	
	local pl = self:CheckPL(player)
	local flash = pl.flashTime or 0
	
	if(flash > LevelTime()) then
		self.flashRef:SetAngles(Vector(0,0,0))
		self.flashRef:PositionOnTag(self.ref,"tag_flash")
		self.flashRef:SetRenderFx(parent:GetRenderFx())
		self.flashRef:Render()
	end
end

function WEAPON:Fire(player,muzzle,angles)
	if not (self.registered) then return end
	PlaySound(player, self.fire)
	local pl = self:CheckPL(player)
	pl.flashTime = LevelTime() + 50
end