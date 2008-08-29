#include "cg_local.h"

typedef struct {
	vec_t x;
	vec_t y;
	vec_t z;
} luavector_t;


/*void lua_pushvector(lua_State *L, vec3_t vec) {
	luavector_t *userdata = (luavector_t*)lua_newuserdata(L, sizeof(luavector_t));
	userdata->x = vec[0];
	userdata->y = vec[1];
	userdata->z = vec[2];

	luaL_getmetatable(L, "Vector");
	lua_setmetatable(L, -2);
}

void lua_tovector(lua_State *L, int i, vec3_t in) {
	luavector_t	*luavector;
	luaL_checktype(L,i,LUA_TUSERDATA);
	luavector = (luavector_t *)lua_touserdata(L, i);
	if (luavector == NULL) luaL_typerror(L, i, "Vector");

	in[0] = luavector->x;
	in[1] = luavector->y;
	in[2] = luavector->z;
}*/



void lua_pushvector(lua_State *L, vec3_t vec) {
	int tableIdx;
	lua_createtable(L,3,0);

	tableIdx = lua_gettop(L);

	lua_pushstring(L, "x");
	lua_pushnumber(L,vec[0]);
	lua_settable(L, tableIdx);

	lua_pushstring(L, "y");
	lua_pushnumber(L,vec[1]);
	lua_settable(L, tableIdx);

	lua_pushstring(L, "z");
	lua_pushnumber(L,vec[2]);
	lua_settable(L, tableIdx);
}

void lua_tovector(lua_State *L, int i, vec3_t in) {
	//vec3_t	out;
	float x = -1;
	float y = -1;
	float z = -1;
	
	//G_Printf("Got A Good Table.\n");

	lua_pushstring(L,"x");
	lua_gettable(L,i);
	x = lua_tonumber(L,lua_gettop(L));

	lua_pushstring(L,"y");
	lua_gettable(L,i);
	y = lua_tonumber(L,lua_gettop(L));

	lua_pushstring(L,"z");
	lua_gettable(L,i);
	z = lua_tonumber(L,lua_gettop(L));

	//G_Printf("%i,%i,%i\n",x,y,z);


	//if(x != -1 && y != -1 && z != -1) {
		in[0] = x;
		in[1] = y;
		in[2] = z;
	//}
}

luavector_t *lua_toluavector(lua_State *L, int i) {
	luavector_t	*luavector;
	luaL_checktype(L,i,LUA_TUSERDATA);
	luavector = (luavector_t *)lua_touserdata(L, i);
	if (luavector == NULL) luaL_typerror(L, i, "Vector");
	return luavector;
}

static int qlua_setvector (lua_State *L) {
	luavector_t *vec = lua_toluavector(L, 1);
	int index = lua_tointeger(L, 2);
	vec_t value = luaL_checknumber(L, 3);

	if(index == 0)
		vec->x = value;

	if(index == 1)
		vec->y = value;

	if(index == 2)
		vec->z = value;

	return 0;
}

static int qlua_getvector (lua_State *L) {
	luavector_t *vec = NULL;
	int index = 0;

	vec = lua_toluavector(L, 1);
	index = lua_tointeger(L, 2);

	if(index == 0) {
		lua_pushnumber(L,vec->x);
		return 1;
	}

	if(index == 1) {
		lua_pushnumber(L,vec->y);
		return 1;
	}

	if(index == 2) {
		lua_pushnumber(L,vec->z);
		return 1;
	}
	return 0;
}

/*
static int qlua_setvector (lua_State *L) {
	luavector_t *vec = lua_toluavector(L, 1);
	const char *index = luaL_checkstring(L, 2);
	vec_t value = luaL_checknumber(L, 3);

	if(strcmp(index,"x") == 0)
		vec->x = value;

	if(strcmp(index,"y") == 0)
		vec->y = value;

	if(strcmp(index,"z") == 0)
		vec->z = value;

	return 0;
}

static int qlua_getvector (lua_State *L) {
	luavector_t *vec = NULL;
	const char *index = "";

	vec = lua_toluavector(L, 1);
	index = lua_tostring(L, 2);

	if(index != NULL) {
		if(strcmp(index,"x") == 0) {
			lua_pushnumber(L,vec->x);
			return 1;
		}

		if(strcmp(index,"y") == 0) {
			lua_pushnumber(L,vec->y);
			return 1;
		}

		if(strcmp(index,"z") == 0) {
			lua_pushnumber(L,vec->z);
			return 1;
		}
	}
	return 0;
}
*/

static int Vector_tostring (lua_State *L)
{
  lua_pushfstring(L, "Vector: %p", lua_touserdata(L, 1));
  return 1;
}

static int Vector_equal (lua_State *L)
{
	vec3_t v1;
	vec3_t v2;

	lua_tovector(L,1,v1);
	lua_tovector(L,2,v2);

	if(v1 != NULL && v2 != NULL) {
		lua_pushboolean(L, (v1[0] == v2[0] && v1[1] == v2[1] && v1[2] == v2[2]));
	} else {
		lua_pushboolean(L, 0);
	}
  return 1;
}

static const luaL_reg Vector_methods[] = {
  {"get",		qlua_getvector},
  {"set",		qlua_setvector},
  {0,0}
};

static const luaL_reg Vector_meta[] = {
  {"__tostring", Vector_tostring},
  {"__eq", Vector_equal},
  {"__index", qlua_getvector},
  {"__newindex", qlua_setvector},
  {0, 0}
};

int Vector_register (lua_State *L) {
	luaL_openlib(L, "Vector", Vector_methods, 0);

	luaL_newmetatable(L, "Vector");

	luaL_openlib(L, 0, Vector_meta, 0);

	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);

	lua_pop(L, 1);

	return 1;
}

void lua_pushtrace(lua_State *L, trace_t results) {
	lua_newtable(L);

	if(results.fraction != 1.0) {
		lua_pushstring(L, "allsolid");
		lua_pushboolean(L,results.allsolid);
		lua_rawset(L, -3);

		lua_pushstring(L, "contents");
		lua_pushinteger(L,results.contents);
		lua_rawset(L, -3);

		if(results.entityNum != ENTITYNUM_MAX_NORMAL) {
			lua_pushstring(L, "entity");
			lua_pushentity(L,&cg_entities[ results.entityNum ]);
			lua_rawset(L, -3);
		}

		lua_pushstring(L, "normal");
		lua_pushvector(L,results.plane.normal);
		lua_rawset(L, -3);

		lua_pushstring(L, "surfaceflags");
		lua_pushinteger(L,results.surfaceFlags);
		lua_rawset(L, -3);
	}

	lua_pushstring(L, "startsolid");
	lua_pushboolean(L,results.startsolid);
	lua_rawset(L, -3);

	lua_pushstring(L, "endpos");
	lua_pushvector(L,results.endpos);
	lua_rawset(L, -3);

	lua_pushstring(L, "fraction");
	lua_pushnumber(L,results.fraction);
	lua_rawset(L, -3);

	lua_pushstring(L, "hit");
	lua_pushboolean(L, (results.fraction != 1.0));
	lua_rawset(L, -3);
}

int qlua_trace(lua_State *L) {
	trace_t results;
	vec3_t start, end;
	vec3_t mins, maxs;
	centity_t *ent;
	int pass=ENTITYNUM_NONE, mask=MASK_ALL;
	int top = lua_gettop(L);

	if(top > 1) {
		lua_tovector(L,1,start);
		lua_tovector(L,2,end);
		VectorSet(mins,vec3_origin[0],vec3_origin[1],vec3_origin[2]);
		VectorSet(maxs,vec3_origin[0],vec3_origin[1],vec3_origin[2]);
		if(top > 2) {
			if(lua_type(L,3) == LUA_TNUMBER) {
				pass = lua_tointeger(L,3);
			} else if(lua_type(L,3) == LUA_TUSERDATA) {
				ent = lua_toentity(L,3);
				if(ent != NULL) {
					pass = ent->currentState.number;
				}
			}
			if(top > 3)
				mask = lua_tointeger(L,4);
			if(top > 4) {
				if(lua_type(L,5) == LUA_TVECTOR) lua_tovector(L,5,mins);
				if(lua_type(L,6) == LUA_TVECTOR) lua_tovector(L,6,maxs);
			}
		}
		CG_Trace(&results,start,mins,maxs,end,pass,mask);

		lua_pushtrace(L, results);

		return 1;
	}


	return 0;
}

int qlua_VectorToAngles(lua_State *L) {
	vec3_t v,angles;

	luaL_checktype(L,1,LUA_TVECTOR);
	lua_tovector(L,1,v);

	vectoangles(v,angles);

	lua_pushvector(L,angles);
	return 1;
}

int qlua_AngleVectors(lua_State *L) {
	vec3_t v,f,r,u;
	luaL_checktype(L,1,LUA_TVECTOR);
	lua_tovector(L,1,v);

	v[0] = AngleMod(v[0]);
	v[1] = AngleMod(v[1]);
	v[2] = AngleMod(v[2]);

	AngleVectors(v,f,r,u);
	lua_pushvector(L,f);
	lua_pushvector(L,r);
	lua_pushvector(L,u);
	return 3;
}

int qlua_VectorNormalize(lua_State *L) {
	vec3_t v;
	int	len = 0;
	luaL_checktype(L,1,LUA_TVECTOR);
	lua_tovector(L,1,v);
	len = VectorNormalize(v);
	lua_pushvector(L,v);
	lua_pushinteger(L,len);
	return 2;
}

int qlua_VectorLength(lua_State *L) {
	vec3_t v;
	float len = 0;
	luaL_checktype(L,1,LUA_TVECTOR);
	lua_tovector(L,1,v);
	len = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
	lua_pushnumber(L,len);
	return 1;
}

int qlua_VectorForward(lua_State *L) {
	vec3_t v;
	vec3_t f,r,u;

	luaL_checktype(L,1,LUA_TVECTOR);
	lua_tovector(L,1,v);
	AngleVectors(v,f,r,u);
	lua_pushvector(L,f);
	return 1;
}

int qlua_VectorRight(lua_State *L) {
	vec3_t v;
	vec3_t axis[3];

	luaL_checktype(L,1,LUA_TVECTOR);
	lua_tovector(L,1,v);
	AnglesToAxis(v,axis);
	lua_pushvector(L,axis[0]);
	return 1;
}

int qlua_VectorUp(lua_State *L) {
	vec3_t v;
	vec3_t axis[3];

	luaL_checktype(L,1,LUA_TVECTOR);
	lua_tovector(L,1,v);
	AnglesToAxis(v,axis);
	lua_pushvector(L,axis[2]);
	return 1;
}

void CG_InitLuaVector(lua_State *L) {
	lua_register(L,"TraceLine",qlua_trace);
	lua_register(L,"VectorToAngles",qlua_VectorToAngles);
	lua_register(L,"VectorNormalize",qlua_VectorNormalize);
	lua_register(L,"VectorLength",qlua_VectorLength);
	lua_register(L,"VectorForward",qlua_VectorForward);
	lua_register(L,"VectorRight",qlua_VectorRight);
	lua_register(L,"VectorUp",qlua_VectorUp);
	lua_register(L,"AngleVectors",qlua_AngleVectors);

	Vector_register(L);
}