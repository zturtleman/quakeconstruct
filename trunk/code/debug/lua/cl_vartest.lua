function d2d()
	local c = 0
	for k,v in pairs(_N) do
		local txt = "Var: " .. k .. " = " .. v
		draw.SetColor(1,1,1,1)
		draw.Text(0,300 + (c*10),txt,10,10)
		c = c + 1
	end
end
hook.add("Draw2D","cl_vartest",d2d)