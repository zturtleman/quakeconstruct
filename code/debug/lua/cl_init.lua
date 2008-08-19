--require("cl_marks")
--require("cl_cgtab")
--self.VAriblae

local function md5test(p,c,a)
	if(a[1] != nil and type(a[1]) == "string") then
	k = MD5(a[1])
	print(hexFormat(k) .. "\n")
	end
end
concommand.Add("md5test",md5test)

local md5sum = fileMD5("lua/cl_small.lua")
md5sum = hexFormat(md5sum)
print(md5sum .. "\n")

md5sum = fileMD5("lua/downloads/cl_small.lua")
md5sum = hexFormat(md5sum)
print(md5sum .. "\n")