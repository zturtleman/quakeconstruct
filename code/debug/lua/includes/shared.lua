local function includex(s) 
	include("lua/includes/" .. s .. ".lua")
end

includex("tools")
includex("extensions/init")
includex("file")
includex("hooks")
includex("entities")
includex("timer")
includex("enum")
includex("vector")
includex("scriptmanager")
if(CLIENT) then includex("sound") end
if(CLIENT) then includex("shader") end
includex("commands")
--require "includes/functiondump"

ENTITYNUM_NONE = 1023
ENTITYNUM_WORLD	= 1022
ENTITYNUM_MAX_NORMAL = 1022

CONTENTS_SOLID = 1
CONTENTS_LAVA = 8
CONTENTS_SLIME = 16
CONTENTS_WATER = 32
CONTENTS_FOG = 64