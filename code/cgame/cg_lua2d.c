#include "cg_local.h"

vec4_t	lastcolor;

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
	VectorCopy(color,lastcolor);
	lastcolor[3] = color[3];

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

	x = lua_tointeger(L,1);
	y = lua_tointeger(L,2);
	w = lua_tointeger(L,3);
	h = lua_tointeger(L,4);

	if(lua_type(L,5) == LUA_TNUMBER) {
		shader = lua_tointeger(L,5);
		CG_DrawPic( x, y, w, h, shader );
	} else {
		CG_FillRect( x, y, w, h, lastcolor );
	}
	return 0;
}

int qlua_text(lua_State *L) {
	int x,y;
	int w=CHAR_WIDTH,h=CHAR_HEIGHT;
	float size = 0;
	const char *text = "text";

	luaL_checktype(L,1,LUA_TNUMBER);
	luaL_checktype(L,2,LUA_TNUMBER);
	luaL_checktype(L,3,LUA_TSTRING);

	x = lua_tointeger(L,1);
	y = lua_tointeger(L,2);
	text = lua_tostring(L,3);
	if(lua_type(L,4) == LUA_TNUMBER) {w = lua_tointeger(L,4);}
	if(lua_type(L,5) == LUA_TNUMBER) {h = lua_tointeger(L,5);}

	CG_DrawStringExt(x, y, text, lastcolor, qfalse, qfalse, w, h, 0 );

	return 0;
}

static const luaL_reg Draw_methods[] = {
  {"SetColor",		qlua_setcolor},
  {"Rect",			qlua_rect},
  {"Text",			qlua_text},
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