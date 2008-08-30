#include "cg_local.h"

centity_t *qlua_getrealentity(centity_t *ent) {
	centity_t	*realent = NULL;
	centity_t	*tent = NULL;
	int numEnts = sizeof(cg_entities) / sizeof(cg_entities[0]);
	int i=0;
	int n=0;

	for (i = 0, tent = cg_entities, n = 1;
			i < numEnts;
			i++, tent++) {
			if(ent->currentState.number == tent->currentState.number) {
				if(tent != NULL) {
					return tent;
				}
			}
			n++;
	}
	CG_Printf("Unable To Find Entity: %i\n", ent->currentState.number);
	
	return NULL;
}


//lua_pushlightuserdata(L,cl);
void lua_pushentity(lua_State *L, centity_t *cl) {
	centity_t *ent = NULL;

	if(cl == NULL || cl->currentState.number == ENTITYNUM_MAX_NORMAL || cl->currentState.number < 0) {
		lua_pushnil(L);
		return;
	}

	ent = (centity_t*)lua_newuserdata(L, sizeof(centity_t));
	memcpy(ent,cl,sizeof(centity_t));

	ent->currentState.number = cl->currentState.number;

	luaL_getmetatable(L, "Entity");
	lua_setmetatable(L, -2);
}

centity_t *lua_toentity(lua_State *L, int i) {
	centity_t	*luaentity;
	luaL_checktype(L,i,LUA_TUSERDATA);
	luaentity = (centity_t *)luaL_checkudata(L, i, "Entity");
	//luaentity = qlua_getrealentity(luaentity);

	if (luaentity == NULL) luaL_typerror(L, i, "Entity");

	return luaentity;
}

int qlua_getpos(lua_State *L) {
	centity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushvector(L,luaentity->lerpOrigin);
		return 1;
	}
	return 0;
}

int qlua_setpos(lua_State *L) {
	centity_t	*luaentity;
	vec3_t		origin;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TVECTOR);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
			BG_EvaluateTrajectory( &luaentity->currentState.pos, cg.time, origin );
			lua_tovector(L,2,luaentity->currentState.pos.trBase);
			luaentity->currentState.pos.trDuration += (cg.time - luaentity->currentState.pos.trTime);
			luaentity->currentState.pos.trTime = cg.time;
			
			VectorCopy(luaentity->currentState.pos.trBase, luaentity->currentState.origin);
		return 1;
	}
	return 0;
}

int qlua_getangles(lua_State *L) {
	centity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushvector(L,luaentity->currentState.angles);
		return 1;
	}
	return 0;
}

int qlua_setangles(lua_State *L) {
	centity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TVECTOR);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_tovector(L,2,luaentity->currentState.angles);
		return 1;
	}
	return 0;
}

int qlua_aimvec(lua_State *L) {
	centity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushvector(L,luaentity->currentState.angles);
		return 1;
	}
	return 0;
}

int qlua_isclient(lua_State *L) {
	centity_t	*luaentity;
	clientInfo_t	*ci;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);

	if(luaentity != NULL) {
		ci = &cgs.clientinfo[ luaentity->currentState.clientNum ];
		if(ci != NULL && ci->botSkill != 0) {
			lua_pushboolean(L,0);
		} else {
			lua_pushboolean(L,1);
		}
		return 1;
	}
	return 0;
}

int qlua_isbot(lua_State *L) {
	centity_t	*luaentity;
	clientInfo_t	*ci;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		ci = &cgs.clientinfo[ luaentity->currentState.clientNum ];
		if(ci != NULL && ci->botSkill != 0) {
			lua_pushboolean(L,1);
		} else {
			lua_pushboolean(L,0);
		}
		return 1;
	}
	return 0;
}

int qlua_getclientinfo(lua_State *L) {
	centity_t	*luaentity;
	clientInfo_t	*ci;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		ci = &cgs.clientinfo[ luaentity->currentState.clientNum ];
		if(luaentity->currentState.clientNum == cg.clientNum) {
			if(cg.snap && cg.snap->ps.commandTime != 0) {
				ci->health = cg.snap->ps.stats[STAT_HEALTH];
				ci->armor = cg.snap->ps.stats[STAT_ARMOR];
				ci->curWeapon = cg.snap->ps.weapon;
				ci->ammo = cg.snap->ps.ammo[ci->curWeapon];
			}
		}
		CG_PushClientInfoTab(L,ci);
	}
	return 1;
}

int qlua_getotherentity(lua_State *L) {
	centity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(luaentity->currentState.otherEntityNum != ENTITYNUM_MAX_NORMAL) {
			lua_pushentity(L,&cg_entities[ luaentity->currentState.otherEntityNum ]);
			return 1;
		}
	}
	return 0;
}

int qlua_getotherentity2(lua_State *L) {
	centity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(luaentity->currentState.otherEntityNum2 != ENTITYNUM_MAX_NORMAL) {
			lua_pushentity(L,&cg_entities[ luaentity->currentState.otherEntityNum2 ]);
			return 1;
		}
	}
	return 0;
}

int qlua_getbytedir(lua_State *L) {
	centity_t	*luaentity;
	vec3_t		dir;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		ByteToDir( luaentity->currentState.eventParm, dir );
		lua_pushvector(L,dir);
		return 1;
	}
	return 0;
}

int qlua_entityid(lua_State *L) {
	centity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->currentState.number);
	}
	return 1;
}

static int Entity_tostring (lua_State *L)
{
  lua_pushfstring(L, "Entity: %p", lua_touserdata(L, 1));
  return 1;
}

static int Entity_equal (lua_State *L)
{
	centity_t *e1 = lua_toentity(L,1);
	centity_t *e2 = lua_toentity(L,2);
	if(e1 != NULL && e2 != NULL) {
		//CG_Printf("EQ CHECK: %i %i\n",e1->currentState.clientNum,e2->currentState.clientNum);
		lua_pushboolean(L, (e1->currentState.clientNum == e2->currentState.clientNum) &&
		(e1->currentState.number == e2->currentState.number));
	} else {
		lua_pushboolean(L, 0);
	}
  return 1;
}

static const luaL_reg Entity_methods[] = {
  {"GetPos",		qlua_getpos},
  {"SetPos",		qlua_setpos},
  {"GetInfo",		qlua_getclientinfo},
  {"GetOtherEntity",	qlua_getotherentity},
  {"GetOtherEntity2",	qlua_getotherentity},
  {"GetByteDir",		qlua_getbytedir},
  {"EntIndex",		qlua_entityid},
  {"IsBot",			qlua_isbot},
  {"IsClient",		qlua_isclient},
  {0,0}
};

static const luaL_reg Entity_meta[] = {
  {"__tostring", Entity_tostring},
  {"__eq", Entity_equal},
  {0, 0}
};

int Entity_register (lua_State *L) {
	luaL_openlib(L, "Entity", Entity_methods, 0);

	luaL_newmetatable(L, "Entity");

	luaL_openlib(L, 0, Entity_meta, 0);
	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);

	lua_pop(L, 1);
	return 1;
}

int qlua_unlink(lua_State *L) {
	centity_t *ent;
	luaL_checktype(L,1,LUA_TUSERDATA);

	ent = lua_toentity(L,1);
	if(ent != NULL) {
		//qlua_UnlinkEntity(ent);
	}
	return 0;
}

int qlua_link(lua_State *L) {
	centity_t *ent;
	luaL_checktype(L,1,LUA_TUSERDATA);

	ent = lua_toentity(L,1);
	if(ent != NULL) {
		//qlua_LinkEntity(ent);
	}
	return 0;
}

int qlua_localplayer(lua_State *L) {
	centity_t *ent = &cg_entities[ cg.clientNum ];
	if(ent != NULL) {
		lua_pushentity(L, ent);
		return 1;
	}
	return 0;
}

void CG_InitLuaEnts(lua_State *L) {
	Entity_register(L);
	//lua_register(L,"GetEntitiesByClass",qlua_getentitiesbyclass);
	//lua_register(L,"GetAllPlayers",qlua_getallplayers);
	lua_register(L,"LocalPlayer",qlua_localplayer);
	lua_register(L,"UnlinkEntity",qlua_unlink);
	lua_register(L,"LinkEntity",qlua_link);
}