require "includes/extensions/init"
require "includes/file"
require "includes/hooks"
require "includes/tools"
require "includes/entities"
require "includes/timer"
require "includes/enum"
require "includes/commands"
require "includes/vector"
--require "includes/functiondump"

print("^5use /load to load a script.\n")

ENTITYNUM_NONE = 1023
ENTITYNUM_WORLD	= 1022
ENTITYNUM_MAX_NORMAL = 1022

CONTENTS_SOLID = 1
CONTENTS_LAVA = 8
CONTENTS_SLIME = 16
CONTENTS_WATER = 32
CONTENTS_FOG = 64