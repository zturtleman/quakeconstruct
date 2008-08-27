--SendScript("lua/cl_debugbar.lua")
--SendScript("lua/cl_marks.lua")
--includesimple("sctest")

--SendScript("lua/vampiric_cl.lua")
--SendScript("lua/includes/scriptmanager.lua")

local encoded = base64.enc("This is a test of the base64 encoder and decoder respectively.")
print(encoded .. "\n")

local decoded = base64.dec(encoded)
print(decoded .. "\n")