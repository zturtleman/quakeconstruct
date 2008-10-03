--require("cl_marks")
--require("cl_cgtab")
--self.VAriblae
include("lua/cl_menu2.lua")
include("lua/cl_testmenu2.lua")

function HandleMessage()
	local long = message.ReadLong()
	local str = message.ReadString()
	print("Got Long: " .. long .. "\n")
	print("Got String: " .. str .. "\n")
end
hook.add("HandleMessage","cl_init",HandleMessage)