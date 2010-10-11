#include "g_local.h"

int luautil_pointcontents(lua_State *L) {
	vec3_t point;
	int pass = -1;
	int contents;

	//luaL_checkudata(L,1,"Vector");
	if(lua_type(L,1) != LUA_TUSERDATA) return 0;

	lua_tovector(L,1,point);

	if(lua_type(L,2) == LUA_TNUMBER) {
		pass = lua_tonumber(L,2);
	}
	contents = trap_PointContents(point,pass);

	lua_pushinteger(L,contents);
	return 1;
}

int luautil_getviewheight(lua_State *L) {
	gentity_t *ent = lua_toentity(L,1);
	
	if(ent == NULL || ent->client == NULL) return 0;
	lua_pushinteger(L,ent->client->ps.viewheight);
	return 1;
}

static const luaL_reg Util_methods[] = {
  {"GetPointContents",	luautil_pointcontents},
  {"GetViewHeight",		luautil_getviewheight},
  {0,0}
};

void G_InitLuaUtil(lua_State *L) {
	luaL_openlib(L, "util", Util_methods, 0);
}