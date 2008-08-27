#include "cg_local.h"

int qlua_getitemicon(lua_State *L) {
	int icon = 0;
	int size = sizeof(cg_items) / sizeof(cg_items[0]);
	luaL_checktype(L,1,LUA_TNUMBER);

	icon = lua_tointeger(L,1);

	if(icon <= 0 || icon > size) {
		lua_pushstring(L,"Item Index Out Of Bounds\n");
		lua_error(L);
		return 1;
	}
	CG_RegisterItemVisuals( icon );
	lua_pushinteger(L,cg_items[icon].icon);
	return 1;
}

int qlua_getitemname(lua_State *L) {
	int icon = 0;
	int size = sizeof(cg_items) / sizeof(cg_items[0]);
	luaL_checktype(L,1,LUA_TNUMBER);

	icon = lua_tointeger(L,1);

	if(icon <= 0 || icon > size) {
		lua_pushstring(L,"Item Index Out Of Bounds\n");
		lua_error(L);
		return 1;
	}
	if(bg_itemlist[icon].pickup_name != NULL) {
		lua_pushstring(L,bg_itemlist[icon].pickup_name);
	}
	return 1;
}

int qlua_getweaponicon(lua_State *L) {
	int icon = 0;
	int size = WP_NUM_WEAPONS;
	qboolean ammo = qfalse;

	luaL_checktype(L,1,LUA_TNUMBER);

	icon = lua_tointeger(L,1);

	if(icon < 0 || icon >= size) {
		lua_pushstring(L,"Weapon Index Out Of Bounds\n");
		lua_error(L);
		return 1;
	}

	if(lua_type(L,2) == LUA_TBOOLEAN && lua_toboolean(L,2) == qtrue) {
		lua_pushinteger(L,cg_weapons[ icon ].ammoIcon);
	} else {
		lua_pushinteger(L,cg_weapons[ icon ].weaponIcon);
	}
	return 1;
}

int qlua_getweaponname(lua_State *L) {
	int icon = 0;
	int size = WP_NUM_WEAPONS;
	gitem_t *item;

	luaL_checktype(L,1,LUA_TNUMBER);

	icon = lua_tointeger(L,1);

	if(icon < 0 || icon >= size) {
		lua_pushstring(L,"Weapon Index Out Of Bounds\n");
		lua_error(L);
		return 1;
	}
	item = cg_weapons[ icon ].item;

	if(item != NULL) {
		lua_pushstring(L,item->pickup_name);
	} else {
		lua_pushstring(L,"");
	}
	return 1;
}

int qlua_lockmouse (lua_State *L) {
	luaL_checktype(L,LUA_TBOOLEAN,1);
	trap_LockMouse(lua_toboolean(L,1));
	return 0;
}

static const luaL_reg Util_methods[] = {
  {"GetItemIcon",	qlua_getitemicon},
  {"GetItemName",	qlua_getitemname},
  {"GetWeaponIcon",	qlua_getweaponicon},
  {"GetWeaponName",	qlua_getweaponname},
  {"LockMouse",		qlua_lockmouse},
  {0,0}
};

void CG_InitLuaUtil(lua_State *L) {
	luaL_openlib(L, "util", Util_methods, 0);
}