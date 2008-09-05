#include "cg_local.h"

vec4_t	lastcolor;
qboolean	maskOn = qfalse;

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

int qlua_maskrect(lua_State *L) {
	float x,y,w,h;

	luaL_checktype(L,1,LUA_TNUMBER);
	luaL_checktype(L,2,LUA_TNUMBER);
	luaL_checktype(L,3,LUA_TNUMBER);
	luaL_checktype(L,4,LUA_TNUMBER);

	x = lua_tonumber(L,1);
	y = lua_tonumber(L,2);
	w = lua_tonumber(L,3);
	h = lua_tonumber(L,4);

	x *= cgs.screenXScale;
	y *= cgs.screenYScale;
	w *= cgs.screenXScale;
	h *= cgs.screenYScale;

	trap_R_BeginMask(x,y,w,h);
	maskOn = qtrue;
	return 0;
}

int qlua_endmask(lua_State *L) {
	trap_R_EndMask();
	maskOn = qfalse;
	return 0;
}

float quickfloat(lua_State *L, int i, float def) {
	if(lua_type(L,i) == LUA_TNUMBER) def = lua_tonumber(L,i);
	return def;
}

int qlua_rect(lua_State *L) {
	float x,y,w,h,s,t,s2,t2;

	qhandle_t shader = cgs.media.whiteShader;

	luaL_checktype(L,1,LUA_TNUMBER);
	luaL_checktype(L,2,LUA_TNUMBER);
	luaL_checktype(L,3,LUA_TNUMBER);
	luaL_checktype(L,4,LUA_TNUMBER);

	x = lua_tonumber(L,1);
	y = lua_tonumber(L,2);
	w = lua_tonumber(L,3);
	h = lua_tonumber(L,4);

	if(lua_type(L,5) == LUA_TNUMBER) {
		shader = lua_tointeger(L,5);
	}
	
	s = quickfloat(L,6,0);
	t = quickfloat(L,7,0);
	s2 = quickfloat(L,8,1);
	t2 = quickfloat(L,9,1);

	CG_AdjustFrom640( &x, &y, &w, &h );
	trap_R_DrawStretchPic( x, y, w, h, s, t, s2, t2, shader );

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
  {"EndMask",		qlua_endmask},
  {"MaskRect",		qlua_maskrect},
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

void CG_KillMasks() {
	trap_R_EndMask();
	maskOn = qfalse;
}

void CG_InitLua2D(lua_State *L) {
	luaL_openlib(L, "draw", Draw_methods, 0);
	lua_register(L, "__loadshader", qlua_loadshader);
}