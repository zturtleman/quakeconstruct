#include "q_shared.h"
#include "bg_public.h"

char *toChars(const char *str) {
	return (char *)str;
}

int additem(lua_State *L) {
	gitem_t item;

	memset(&item,0,sizeof(item));

	item.classname = toChars(luaL_optstring(L,1,"nil"));
	item.giType = luaL_optinteger(L,2,IT_BAD);
	item.giTag = luaL_optinteger(L,3,WP_NONE);
	item.icon = toChars(luaL_optstring(L,4,"icons/iconw_grapple"));
	item.pickup_name =  toChars(luaL_optstring(L,5,"Unknown Item"));
	item.pickup_sound = toChars(luaL_optstring(L,6,"sound/misc/w_pkup.wav"));
	item.quantity = luaL_optinteger(L,7,0);

	item.world_model[0] = toChars(luaL_optstring(L,8,"models/powerups/health/medium_cross.md3"));
	item.world_model[1] = toChars(luaL_optstring(L,9,""));
	item.world_model[2] = toChars(luaL_optstring(L,10,""));
	item.world_model[3] = toChars(luaL_optstring(L,11,""));

	item.precaches = "";
	item.sounds = "";

	BG_AddItem(&item);
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
	//lua_register(L,"AddItem",additem);
	lua_register(L,"FindItemByClassname",qlua_finditem);
}