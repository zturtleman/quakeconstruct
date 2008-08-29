#include "cg_local.h"

//lua_pushlightuserdata(L,cl);
void lua_pushrefentity(lua_State *L, refEntity_t *cl) {
	refEntity_t *ent = NULL;

	if(cl == NULL) {
		lua_pushnil(L);
		return;
	}

	ent = (refEntity_t*)lua_newuserdata(L, sizeof(refEntity_t));
	memcpy(ent,cl,sizeof(refEntity_t));

	luaL_getmetatable(L, "RefEntity");
	lua_setmetatable(L, -2);
}

refEntity_t *lua_torefentity(lua_State *L, int i) {
	refEntity_t	*luaentity = NULL;

	luaL_checktype(L,i,LUA_TUSERDATA);

	luaentity = (refEntity_t *)luaL_checkudata(L, i, "RefEntity");//lua_touserdata(L, i);

	if (luaentity == NULL) luaL_typerror(L, i, "RefEntity");

	return luaentity;
}

int qlua_rgetpos(lua_State *L) {
	refEntity_t	*luaentity;
	vec3_t		origin;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		VectorCopy(luaentity->origin, origin);
		lua_pushvector(L,origin);
		return 1;
	}
	return 0;
}

int qlua_rsetpos(lua_State *L) {
	refEntity_t	*luaentity;
	vec3_t		origin;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TVECTOR);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_tovector(L,2,origin);
		VectorCopy( origin, luaentity->origin );
	}
	return 0;
}

int qlua_rgetpos2(lua_State *L) {
	refEntity_t	*luaentity;
	vec3_t		origin;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		VectorCopy(luaentity->oldorigin, origin);
		lua_pushvector(L,origin);
		return 1;
	}
	return 0;
}

int qlua_rsetpos2(lua_State *L) {
	refEntity_t	*luaentity;
	vec3_t		origin;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TVECTOR);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_tovector(L,2,origin);
		VectorCopy( origin, luaentity->oldorigin );
	}
	return 0;
}

int qlua_rgetangles(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushvector(L,luaentity->axis[0]);
		return 1;
	}
	return 0;
}

int qlua_rsetangles(lua_State *L) {
	refEntity_t	*luaentity;
	vec3_t angles;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TVECTOR);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_tovector(L,2,angles);
		AnglesToAxis( angles, luaentity->axis );
	}
	return 0;
}

int qlua_rsetshader(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		luaentity->customShader = lua_tointeger(L,2);
	}
	return 0;
}

int qlua_rgetshader(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->customShader);
		return 1;
	}
	return 0;
}

int qlua_rsetmodel(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		luaentity->hModel = lua_tointeger(L,2);
	}
	return 0;
}

int qlua_rgetmodel(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->hModel);
		return 1;
	}
	return 0;
}

int qlua_rsettype(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		if(lua_tointeger(L,2) < 0 || lua_tointeger(L,2) >= RT_MAX_REF_ENTITY_TYPE) {
			lua_pushstring(L,"Index out of range (Render Type).");
			lua_error(L);
			return 1;
		}
		luaentity->reType = lua_tointeger(L,2);
	}
	return 0;
}

int qlua_rgettype(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->reType);
		return 1;
	}
	return 0;
}

int qlua_rsetradius(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		luaentity->radius = lua_tonumber(L,2);
	}
	return 0;
}

int qlua_rgetradius(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushnumber(L,luaentity->radius);
		return 1;
	}
	return 0;
}

int qlua_rsetskin(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL && lua_tointeger(L,2) > -1) {
		luaentity->customSkin = lua_tointeger(L,2);
	}
	return 0;
}

int qlua_rgetskin(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->customSkin);
		return 1;
	}
	return 0;
}

int qlua_rsetscale(lua_State *L) {
	refEntity_t	*luaentity;
	vec3_t in;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TVECTOR);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_tovector(L,2,in);
		VectorScale(luaentity->axis[0],in[0],luaentity->axis[0]);
		VectorScale(luaentity->axis[1],in[1],luaentity->axis[1]);
		VectorScale(luaentity->axis[2],in[2],luaentity->axis[2]);
		return 1;
	}
	return 0;	
}

int qlua_rsetrotation(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		luaentity->rotation = lua_tonumber(L,2);
		return 1;
	}
	return 0;	
}

int qlua_rsetcolor(lua_State *L) {
	int err = 0;
	refEntity_t	*luaentity;
	vec4_t	color;
	
	VectorClear(color);

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaentity = lua_torefentity(L,1);

	if(lua_type(L,2) == LUA_TNUMBER) {
		color[0] = lua_tonumber(L,2);
		if(lua_type(L,3) == LUA_TNUMBER) {
			color[1] = lua_tonumber(L,3);
			if(lua_type(L,4) == LUA_TNUMBER) {
				color[2] = lua_tonumber(L,4);
				if(lua_type(L,5) == LUA_TNUMBER) {
					color[3] = lua_tonumber(L,5);
				}
			}
		}
	}
	if(color[0] > 1) {color[0] = color[0] / 255;}
	if(color[1] > 1) {color[1] = color[1] / 255;}
	if(color[2] > 1) {color[2] = color[2] / 255;}
	if(color[3] > 1) {color[3] = color[3] / 255;}

	if(color[0] > 1) {err = 1;}
	if(color[1] > 1) {err = 1;}
	if(color[2] > 1) {err = 1;}
	if(color[3] > 1) {err = 1;}

	if(err == 1) {
		lua_pushstring(L,"Color out of range");
		lua_error(L);
		return 1;
	}

	if(luaentity != NULL) {
		luaentity->shaderRGBA[0] = (int)(color[0]*255);
		luaentity->shaderRGBA[1] = (int)(color[1]*255);
		luaentity->shaderRGBA[2] = (int)(color[2]*255);
		luaentity->shaderRGBA[3] = (int)(color[3]*255);
	}

	return 0;
}

int qlua_rrender(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		trap_R_AddRefEntityToScene( luaentity );
	}
	return 0;
}

int qlua_rrenderfx(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		if(lua_tointeger(L,2) < 1 || lua_tointeger(L,2) >= 512) {
			lua_pushstring(L,"Index out of range (Render Fx).");
			lua_error(L);
			return 1;
		}
		luaentity->renderfx |= lua_tointeger(L,2);
	}
	return 0;
}

static int Entity_tostring (lua_State *L)
{
  lua_pushfstring(L, "RefEntity: %p", lua_touserdata(L, 1));
  return 1;
}

static int Entity_equal (lua_State *L)
{
	centity_t *e1 = lua_toentity(L,1);
	centity_t *e2 = lua_toentity(L,2);
	if(e1 != NULL && e2 != NULL) {
		lua_pushboolean(L, (e1->currentState.number == e2->currentState.number));
	} else {
		lua_pushboolean(L, 0);
	}
  return 1;
}

static const luaL_reg REntity_methods[] = {
  {"AddRenderFx",	qlua_rrenderfx},
  {"GetPos",		qlua_rgetpos},
  {"SetPos",		qlua_rsetpos},
  {"GetPos2",		qlua_rgetpos2},
  {"SetPos2",		qlua_rsetpos2},
  {"GetAngles",		qlua_rgetangles},
  {"SetAngles",		qlua_rsetangles},
  {"SetShader",		qlua_rsetshader},
  {"GetShader",		qlua_rgetshader},
  {"SetModel",		qlua_rsetmodel},
  {"GetModel",		qlua_rgetmodel},
  {"SetSkin",		qlua_rsetskin},
  {"GetSkin",		qlua_rgetskin},
  {"SetType",		qlua_rsettype},
  {"GetType",		qlua_rgettype},
  {"SetRadius",		qlua_rsetradius},
  {"GetRadius",		qlua_rgetradius},
  {"SetColor",		qlua_rsetcolor},
  {"SetRotation",	qlua_rsetrotation},
  {"Scale",			qlua_rsetscale},
  {"Render",		qlua_rrender},
  {0,0}
};

static const luaL_reg REntity_meta[] = {
  {"__tostring", Entity_tostring},
  {"__eq", Entity_equal},
  {0, 0}
};

int REntity_register (lua_State *L) {
	luaL_openlib(L, "RefEntity", REntity_methods, 0);

	luaL_newmetatable(L, "RefEntity");

	luaL_openlib(L, 0, REntity_meta, 0);
	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);

	lua_pop(L, 1);
	return 1;
}

int qlua_createrefentity (lua_State *L) {
	refEntity_t		ent;
	refEntity_t		*ent2;
	
	if(lua_type(L,1) == LUA_TUSERDATA) {
		ent2 = lua_torefentity(L,1);
		if(ent2 != NULL) {
			memcpy(&ent,ent2,sizeof(refEntity_t));
			lua_pushrefentity(L,&ent);
			return 1;
		}
	}

	memset( &ent, 0, sizeof( ent ) );
	
	AxisClear( ent.axis );

	lua_pushrefentity(L,&ent);
	return 1;
}

void CG_InitLuaREnts(lua_State *L) {
	REntity_register(L);
	//lua_register(L,"GetEntitiesByClass",qlua_getentitiesbyclass);
	//lua_register(L,"GetAllPlayers",qlua_getallplayers);
	lua_register(L,"RefEntity",qlua_createrefentity);
}