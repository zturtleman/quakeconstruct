local function cc()
	SendScript("lua/vampiric_cl.lua")
	--SendScript("lua/cl_small.lua")
end
concommand.Add("ss",cc)