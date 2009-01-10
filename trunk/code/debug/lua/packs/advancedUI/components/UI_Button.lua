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
	SkinCall("DrawButtonBackground",self:MouseOver(),self:MouseDown())
end

function Panel:MouseReleased()
	self:DoClick()
end

registerComponent(Panel,"button","label")