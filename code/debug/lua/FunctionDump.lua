
// Outputs functions and stuff in wiki format

local clHooks = {
"ShouldDraw",
"Draw2D",
"Draw3D",
"ItemPickup",
"EventReceived",
"EntityLinked",
"Loaded",
"KeyEvent",
"MouseEvent",
"ClientInfoLoaded",
"ClientInfoChanged",
"MessageReceived",
"SoundLoaded",
"ModelLoaded",
"ShaderLoaded",
}

local svHooks = {
"PlayerJoined",
"PlayerSpawned",
"PlayerDisconnected",
"PlayerKilled",
"PlayerDamaged",
"MessageReceived",
"ShouldDropItem",
"EntityLinked",
"EntityUnlinked",
"Think",
"ClientThink",
"FiredWeapon",
}

OUTPUT = ""

xside = xside or ""

local function XSide( class, name )
	if ( string.find( xside, class .. "." .. name ) ) then return "[[SHARED|SHD]]" end
	if ( string.find( xside, class .. ":" .. name ) ) then return "[[SHARED|SHD]]" end
	
	if ( SERVER ) then return "[[SERVER|SRV]]" end
	
	return "[[CLIENT|CLI]]"
	
end


local function GetFunctions( tab )

	local functions = {}

	for k, v in pairs( tab ) do

		if ( type(v) == "function" ) then
		
			table.insert( functions, tostring(k) )
		
		end
	
	end
	
	table.sort( functions )
	return functions

end


local function DoMetaTable( name )
	
	OUTPUT = OUTPUT .. "\n\r==[["..name.."]] ([[Object]])==\n\r"
	func = GetFunctions( _R[ name ] )
	
	if ( type(_R[ name ]) != "table" ) then
		--Msg("Error: _R["..name.."] is not a table!\n")
	end
	
	for k, v in pairs( func ) do
		OUTPUT = OUTPUT .. XSide( name, v ) .. " [["..name.."]]:[["..name.."."..v.."|"..v.."]]<br />\n"
	end
	
end

local function DoLibrary( name )
	
	OUTPUT = OUTPUT .. "\n\r==[["..name.."]] ([[Library]])==\n\r"
	
	if ( type(_G[ name ]) != "table" ) then
		--Msg("Error: _G["..name.."] is not a table!\n")
	end
	
	func = GetFunctions( _G[ name ] )
	for k, v in pairs( func ) do
		OUTPUT = OUTPUT .. XSide( name, v ) .. " [["..name.."]]:[["..name.."."..v.."|"..v.."]]<br />\n"
	end
	
end

local function DoHooks( tab )
	for k, v in pairs( tab ) do
		OUTPUT = OUTPUT .. XSide( "", v ) .. " [["..v.."]]<br />\n"
	end
end

local t ={}

for k, v in pairs(_G) do
	if ( type(v) == "table" ) then
		table.insert( t, tostring(k) )
	end
end

if(CLIENT) then
	--[[for k, v in pairs(UI_Components) do
		if ( type(v) == "table" ) then
			table.insert( t, tostring(k) )
		end
	end]]
	for k,v in pairs(UI_Components) do
		OUTPUT = OUTPUT .. "\n\r==[["..k.."]] ([[Object]])==\n\r"
		if(!v.BaseClass) then
			print(k .. "\n")
			func = GetFunctions( v )
			for x, y in pairs( func ) do
				OUTPUT = OUTPUT .. XSide( k, y ) .. " [["..k.."]]:[["..k..":"..y.."|"..y.."]]<br />\n"
			end
		else
			print(k .. "\n")
			func = GetFunctions( v )
			for x, y in pairs( func ) do
				if(table.HasKey(v.BaseClass,y) == false) then
					OUTPUT = OUTPUT .. XSide( k, y ) .. " [["..k.."]]:[["..k..":"..y.."|"..y.."]]<br />\n"
				end
			end	
		end
	end
end

table.sort( t )
for k, v in pairs( t ) do
    --Msg("Library: "..v.."\n")
	DoLibrary( v )
end

local function writef(f,data)
	local file = io.open(f,"w")
	if(file != nil) then
		file:write(data)
		file:close()
	end
end

if ( SERVER ) then
	table.sort( svHooks )
	DoHooks(svHooks)
	writef( "lua/ServerFunctions.txt", OUTPUT )
else
	table.sort( clHooks )
	DoHooks(clHooks)
	writef( "lua/ClientFunctions.txt", OUTPUT )
end

