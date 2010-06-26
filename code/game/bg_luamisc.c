#include "q_shared.h"
#include "bg_public.h"

char *toChars(const char *str) {
	return (char *)str;
}

int additem(lua_State *L) {
	int id;
	gitem_t item;

	//memset(&item,0,sizeof(item));

	luaL_checktype(L,1,LUA_TNUMBER);
	luaL_checktype(L,2,LUA_TSTRING);

	id = lua_tointeger(L,1);

	item.classname = toChars(lua_tostring(L,2));
	item.giType = luaL_optinteger(L,3,IT_BAD);
	item.giTag = luaL_optinteger(L,4,WP_NONE);
	item.icon = toChars(luaL_optstring(L,5,"icons/iconw_grapple"));
	item.pickup_name =  toChars(luaL_optstring(L,6,"Unknown Item"));
	item.pickup_sound = toChars(luaL_optstring(L,7,"sound/misc/w_pkup.wav"));
	item.quantity = luaL_optinteger(L,8,0);

	item.world_model[0] = toChars(luaL_optstring(L,9,"models/powerups/health/medium_cross.md3"));
	item.world_model[1] = toChars(luaL_optstring(L,10,""));
	item.world_model[2] = toChars(luaL_optstring(L,11,""));
	item.world_model[3] = toChars(luaL_optstring(L,12,""));

	item.precaches = "";
	item.sounds = "";

	BG_AddItem(&item, id);
	return 0;
}

int qlua_finditem(lua_State *L) {
	const char *str = "";
	luaL_checkstring(L,1);

	str = lua_tostring(L,1);

	lua_pushinteger(L,BG_FindItemIndexByClass(str));
	return 1;
}

void BG_InitLuaMisc(lua_State *L) {
	lua_register(L,"AddItem",additem);
	lua_register(L,"FindItemByClassname",qlua_finditem);
}