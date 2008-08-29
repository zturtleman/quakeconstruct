#include "cg_local.h"

qboolean lock = qfalse;

float qlua_pullfloat(lua_State *L, char *str, qboolean req, float def) {
	float v = def;
	lua_pushstring(L,str);
	lua_gettable(L,1);
	if(req) luaL_checktype(L,lua_gettop(L),LUA_TNUMBER);
	if(lua_type(L,lua_gettop(L)) == LUA_TNUMBER) {
		v = lua_tonumber(L,lua_gettop(L));
	}
	return v;
}

void qlua_pullvector(lua_State *L, char *str, vec3_t vec, qboolean req) {
	vec3_t v;
	VectorClear(v);
	lua_pushstring(L,str);
	lua_gettable(L,1);
	if(req) luaL_checktype(L,lua_gettop(L),LUA_TVECTOR);
	if(lua_type(L,lua_gettop(L)) == LUA_TVECTOR) {
		lua_tovector(L,lua_gettop(L),v);
	}
	vec[0] = v[0];
	vec[1] = v[1];
	vec[2] = v[2];
}

int qlua_renderscene(lua_State *L) {
	vec3_t			angles;
	refdef_t		refdef;
	float x,y,w,h;
	int a = 1;
	int top = lua_gettop(L);

	if(lock) {
		lua_pushstring(L,"RefDefs Locked Durring 3D hook.\n");
		lua_error(L);
		return 1;		
	}

	memset( &refdef, 0, sizeof( refdef ) );

	refdef.x = 0;
	refdef.y = 0;
	refdef.fov_x = 30;
	refdef.fov_y = 30;
	refdef.time = cg.time;
	refdef.rdflags = RDF_NOWORLDMODEL;
	AxisClear( refdef.viewaxis );

	luaL_checktype(L,1,LUA_TTABLE);

	x = qlua_pullfloat(L,"x",qtrue,0);
	y = qlua_pullfloat(L,"y",qtrue,0);
	w = qlua_pullfloat(L,"width",qtrue,0);
	h = qlua_pullfloat(L,"height",qtrue,0);
	refdef.fov_x = qlua_pullfloat(L,"fov_x",qfalse,30);
	refdef.fov_y = qlua_pullfloat(L,"fov_y",qfalse,30);
	qlua_pullvector(L,"origin",refdef.vieworg,qfalse);
	qlua_pullvector(L,"angles",angles,qfalse);

	//if(angles[0] != 0 || angles[1] != 0 || angles[2] != 0) {
		AnglesToAxis(angles,refdef.viewaxis);
	//}

	if(w > 0 && h > 0) {
		CG_AdjustFrom640( &x, &y, &w, &h );
		refdef.x = x;
		refdef.y = y;
		refdef.width = w;
		refdef.height = h;

		trap_R_RenderScene( &refdef );
		return 0;
	} else {
		lua_pushstring(L,"RefDef Failed\n");
		lua_error(L);
		return 1;
	}

	trap_R_ClearScene();
	return 0;
}

int qlua_createscene(lua_State *L) {
	if(lock) {
		lua_pushstring(L,"RefDefs Locked Durring 3D hook.\n");
		lua_error(L);
		return 1;		
	}

	trap_R_ClearScene();
	return 0;
}

int qlua_modelbounds(lua_State *L) {
	vec3_t	mins, maxs;

	luaL_checkint(L,1);

	trap_R_ModelBounds( lua_tointeger(L,1), mins, maxs );

	lua_pushvector(L,mins);
	lua_pushvector(L,maxs);
	return 2;
}

static const luaL_reg Render_methods[] = {
  {"CreateScene",		qlua_createscene},
  {"RenderScene",		qlua_renderscene},
  {"ModelBounds",		qlua_modelbounds},
  {0,0}
};

int qlua_loadmodel(lua_State *L) {
	const char *model;

	if(lua_type(L,1) == LUA_TSTRING) {
		model = lua_tostring(L,1);
		lua_pushinteger(L,trap_R_RegisterModel( model ));
		return 1;
	}
	return 0;
}

void CG_InitLua3D(lua_State *L) {
	luaL_openlib(L, "render", Render_methods, 0);
	lua_register(L, "__loadmodel", qlua_loadmodel);
}

void CG_Lock3D(qboolean b) {
	lock = b;
}