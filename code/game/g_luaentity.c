#include "g_local.h"

gentity_t *qlua_getrealentity(gentity_t *ent) {
	gentity_t	*tent = NULL;
	int numEnts = sizeof(g_entities) / sizeof(g_entities[0]);
	/*int i=0;
	int n=0;

	for (i = 0, tent = g_entities, n = 1;
			i < level.num_entities;
			i++, tent++) {
		if (tent->classname) {
			if(ent->s.number == tent->s.number) {
				if(tent != NULL) {
					return tent;
				}
			}
			n++;
		}
	}

	tent = g_entities + ent->s.number;
	if(tent != NULL) {
		tent->classname = "player";
		return tent;
	}

	G_Printf("Unable To Find Entity: %i\n", ent->s.number);*/

	if ( !ent || ent->s.number < 0 || ent->s.number > numEnts ) {
		G_Printf("Invalid Entity: %i\n", ent->s.number);
	} else {
		tent = &g_entities[ent->s.number];
		if(tent != NULL) {
			return tent;
		}
	}
	
	return NULL;
}

void lua_entitytab(lua_State *L, gentity_t *ent) {
	if(ent->lua_persistanttable == 0) {
		lua_newtable(L);
		ent->lua_persistanttable = qlua_storefunc(L,lua_gettop(L),0);
	}
}

int lua_getentitytable(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(qlua_getstored(L,luaentity->lua_persistanttable)) {
			return 1;
		}
	}
	return 0;
}

/*int lua_setentitytable(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TTABLE);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_gettable(L,2);
		luaentity->lua_persistanttable = qlua_storefunc(L,lua_gettop(L),0);
		return 1;
	}
	return 0;
}*/

//lua_pushlightuserdata(L,cl);
void lua_pushentity(lua_State *L, gentity_t *cl) {
	gentity_t *ent = NULL;

	if(cl == NULL || cl->s.number == ENTITYNUM_MAX_NORMAL || (cl->client == NULL && cl->s.number == 0)) {
		lua_pushnil(L);
		return;
	}

	lua_entitytab(L, cl);

	ent = (gentity_t*)lua_newuserdata(L, sizeof(gentity_t));
	memcpy(ent,cl,sizeof(gentity_t));
	
	ent->s.number = cl->s.number;

	luaL_getmetatable(L, "Entity");
	lua_setmetatable(L, -2);
}

gentity_t *lua_toentity(lua_State *L, int i) {
	gentity_t	*luaentity;
	luaL_checktype(L,i,LUA_TUSERDATA);
	luaentity = (gentity_t *)lua_touserdata(L, i);
	luaentity = qlua_getrealentity(luaentity);

	if (luaentity == NULL) luaL_typerror(L, i, "Entity");
	return luaentity;
}

int qlua_getclientinfo(lua_State *L) {
	gentity_t	*luaentity;

	lua_newtable(L);

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL && luaentity->client != NULL) {
		lua_pushstring(L, "name");
		lua_pushstring(L,luaentity->client->pers.netname);
		lua_rawset(L, -3);

		lua_pushstring(L, "health");
		lua_pushinteger(L,luaentity->health);
		lua_rawset(L, -3);

		lua_pushstring(L, "score");
		lua_pushinteger(L,luaentity->client->ps.persistant[PERS_SCORE]);
		lua_rawset(L, -3);

		lua_pushstring(L, "connected");
		lua_pushboolean(L,luaentity->client->pers.connected);
		lua_rawset(L, -3);

		lua_pushstring(L, "weapon");
		lua_pushinteger(L,luaentity->client->ps.weapon);
		lua_rawset(L, -3);

		lua_pushstring(L, "buttons");
		lua_pushinteger(L,luaentity->client->buttons);
		lua_rawset(L, -3);

		lua_pushstring(L, "model");
		lua_pushinteger(L,luaentity->s.modelindex);
		lua_rawset(L, -3);

		lua_pushstring(L, "team");
		lua_pushinteger(L,luaentity->client->sess.sessionTeam);
		lua_rawset(L, -3);
	} else {
		lua_pushstring(L,"<CLIENT WAS NIL>");
	}
	return 1;
}

int qlua_setclientinfo(lua_State *L) {
	gentity_t	*luaentity;
	int			inf;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	if(lua_gettop(L) < 2) {
		lua_pushstring(L,"Invalid Number Of Arguments For \"SetClientInfo\".");
		lua_error(L);
	}

	luaentity = lua_toentity(L,1);
	inf = lua_tonumber(L,2);
	if(luaentity != NULL && luaentity->client != NULL) {
		if (inf == PLAYERINFO_NAME) {
			luaL_checktype(L,3,LUA_TSTRING);
			strncpy(luaentity->client->pers.netname, lua_tostring(L,3), 36);
		} else if (inf == PLAYERINFO_HEALTH) {
			luaL_checktype(L,3,LUA_TNUMBER);
			luaentity->health = lua_tonumber(L,3);
			if(luaentity->health <= 0) {
				luaentity->health = luaentity->health - 1;
				//player_die(luaentity, NULL, NULL, -luaentity->health, MOD_CRUSH);
			}
			//trap_SendServerCommand( -1, va("playerhealth %i %i", luaentity->s.number, luaentity->health) );
		} else if (inf == PLAYERINFO_SCORE) {
			luaL_checktype(L,3,LUA_TNUMBER);
			luaentity->client->ps.persistant[PERS_SCORE] = lua_tonumber(L,3);
		} else {
			lua_pushfstring(L,"Invalid Argument For \"SetClientInfo\": %s.",inf);
			lua_error(L);
		}
	} else {
		lua_pushstring(L,"<CLIENT WAS NIL>");
	}
	return 1;
}

int qlua_isclient(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL && luaentity->client != NULL) {
		lua_pushboolean(L,1);
	} else {
		lua_pushboolean(L,0);
	}
	return 1;
}

int qlua_isbot(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL && luaentity->client != NULL) {
		if(luaentity->r.svFlags & SVF_BOT) {
			lua_pushboolean(L,1);
		} else {
			lua_pushboolean(L,0);
		}
	}
	return 1;
}

int qlua_setweapon(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	if(lua_gettop(L) == 2) {
		int weap = lua_tointeger(L,2);
		if(weap < 1 || weap > WP_NUM_WEAPONS-1) {
			lua_pushstring(L,"Invalid Argument For \"SetPlayerWeapon\"\n (out of range).\n");
			lua_error(L);
			return 1;
		}

		luaentity = lua_toentity(L,1);
		if(luaentity != NULL && luaentity->client != NULL) {
			int actuallweap = luaentity->client->ps.weapon;
			if((luaentity->client->ps.stats[STAT_WEAPONS] & (1 << weap)) && (luaentity->client->ps.ammo[weap] || actuallweap == WP_GAUNTLET)) {
				luaentity->client->ps.weapon = weap;
				luaentity->client->ps.weaponstate = WEAPON_READY;
			} else {
				lua_pushstring(L,"Invalid Argument For \"SetPlayerWeapon\"\n (client does not have that weapon or weapon has no ammo).\n");
				lua_error(L);
				return 1;				
			}
		}
	} else {
		lua_pushstring(L,"Invalid Number Of Arguments.\n");
		lua_error(L);
		return 1;
	}
	return 0;
}

int qlua_hasweapon(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	if(lua_gettop(L) == 2) {
		int weap = lua_tointeger(L,2);
		if(weap < 1 || weap > WP_NUM_WEAPONS-1) {
			lua_pushstring(L,"Invalid Argument For \"HasWeapon\"\n (out of range).\n");
			lua_error(L);
			return 1;
		}

		luaentity = lua_toentity(L,1);
		if(luaentity != NULL && luaentity->client != NULL) {
			if((luaentity->client->ps.stats[STAT_WEAPONS] & (1 << weap))) {
				lua_pushboolean(L,qtrue);
			} else {
				lua_pushboolean(L,qfalse);
			}
			return 1;
		}
	} else {
		lua_pushstring(L,"Invalid Number Of Arguments.\n");
		lua_error(L);
		return 1;
	}
	return 0;
}

int qlua_hasammo(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	if(lua_gettop(L) == 2) {
		int weap = lua_tointeger(L,2);
		if(weap < 1 || weap > WP_NUM_WEAPONS-1) {
			lua_pushstring(L,"Invalid Argument For \"HasAmmo\"\n (out of range).\n");
			lua_error(L);
			return 1;
		}

		luaentity = lua_toentity(L,1);
		if(luaentity != NULL && luaentity->client != NULL) {
			if((luaentity->client->ps.stats[STAT_WEAPONS] & (1 << weap)) && (luaentity->client->ps.ammo[weap])) {
				lua_pushboolean(L,qtrue);
			} else {
				lua_pushboolean(L,qfalse);
			}
			return 1;
		}
	} else {
		lua_pushstring(L,"Invalid Number Of Arguments.\n");
		lua_error(L);
		return 1;
	}
	return 0;
}


int qlua_giveweapon(lua_State *L) {
	gentity_t	*luaentity;
	int		i;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	if(lua_gettop(L) == 2) {
		int weap = lua_tointeger(L,2);
		if(weap < 1 || weap > WP_NUM_WEAPONS-1) {
			lua_pushstring(L,"Invalid Argument For \"GiveWeapon\"\n (out of range).\n");
			lua_error(L);
			return 1;
		}

		luaentity = lua_toentity(L,1);
		if(luaentity != NULL && luaentity->client != NULL) {
			luaentity->client->ps.stats[STAT_WEAPONS] |= ( 1 << weap );
			if(luaentity->client->ps.ammo[weap] == 0) {
				for ( i = 0 ; i < bg_numItems ; i++ ) {
					if ( bg_itemlist[i].giTag == weap ) {
						luaentity->client->ps.ammo[weap] = bg_itemlist[i].quantity;
					}
				}
			} else {
				if(luaentity->client->ps.ammo[weap] < 999) {
					luaentity->client->ps.ammo[weap] = luaentity->client->ps.ammo[weap] + 1;
				}
			}
			if(luaentity->client->ps.ammo[weap] < 1) {
				luaentity->client->ps.ammo[weap] = 1;
			}
		}
	} else {
		lua_pushstring(L,"Invalid Number Of Arguments.\n");
		lua_error(L);
		return 1;
	}
	return 0;
}

int qlua_removeweapons(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL && luaentity->client != NULL) {
		luaentity->client->ps.stats[STAT_WEAPONS] = (1 << WP_NONE);
		luaentity->client->ps.ammo[WP_NONE] = 0;
		luaentity->client->ps.weapon = WP_NONE;
		luaentity->client->ps.weaponstate = WEAPON_READY;
	}
	return 1;
}

int qlua_removepowerups(lua_State *L) {
	gentity_t	*luaentity;
	int i=0;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL && luaentity->client != NULL) {
		for ( i = 0 ; i < MAX_POWERUPS ; i++ ) {
			luaentity->client->ps.powerups[ i ] = 0;
		}
	}
	return 1;
}

int qlua_setpowerup(lua_State *L) {
	gentity_t	*luaentity;
	int pw = PW_NONE;
	int time = 0;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checkint(L,2);
	luaL_checkint(L,3);

	pw = lua_tointeger(L,2);
	time = lua_tointeger(L,3);

	if(pw < PW_NONE || pw > PW_BLUEFLAG) {
		lua_pushstring(L,"Invalid Argument For \"SetPowerup\"\n (out of range).\n");
		lua_error(L);
		return 1;
	}

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL && luaentity->client != NULL) {
		luaentity->client->ps.powerups[pw] = level.time + time;
		if(time <= 0) {
			luaentity->client->ps.powerups[pw] = 0;
		}
	}
	return 1;
}

int qlua_setspeed(lua_State *L) {
	gentity_t	*luaentity;
	float spd = 0;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checknumber(L,2);

	spd = lua_tonumber(L,2);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL && luaentity->client != NULL && spd >= 0) {
		luaentity->client->ps.speed = g_speed.value * spd;
	}
	return 0;
}


int qlua_setammo(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);
	luaL_checktype(L,3,LUA_TNUMBER);

	if(lua_gettop(L) == 3) {
		int weap = lua_tointeger(L,2);
		int ammo = lua_tointeger(L,3);
		if(weap < 1 || weap > WP_NUM_WEAPONS-1) {
			lua_pushstring(L,"Invalid Argument For \"SetAmmo\"\n (out of range).\n");
			lua_error(L);
			return 1;
		}

		luaentity = lua_toentity(L,1);
		if(luaentity != NULL && luaentity->client != NULL) {
			if(ammo >= -1 && ammo <= 999) {
				luaentity->client->ps.ammo[weap] = ammo;
			}
		}
	} else {
		lua_pushstring(L,"Invalid Number Of Arguments.\n");
		lua_error(L);
		return 1;
	}
	return 0;
}

int qlua_getammo(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	if(lua_gettop(L) == 2) {
		int weap = lua_tointeger(L,2);
		if(weap < 1 || weap > WP_NUM_WEAPONS-1) {
			lua_pushstring(L,"Invalid Argument For \"GetAmmo\"\n (out of range).\n");
			lua_error(L);
			return 1;
		}

		luaentity = lua_toentity(L,1);
		if(luaentity != NULL && luaentity->client != NULL) {
			lua_pushinteger(L,luaentity->client->ps.ammo[weap]);
			return 1;
		}
	} else {
		lua_pushstring(L,"Invalid Number Of Arguments.\n");
		lua_error(L);
		return 1;
	}
	return 0;
}

int qlua_getclass(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushstring(L,luaentity->classname);
	} else {
		lua_pushstring(L,"<INVALID ENTITY>");
	}
	return 1;
}

int qlua_getpos(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(luaentity->client) {
			lua_pushvector(L,luaentity->client->ps.origin);
		} else {
			lua_pushvector(L,luaentity->r.currentOrigin);
		}
		return 1;
	}
	return 0;
}

int qlua_setpos(lua_State *L) {
	gentity_t	*luaentity;
	vec3_t		origin;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TVECTOR);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(luaentity->client) {
			lua_tovector(L,2,luaentity->client->ps.origin);
		} else {
			BG_EvaluateTrajectory( &luaentity->s.pos, level.time, origin );
			lua_tovector(L,2,luaentity->s.pos.trBase);
			luaentity->s.pos.trDuration += (level.time - luaentity->s.pos.trTime);
			luaentity->s.pos.trTime = level.time;
			VectorCopy(luaentity->s.pos.trBase, luaentity->r.currentOrigin);
		}
		return 1;
	}
	return 0;
}

int qlua_getangles(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushvector(L,luaentity->s.angles);
		return 1;
	}
	return 0;
}

int qlua_setangles(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TVECTOR);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_tovector(L,2,luaentity->s.angles);
		return 1;
	}
	return 0;
}

int qlua_getmuzzlepos(lua_State *L) {
	vec3_t forward,right,up,muzzle;

	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(luaentity->client) {
			AngleVectors (luaentity->client->ps.viewangles, forward, right, up);
			CalcMuzzlePointOrigin ( luaentity, luaentity->client->oldOrigin, forward, right, up, muzzle );
			lua_pushvector(L,muzzle);
		}
		return 1;
	}
	return 0;
}

int qlua_getvel(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(luaentity->client) {
			lua_pushvector(L,luaentity->client->ps.velocity);
		} else {
			lua_pushvector(L,luaentity->s.pos.trDelta);
		}
		return 1;
	}
	return 0;
}

int qlua_setvel(lua_State *L) {
	gentity_t	*luaentity;
	vec3_t	origin;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TVECTOR);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(luaentity->client) {
			lua_tovector(L,2,luaentity->client->ps.velocity);
		} else {
			BG_EvaluateTrajectory( &luaentity->s.pos, level.time, origin );
			VectorCopy(origin, luaentity->s.pos.trBase);
			luaentity->s.pos.trDuration += (level.time - luaentity->s.pos.trTime);
			luaentity->s.pos.trTime = level.time;
			lua_tovector(L,2,luaentity->s.pos.trDelta);
		}
		return 1;
	}
	return 0;
}



int qlua_aimvec(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(luaentity->client) {
			lua_pushvector(L,luaentity->client->ps.viewangles);
			return 1;
		}
	}
	return 0;
}

int qlua_getotherentity(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(luaentity->s.otherEntityNum != ENTITYNUM_MAX_NORMAL) {
			lua_pushentity(L,&g_entities[ luaentity->s.otherEntityNum ]);
			return 1;
		}
	}
	return 0;
}

int qlua_getotherentity2(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(luaentity->s.otherEntityNum2 != ENTITYNUM_MAX_NORMAL) {
			lua_pushentity(L,&g_entities[ luaentity->s.otherEntityNum2 ]);
			return 1;
		}
	}
	return 0;
}

int qlua_gettarget(lua_State *L) {
	gentity_t	*luaentity;
	gentity_t	*target;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(luaentity->target_ent) {
			lua_pushentity(L,luaentity->target_ent);
			return 1;
		} else if (luaentity->target) {
			target = G_PickTarget(luaentity->target);
			if(target) {
				lua_pushentity(L,target);
				return 1;
			}
		}
	}
	return 0;
}

int qlua_getallentities(lua_State *L) {
	int numEnts = sizeof(g_entities) / sizeof(g_entities[0]);
	int i=0;
	int n=0;
	gentity_t	*ent;

	lua_newtable(L);

	for (i = 0, ent = g_entities, n = 1;
			i < level.num_entities;
			i++, ent++) {
		if (ent->classname) {
			lua_pushnumber(L, n);
			lua_pushentity(L,ent);
			lua_rawset(L, -3);
			n++;
		}
	}

	return 1;
}

int qlua_getentitiesbyclass(lua_State *L) {
	int numEnts = sizeof(g_entities) / sizeof(g_entities[0]);
	int i=0;
	int n=0;
	const char *filter = "";

	gentity_t	*ent;

	if(lua_gettop(L) > 0) {
		filter = lua_tostring(L,1);
		lua_newtable(L);

		for (i = 0, ent = g_entities, n = 1;
				i < level.num_entities;
				i++, ent++) {
				if (ent->classname && strcmp(ent->classname, filter) == 0) {
					lua_pushnumber(L, n);
					lua_pushentity(L,ent);
					lua_rawset(L, -3);
					n++;
				}
		}
	}
	return 1;
}

int qlua_getallplayers(lua_State *L) {
	int numEnts = sizeof(g_entities) / sizeof(g_entities[0]);
	int i=0;
	int n=0;
	gentity_t	*ent;

	lua_newtable(L);

	for (i = 0, ent = g_entities, n = 1;
			i < level.num_entities;
			i++, ent++) {
			if (ent->classname && ent->client) {
			lua_pushnumber(L, n);
			lua_pushentity(L,ent);
			lua_rawset(L, -3);
			n++;
		}
	}

	return 1;
}


int qlua_removeentity(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL && luaentity->client == NULL) {
		G_FreeEntity(luaentity);
	}
	return 0;
}

int qlua_entityid(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->s.number);
	}
	return 1;
}

int qlua_getparent(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		if(luaentity->parent != NULL) {
			lua_pushentity(L,luaentity->parent);
		}
	}
	return 1;
}

int qlua_damageplayer(lua_State *L) {
	gentity_t	*targ = NULL;
	gentity_t	*inflictor = NULL;
	gentity_t	*attacker = NULL;
	int			damage = 0;
	int			df = 0;
	int			mod = 0;
	int			carg = 1;

	if(lua_gettop(L) > 0) {
		luaL_checktype(L,carg,LUA_TUSERDATA);
		if(lua_type(L,carg) == LUA_TUSERDATA) {targ = lua_toentity(L,carg); carg++;}
		if(lua_type(L,carg) == LUA_TNIL) carg++;

		if(lua_type(L,carg) == LUA_TUSERDATA) {inflictor = lua_toentity(L,carg); carg++;}
		if(lua_type(L,carg) == LUA_TNIL) carg++;
		
		if(lua_type(L,carg) == LUA_TUSERDATA) {attacker = lua_toentity(L,carg); carg++;}
		if(lua_type(L,carg) == LUA_TNIL) carg++;


		luaL_checkint(L,carg);
		damage = lua_tointeger(L,carg);

		if(lua_gettop(L) > carg) {
			mod = lua_tointeger(L,carg+1);
		}

		if ( mod >= 0 && mod <= MOD_MAX ) {
			G_Damage(targ,inflictor,attacker,NULL,NULL,damage,DAMAGE_THRU_LUA,mod);
		} else {
			lua_pushstring(L,"Invalid Argument For \"DamagePlayer\"\n (MOD out of range).\n");
			lua_error(L);
		}
	}
	return 0;
}

int qlua_sendtexttoplayer(lua_State *L) {
	gentity_t	*luaentity;
	const char *msg = "";
	int center = 0;
	int id = 0;

	luaL_checktype(L,1,LUA_TUSERDATA);

	if(lua_gettop(L) > 1) {
		luaentity = lua_toentity(L,1);
		msg = lua_tostring(L,2);
		center = lua_toboolean(L,3);
		if(msg && luaentity && luaentity->client) {
			id = luaentity->client->ps.clientNum;
			if(center == 1) {
				trap_SendServerCommand( id, va("cp \"%s\"", msg) );
			} else {
				trap_SendServerCommand( id, va("print \"%s\"",msg) );
			}
		}
	}
	return 0;
}

int qlua_addevent(lua_State *L) {
	gentity_t	*luaentity;
	int event = 0;
	int param = 0;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checkint(L,2);

	if(lua_gettop(L) > 1) {
		luaentity = lua_toentity(L,1);
		event = lua_tointeger(L,2);
		if(lua_gettop(L) >= 3) {
			luaL_checkint(L,3);
			param = lua_tointeger(L,3);
		}
		if(luaentity) {
			if(event >= EV_NONE && event <= EV_TAUNT_PATROL) {
				G_AddEvent(luaentity,event,param);
			}
		}
	}
	return 0;
}

int qlua_playsound(lua_State *L) {
	gentity_t	*luaentity;
	const char *file = "";
	char	buffer[MAX_QPATH];
	int index = 0;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TSTRING);

	if(lua_gettop(L) >= 2) {
		luaentity = lua_toentity(L,1);
		file = lua_tostring(L,2);
		if(luaentity) {
			if (!strstr( file, ".wav" )) {
				Com_sprintf (buffer, sizeof(buffer), "%s.wav", file );
			} else {
				Q_strncpyz( buffer, file, sizeof(buffer) );
			}

			index = G_SoundIndex(buffer);
			if(index) {
				G_AddEvent( luaentity, EV_GENERAL_SOUND, index );
			}
		}
	}
	return 0;
}

int qlua_setcallback(lua_State *L) {
	gentity_t	*ent;
	int	call;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);
	luaL_checktype(L,3,LUA_TFUNCTION);

	if(lua_gettop(L) >= 2) {
		ent = lua_toentity(L,1);
		call = lua_tointeger(L,2);
		if(ent) {
			switch(call) {
				case 0: ent->lua_blocked = qlua_storefunc(L,3,ent->lua_blocked); break;
				case 1: ent->lua_die = qlua_storefunc(L,3,ent->lua_die); break;
				case 2: ent->lua_pain = qlua_storefunc(L,3,ent->lua_pain); break;
				case 3: ent->lua_reached = qlua_storefunc(L,3,ent->lua_reached); break;
				case 4: ent->lua_think = qlua_storefunc(L,3,ent->lua_think); break;
				case 5: ent->lua_touch = qlua_storefunc(L,3,ent->lua_touch); break;
				case 6: ent->lua_use = qlua_storefunc(L,3,ent->lua_use); break;
			}		
		}
	}
	return 0;
}

static int qlua_setmaxhealth(lua_State *L) {
	gentity_t	*luaentity;
	int			val=0;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_toentity(L,1);
	val = lua_tointeger(L,2);
	if(luaentity != NULL && luaentity->client) {
		//luaentity->client->ps.luatest = val;
		//luaentity->client->ps.luatest2 = "Max Health:";
		//sprintf(luaentity->client->ps.luatest2,"Max-Health:");
		//Q_strncpyz(luaentity->client->ps.luatest2,"Max Health:",1024);
		//G_Printf("Sizeof String: %i\n",(sizeof(luaentity->client->ps.luatest2) / sizeof(luaentity->client->ps.luatest2[0]))*32);

		if(val <= 0 && luaentity->client->luamaxhealth != 0) {
			luaentity->client->ps.stats[STAT_MAX_HEALTH] = luaentity->client->pers.maxHealth;
			luaentity->client->luamaxhealth = 0;
		} else {
			luaentity->client->luamaxhealth = val;
		}
	}
	return 0;
}

static int qlua_getmaxhealth(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL && luaentity->client) {
		lua_pushinteger(L,luaentity->client->luamaxhealth);
		return 1;
	}
	return 0;
}

static int qlua_sendstring(lua_State *L) {
	gentity_t	*luaentity;
	const char	*str = "";

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TSTRING);

	luaentity = lua_toentity(L,1);
	str	= lua_tostring(L,2);
	if(luaentity != NULL && luaentity->client && str != NULL) {
		trap_SendServerCommand( luaentity->s.number, va("luamsg %s", str) );
	}
	return 0;
}

static int Entity_tostring (lua_State *L)
{
	gentity_t *e1 = lua_toentity(L,1);
	if(e1 != NULL) {
		lua_pushstring(L,e1->classname);
		return 1;
	}
	return 0;
}

static int Entity_equal (lua_State *L)
{
	gentity_t *e1 = lua_toentity(L,1);
	gentity_t *e2 = lua_toentity(L,2);
	if(e1 != NULL && e2 != NULL) {
		lua_pushboolean(L, (e1->s.number == e2->s.number));
	} else {
		lua_pushboolean(L, 0);
	}
  return 1;
}

static int Entity_table (lua_State *L) {
	//gentity_t *ent = lua_toentity(L,1);
	const char *in = lua_tostring(L,2);
	G_Printf("TableIn\n");
	if(in != NULL) {
		G_Printf("Getting: %s\n",in);
		lua_gettable(L,1);
		lua_pushstring(L,in);
		lua_rawget(L, -2);
		return 1;
	}
	return 0;
}

static int Entity_tableset (lua_State *L) {
	gentity_t *ent = lua_toentity(L,1);
	const char *in = lua_tostring(L,2);
	if(ent != NULL) {
		if(qlua_getstored(L,ent->lua_persistanttable)) {
			if(in != NULL) {
				lua_pushstring(L,in);
				lua_pushvalue(L,3);
				lua_rawset(L, -3);
			}
			return 1;
		}
	}
	return 0;
}

int lua_setclipmask(lua_State *L) {
	gentity_t	*luaentity;
	int mask = 0;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_toentity(L,1);
	mask	= lua_tonumber(L,2);
	if(luaentity != NULL) {
		luaentity->clipmask = mask;
	}
	return 0;
}

int lua_gettr(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->s.pos.trType);
		return 1;
	}
	return 0;
}

int lua_settr(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		luaentity->s.pos.trType = lua_tointeger(L,2);
	}
	return 0;
}

int lua_getnextthink(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->nextthink);
		return 1;
	}
	return 0;
}

int lua_setnextthink(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		luaentity->nextthink = lua_tointeger(L,2);
	}
	return 0;
}

int lua_gettrx(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushtrajectory(L,&luaentity->s.pos);
		return 1;
	}
	return 0;
}

int lua_settrx(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		luaentity->s.pos = *lua_totrajectory(L,2);
	}
	return 0;
}

int lua_getmins(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushvector(L,luaentity->r.mins);
		return 1;
	}
	return 0;
}

int lua_setmins(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TVECTOR);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_tovector(L,2,luaentity->r.mins);
	}
	return 0;
}

int lua_getmaxs(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushvector(L,luaentity->r.maxs);
		return 1;
	}
	return 0;
}

int lua_setmaxs(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TVECTOR);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_tovector(L,2,luaentity->r.maxs);
	}
	return 0;
}

int lua_settakedamage(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TBOOLEAN);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		luaentity->takedamage = lua_toboolean(L,2);
	}
	return 0;
}

int lua_setclip(lua_State *L) {
	gentity_t	*luaentity;
	int			mask = 0;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		mask = lua_tointeger(L,2);
		luaentity->clipmask = mask;
		luaentity->r.contents = mask;
	}
	return 0;
}

int lua_sethp(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		luaentity->health = lua_tointeger(L,2);
	}
	return 0;
}

int lua_gethp(lua_State *L) {
	gentity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_toentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->health);
		return 1;
	}
	return 0;
}

static const luaL_reg Entity_methods[] = {
  {"GetInfo",		qlua_getclientinfo},
  {"SetInfo",		qlua_setclientinfo},
  {"GetPos",		qlua_getpos},
  {"SetPos",		qlua_setpos},
  {"GetAngles",		qlua_getangles},
  {"SetAngles",		qlua_setangles},
  {"GetMuzzlePos",	qlua_getmuzzlepos},
  {"GetAimVector",		qlua_aimvec},
  {"GetVelocity",		qlua_getvel},
  {"SetVelocity",		qlua_setvel},
  {"GetOtherEntity",	qlua_getotherentity},
  {"GetOtherEntity2",	qlua_getotherentity},
  {"GetTarget",			qlua_gettarget},
  {"SetWeapon",		qlua_setweapon},
  {"GiveWeapon",	qlua_giveweapon},
  {"HasWeapon",		qlua_hasweapon},
  {"HasAmmo",		qlua_hasammo},
  {"SetAmmo",		qlua_setammo},
  {"GetAmmo",		qlua_getammo},
  {"SetPowerup",	qlua_setpowerup},
  {"GetMaxHealth",	qlua_getmaxhealth},
  {"SetMaxHealth",	qlua_setmaxhealth},
  {"RemoveWeapons", qlua_removeweapons},
  {"RemovePowerups",	qlua_removepowerups},
  {"Damage",		qlua_damageplayer},
  {"SendMessage",	qlua_sendtexttoplayer},
  {"IsPlayer",		qlua_isclient},
  {"IsBot",			qlua_isbot},
  {"Classname",		qlua_getclass},
  {"Remove",		qlua_removeentity},
  {"EntIndex",		qlua_entityid},
  {"AddEvent",		qlua_addevent},
  {"PlaySound",		qlua_playsound},
  {"GetParent",		qlua_getparent},
  {"SetCallback",	qlua_setcallback},
  {"SendString",	qlua_sendstring},
  {"SetSpeed",		qlua_setspeed},
  {"GetTable",		lua_getentitytable},
  {"SetClipMask",	lua_setclipmask},
  {"GetTrType",		lua_gettr},
  {"SetTrType",		lua_settr},
  {"GetNextThink",	lua_getnextthink},
  {"SetNextThink",	lua_setnextthink},
  {"GetTrajectory",	lua_gettrx},
  {"SetTrajectory", lua_settrx},
  {"GetMins",		lua_getmins},
  {"SetMins",		lua_setmins},
  {"GetMaxs",		lua_getmaxs},
  {"SetMaxs",		lua_setmaxs},
  {"SetTakeDamage",	lua_settakedamage},
  {"SetClip",		lua_setclip},
  {"SetHealth",		lua_sethp},
  {"GetHealth",		lua_gethp},
  {0,0}
};

static const luaL_reg Entity_meta[] = {
  {"__tostring", Entity_tostring},
  {"__eq", Entity_equal},
  {"__index", Entity_table},
  {"__newindex", Entity_tableset},
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

int qlua_createtentity (lua_State *L) {
	gentity_t	*tent;
	vec3_t	pos;
	int ev = 0;

	if(lua_gettop(L) >= 2) {
		luaL_checktype(L,1,LUA_TVECTOR);
		luaL_checktype(L,2,LUA_TNUMBER);

		lua_tovector(L,1,pos);
		ev = lua_tointeger(L,2);

		tent = G_TempEntity(pos,ev);

		if(tent != NULL) {
			lua_pushentity(L,tent);
			return 1;
		}
	}
			
	return 0;
}

int qlua_unlink(lua_State *L) {
	gentity_t *ent;
	luaL_checktype(L,1,LUA_TUSERDATA);

	ent = lua_toentity(L,1);
	if(ent != NULL) {
		qlua_UnlinkEntity(ent);
	}
	return 0;
}

int qlua_link(lua_State *L) {
	gentity_t *ent;
	luaL_checktype(L,1,LUA_TUSERDATA);

	ent = lua_toentity(L,1);
	if(ent != NULL) {
		qlua_LinkEntity(ent);
	}
	return 0;
}

int qlua_createEntity(lua_State *L) {
	gentity_t	*ent;
	const char	*classname;

	luaL_checktype(L,1,LUA_TSTRING);
	classname = lua_tostring(L,1);
	if(classname) {
		if(strlen(classname) > 200) {
			lua_pushstring(L,"Classname Too Long!\n");
			lua_error(L);
			return 1;
		}
		ent = G_Spawn();
		ent->client = NULL;
		ent->touch = 0;
		ent->pain = 0;
		ent->die = 0;
		ent->think = 0;
		ent->s.eType = ET_LUA;
		ent->r.svFlags = SVF_BROADCAST;
		ent->s.weapon = WP_NONE;
		ent->clipmask = MASK_SHOT;
		ent->target_ent = NULL;
		ent->s.pos.trType = TR_GRAVITY;
		ent->s.pos.trTime = level.time;
		strcpy(ent->s.luaname, classname);
		ent->classname = "luaentity";
		VectorCopy(ent->s.pos.trBase,ent->s.origin2); 
		qlua_LinkEntity(ent);
		//strcpy(ent->classname, classname);
		lua_pushentity(L,ent);
		return 1;
	}
	return 0;

	/*bolt->s.eType = ET_MISSILE;
	bolt->r.svFlags = SVF_USE_CURRENT_ORIGIN;
	bolt->s.weapon = WP_GRENADE_LAUNCHER;
	bolt->s.eFlags = EF_BOUNCE_HALF;
	bolt->r.ownerNum = self->s.number;
	bolt->parent = self;
	bolt->damage = 100;
	bolt->splashDamage = 100;
	bolt->splashRadius = 150;
	bolt->methodOfDeath = MOD_GRENADE;
	bolt->splashMethodOfDeath = MOD_GRENADE_SPLASH;
	bolt->clipmask = MASK_SHOT;
	bolt->target_ent = NULL;

	bolt->s.pos.trType = TR_GRAVITY;
	bolt->s.pos.trTime = level.time - MISSILE_PRESTEP_TIME;		// move a bit on the very first frame
	VectorCopy( start, bolt->s.pos.trBase );
	VectorScale( dir, 700, bolt->s.pos.trDelta );
	SnapVector( bolt->s.pos.trDelta );			// save net bandwidth

	VectorCopy (start, bolt->r.currentOrigin);

	return bolt;*/
}

void G_InitLuaEnts(lua_State *L) {
	Entity_register(L);
	lua_register(L,"CreateTempEntity",qlua_createtentity);
	//lua_register(L,"GetEntitiesByClass",qlua_getentitiesbyclass);
	//lua_register(L,"GetAllPlayers",qlua_getallplayers);
	lua_register(L,"UnlinkEntity",qlua_unlink);
	lua_register(L,"LinkEntity",qlua_link);
	lua_register(L,"CreateEntity",qlua_createEntity);
}