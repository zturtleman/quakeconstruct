local Panel = {}

local function coloradjust(tab,amt)
	local out = {}
	for k,v in pairs(tab) do
		out[k] = math.min(math.max(v * (1 + amt),0),1)
	end
	return out
end

function Panel:DoClick() end

function Panel:DrawBackground()
	local nbg = {self.bgcolor[1],self.bgcolor[2],self.bgcolor[3],self.bgcolor[4]}
	
	if(self:MouseOver()) then
		self.bgcolor = coloradjust(nbg,.2)
	end
	if(self:MouseDown()) then
		self.bgcolor = coloradjust(nbg,-.2)
	end
	
	UI_Components["panel"].DrawBackground(self)
	
	self.bgcolor[1] = nbg[1]
	self.bgcolor[2] = nbg[2]
	self.bgcolor[3] = nbg[3]
	self.bgcolor[4] = nbg[4]
end

function Panel:MouseReleased()
	self:DoClick()
end

registerComponent(Panel,"button","label")