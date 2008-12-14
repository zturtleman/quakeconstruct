#include "g_local.h"

qboolean LuaTeamChanged(gentity_t *luaentity,int team) {
	lua_State *L = GetServerLuaState();
	if(L == NULL) return qtrue;

	qlua_gethook(L, "PlayerTeamChanged");
	lua_pushentity(L,luaentity);
	lua_pushinteger(L,team);
	qlua_pcall(L,2,1,qtrue);
	if(lua_type(L,-1) == LUA_TBOOLEAN)
		return lua_toboolean(L,-1);

	return qtrue;
}

static const luaL_reg Team_methods[] = {
  {0,0}
};

void G_InitLuaTeam(lua_State *L) {
	luaL_openlib(L, "team", Team_methods, 0);
}