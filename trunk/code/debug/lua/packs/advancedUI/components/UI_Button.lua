local Panel = {}

function Panel:Draw()
	self:DrawBackground()
end

registerComponent(Panel,"button","panel")