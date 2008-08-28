for k,v in pairs(_G) do
	print(k .. "\n")
end

local function includex(s)
	include("lua/includes/" .. s .. ".lua")
end

includex("tools")
includex("extensions/init")
includex("base64")
includex("file")
includex("hooks")
includex("entities")
includex("timer")
includex("enum")
includex("vector")
includex("scriptmanager")
if(CLIENT) then includex("sound") end
if(CLIENT) then includex("shader") end
if(CLIENT) then includex("model") end
if(CLIENT) then includex("input") end
includex("commands")
includex("packs")
--require "includes/functiondump"

ENTITYNUM_NONE = 1023
ENTITYNUM_WORLD	= 1022
ENTITYNUM_MAX_NORMAL = 1022

CONTENTS_SOLID = 1
CONTENTS_LAVA = 8
CONTENTS_SLIME = 16
CONTENTS_WATER = 32
CONTENTS_FOG = 64