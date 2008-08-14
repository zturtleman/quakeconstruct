#include "cg_local.h"

int qlua_setcolor(lua_State *L) {
	vec4_t	color;
	
	VectorClear(color);

	if(lua_type(L,1) == LUA_TNUMBER) {
		color[0] = lua_tonumber(L,1);
		if(lua_type(L,2) == LUA_TNUMBER) {
			color[1] = lua_tonumber(L,2);
			if(lua_type(L,3) == LUA_TNUMBER) {
				color[2] = lua_tonumber(L,3);
				if(lua_type(L,4) == LUA_TNUMBER) {
					color[3] = lua_tonumber(L,4);
				}
			}
		}
	}
	trap_R_SetColor(color);
	return 0;
}

int qlua_rect(lua_State *L) {
	int x,y,w,h;
	qhandle_t shader;

	luaL_checktype(L,1,LUA_TNUMBER);
	luaL_checktype(L,2,LUA_TNUMBER);
	luaL_checktype(L,3,LUA_TNUMBER);
	luaL_checktype(L,4,LUA_TNUMBER);
	luaL_checktype(L,5,LUA_TNUMBER);

	x = lua_tointeger(L,1);
	y = lua_tointeger(L,2);
	w = lua_tointeger(L,3);
	h = lua_tointeger(L,4);
	shader = lua_tointeger(L,5);

	CG_DrawPic( x, y, w, h, shader );
	return 0;
}

static const luaL_reg Draw_methods[] = {
  {"SetColor",		qlua_setcolor},
  {"Rect",			qlua_rect},
  {0,0}
};

int qlua_loadshader(lua_State *L) {
	const char *shader;
	qboolean	nomip;

	if(lua_type(L,1) == LUA_TSTRING) {
		if(lua_type(L,2) == LUA_TBOOLEAN) nomip = lua_toboolean(L,2);
		shader = lua_tostring(L,1);
		if(nomip) {
			lua_pushinteger(L,trap_R_RegisterShader( shader ));
		} else {
			lua_pushinteger(L,trap_R_RegisterShaderNoMip( shader ));
		}
		return 1;
	}
	return 0;
}

void CG_InitLua2D(lua_State *L) {
	luaL_openlib(L, "draw", Draw_methods, 0);
	lua_register(L, "__loadshader", qlua_loadshader);
}