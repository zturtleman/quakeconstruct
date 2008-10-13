#include "cg_local.h"

void qlua_HandleMessage() {
	qlua_gethook(GetClientLuaState(),"HandleMessage");
	qlua_pcall(GetClientLuaState(),0,0,qtrue);
}

int qlua_readshort(lua_State *L) {
	lua_pushinteger(L,trap_N_ReadShort());
	return 1;
}

int qlua_readlong(lua_State *L) {
	lua_pushinteger(L,trap_N_ReadLong());
	return 1;
}

int qlua_readstring(lua_State *L) {
	char *str = trap_N_ReadString();
	lua_pushstring(L,str);
	free(str);
	return 1;
}

int qlua_readfloat(lua_State *L) {
	lua_pushnumber(L,trap_N_ReadFloat());
	return 1;
}

static const luaL_reg Message_methods[] = {
  {"ReadShort",		qlua_readshort},
  {"ReadLong",		qlua_readlong},
  {"ReadString",	qlua_readstring},
  {"ReadFloat",		qlua_readfloat},
  {0,0}
};

void CG_InitLuaMessages(lua_State *L) {
	luaL_openlib(L, "message", Message_methods, 0);
}