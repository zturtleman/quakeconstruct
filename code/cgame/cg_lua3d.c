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

float qlua_pullfloat_i(lua_State *L, int i, qboolean req, float def, int m) {
	float v = def;
	lua_pushinteger(L,i);
	lua_gettable(L,m);
	if(req) luaL_checktype(L,lua_gettop(L),LUA_TNUMBER);
	if(lua_type(L,lua_gettop(L)) == LUA_TNUMBER) {
		v = lua_tonumber(L,lua_gettop(L));
	}
	return v;
}

int qlua_pullint_i(lua_State *L, int i, qboolean req, int def, int m) {
	int v = def;
	lua_pushinteger(L,i);
	lua_gettable(L,m);
	if(req) luaL_checktype(L,lua_gettop(L),LUA_TNUMBER);
	if(lua_type(L,lua_gettop(L)) == LUA_TNUMBER) {
		v = lua_tointeger(L,lua_gettop(L));
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
		vec[0] = v[0];
		vec[1] = v[1];
		vec[2] = v[2];
	}
}

void qlua_pullvector_i(lua_State *L, int i, vec3_t vec, qboolean req, int m) {
	vec3_t v;
	VectorClear(v);
	lua_pushinteger(L,i);
	lua_gettable(L,m);
	if(req) luaL_checktype(L,lua_gettop(L),LUA_TVECTOR);
	if(lua_type(L,lua_gettop(L)) == LUA_TVECTOR) {
		lua_tovector(L,lua_gettop(L),v);
		vec[0] = v[0];
		vec[1] = v[1];
		vec[2] = v[2];
	}
}

int lua_torefdef(lua_State *L, int idx, refdef_t *refdef, qboolean a640) {
	float x,y,w,h;
	vec3_t	angles;

	luaL_checktype(L,idx,LUA_TTABLE);

	x = qlua_pullfloat(L,"x",qfalse,refdef->x);
	y = qlua_pullfloat(L,"y",qfalse,refdef->y);
	w = qlua_pullfloat(L,"width",qfalse,refdef->width);
	h = qlua_pullfloat(L,"height",qfalse,refdef->height);
	refdef->fov_x = qlua_pullfloat(L,"fov_x",qfalse,refdef->fov_x);
	refdef->fov_y = qlua_pullfloat(L,"fov_y",qfalse,refdef->fov_y);
	qlua_pullvector(L,"origin",refdef->vieworg,qfalse);
	qlua_pullvector(L,"angles",angles,qfalse);

	//if(angles[0] != 0 || angles[1] != 0 || angles[2] != 0) {
		AnglesToAxis(angles,refdef->viewaxis);
	//}

	if(w > 0 && h > 0) {
		if(a640) {
			CG_AdjustFrom640( &x, &y, &w, &h );
			refdef->x = x;
			refdef->y = y;
			refdef->width = w;
			refdef->height = h;
		}
		return 0;
	} else {
		lua_pushstring(L,"RefDef Failed\n");
		lua_error(L);
		return 1;
	}
}

int qlua_setrefdef(lua_State *L) {
	luaL_checktype(L,1,LUA_TTABLE);
	lua_torefdef(L,1,&cg.refdef,qfalse);
	return 0;
}

int qlua_renderscene(lua_State *L) {
	refdef_t		refdef;
	int top = lua_gettop(L);
	int error = 0;

	if(lock) {
		lua_pushstring(L,"RefDefs Locked Durring 3D hook.\n");
		lua_error(L);
		return 1;
	}

	//memset( &refdef, 0, sizeof( refdef ) );
	refdef.x = 0;
	refdef.y = 0;
	refdef.fov_x = 30;
	refdef.fov_y = 30;
	refdef.time = cg.time;
	refdef.rdflags = RDF_NOWORLDMODEL;
	AxisClear( refdef.viewaxis );

	error = lua_torefdef(L, 1, &refdef, qtrue);
	if(error == 1) {
		trap_R_ClearScene();
		//CG_Printf("Scene Failed\n");
	} else {
		trap_R_RenderScene( &refdef );
		//CG_Printf("Rendered Scene: %f, %f, %f, %f\n",refdef.x,refdef.y,refdef.width,refdef.height);
	}
	return error;
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

void qlua_pullst(lua_State *L, float v[2], int idx) {
	vec3_t tvec;
	qlua_pullvector_i(L,2,tvec,qtrue,idx);
	v[0] = tvec[0];
	v[1] = tvec[1];
}

void qlua_pullmodulate(lua_State *L, byte v[4], int idx) {
	//CG_Printf("Pulled Ints\n");
	v[0] = (byte) qlua_pullint_i(L,3,qtrue,0,idx);
	v[1] = (byte) qlua_pullint_i(L,4,qtrue,0,idx);
	v[2] = (byte) qlua_pullint_i(L,5,qtrue,0,idx);
	v[3] = (byte) qlua_pullint_i(L,6,qtrue,0,idx);
}

void qlua_readvert(lua_State *L, polyVert_t *vert, vec3_t offset) {
	int idx = lua_gettop(L);

	//CG_Printf("   Read vector\n");
	qlua_pullvector_i(L,1,vert->xyz,qtrue,idx);
	
	//CG_Printf("   Read st\n");
	qlua_pullst(L,vert->st,idx);

	//CG_Printf("   Read modulate\n");
	qlua_pullmodulate(L,vert->modulate,idx);

	VectorAdd(vert->xyz,offset,vert->xyz);

	/*CG_Printf("   Out: %f,%f,%f [%f,%f] %i,%i,%i,%i\n",
		vert->xyz[0],
		vert->xyz[1],
		vert->xyz[2],
		vert->st[0],
		vert->st[1],
		(int) vert->modulate[0],
		(int) vert->modulate[1],
		(int) vert->modulate[2],
		(int) vert->modulate[3]);

	CG_Printf("   Done\n");*/
}

int qlua_passpoly(lua_State *L) {
	int size = 0;
	int i = 0;
	qhandle_t shader = cgs.media.whiteShader;
	vec3_t offset;
	polyVert_t	verts[1024];

	luaL_checktype(L,1,LUA_TTABLE);

	if(lua_type(L,2) == LUA_TNUMBER) {
		shader = lua_tointeger(L,2);
	}

	if(lua_type(L,3) == LUA_TVECTOR) {
		lua_tovector(L,3,offset);
	}

	size = luaL_getn(L,1);
	if(size > 1024) return 0;

	for(i=0;i<size;i++) {
		lua_pushinteger(L,i+1);
		lua_gettable(L,1);
		
		//CG_Printf("Read Vert: %i\n",i+1);
		qlua_readvert(L,&verts[i],offset);
	}

	trap_R_AddPolyToScene( shader, size, verts );

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
  {"SetRefDef",			qlua_setrefdef},
  {"DrawPoly",			qlua_passpoly},
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