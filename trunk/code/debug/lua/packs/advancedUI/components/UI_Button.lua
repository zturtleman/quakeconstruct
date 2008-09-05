local Panel = {}

function Panel:DoClick() end

function Panel:DrawBackground()
	local b = self.bgcolor
	local x,y = self:GetPos()
	draw.SetColor(b[1],b[2],b[3],b[4])
	
	if(self:MouseOver()) then
		draw.SetColor(.1,.3,1,1)
	end
	if(self:MouseDown()) then
		draw.SetColor(1,.3,.1,1)
	end
	draw.Rect(x,y,self.w,self.h)
end

function Panel:MouseReleased()
	self:DoClick()
end

registerComponent(Panel,"button","label")