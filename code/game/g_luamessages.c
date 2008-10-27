#include "g_local.h"

void qlua_pushmessage(lua_State *L, msg_t *msg, int clientnum) {
	luamsg_t *out;
	//lua_pushlightuserdata(L,msg);
	out = (luamsg_t*)lua_newuserdata(L, sizeof(luamsg_t));
	out->msg = (msg_t*) malloc(sizeof(msg_t));
	memcpy(out->msg,msg,sizeof(msg_t));
	out->clientnum = clientnum;
}

luamsg_t *qlua_tomessage(lua_State *L, int idx) {
	luaL_checktype(L,1,LUA_TUSERDATA);
	return (luamsg_t*)lua_touserdata(L,1);
}
/*
int SendTest(lua_State *L) {
	msg_t msg;

	luaL_checkint(L,1);

	trap_N_CreateMessage(&msg, 0);
	trap_N_WriteLong(&msg,lua_tointeger(L,1));
	trap_N_SendMessage(&msg, 0);
	
	return 0;
}
*/

int qlua_createmessage(lua_State *L) {
	msg_t msg;
	gentity_t *ent;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	ent = lua_toentity(L,1);

	trap_N_CreateMessage(&msg, ent->s.clientNum);
	trap_N_WriteLong(&msg,lua_tointeger(L,2));

	qlua_pushmessage(L,&msg, ent->s.clientNum);

	return 1;
}

int qlua_sendmessage(lua_State *L) {
	luamsg_t *msg;

	luaL_checktype(L,1,LUA_TUSERDATA);

	msg = qlua_tomessage(L,1);

	if(msg->msg != NULL) {
		trap_N_SendMessage(msg->msg,msg->clientnum);
	} else {
		G_Printf("Error Error ERRRROOOOORRRR!\n");
	}
	return 0;
}

int qlua_writeshort(lua_State *L) {
	trap_N_WriteShort(qlua_tomessage(L,1)->msg,lua_tointeger(L,2));
	return 0;
}

int qlua_writelong(lua_State *L) {
	trap_N_WriteLong(qlua_tomessage(L,1)->msg,lua_tointeger(L,2));
	return 0;
}

int qlua_writestring(lua_State *L) {
	trap_N_WriteString(qlua_tomessage(L,1)->msg,lua_tostring(L,2));
	return 0;
}

int qlua_writefloat(lua_State *L) {
	trap_N_WriteFloat(qlua_tomessage(L,1)->msg,lua_tonumber(L,2));
	return 0;
}

static const luaL_reg Message_methods[] = {
  {"WriteShort",		qlua_writeshort},
  {"WriteLong",			qlua_writelong},
  {"WriteString",		qlua_writestring},
  {"WriteFloat",		qlua_writefloat},
  {0,0}
};

void G_InitLuaMessages(lua_State *L) {
	lua_register(L,"_Message",qlua_createmessage);
	lua_register(L,"_SendDataMessage",qlua_sendmessage);
	luaL_openlib(L, "_message", Message_methods, 0);
}