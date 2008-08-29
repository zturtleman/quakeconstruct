#include "cg_local.h"

void setTableInt(lua_State *L, char *str, int v) {
	lua_pushstring(L, str);
	lua_pushinteger(L,v);
	lua_rawset(L, -3);
}

void setTableFloat(lua_State *L, char *str, float v) {
	lua_pushstring(L, str);
	lua_pushnumber(L,v);
	lua_rawset(L, -3);
}

void setTableVector(lua_State *L, char *str, vec3_t v) {
	lua_pushstring(L, str);
	lua_pushvector(L, v);
	lua_rawset(L, -3);
}

void setTableString(lua_State *L, char *str, char *v) {
	lua_pushstring(L, str);
	lua_pushstring(L, v);
	lua_rawset(L, -3);
}

void setTableBoolean(lua_State *L, char *str, qboolean v) {
	lua_pushstring(L, str);
	lua_pushboolean(L, v);
	lua_rawset(L, -3);
}

void setTableTable(lua_State *L, char *str, int tab[], int size) {
	int i;
	int tabid;

	lua_pushstring(L, str);
	lua_createtable(L,size,0);
	tabid = lua_gettop(L);

	for(i=0;i<size;i++) {
		lua_pushinteger(L,i+1);
		lua_pushinteger(L,tab[i]);
		lua_settable(L, tabid);
	}
	lua_rawset(L, -3);
}

void getTableVector(lua_State *L, char *str, vec3_t v) {
	lua_pushstring(L, str);
	lua_gettable(L, -2);
	lua_tovector(L, -1, v);
}

void CG_ApplyCGTab(lua_State *L) {
	lua_getglobal(L, "_CG");

	getTableVector(L,"viewOrigin",cg.refdef.vieworg);
}

void CG_PushCGTab(lua_State *L) {
	lua_newtable(L);

	setTableFloat(L,"damageTime",cg.damageTime);
	setTableFloat(L,"damageValue",cg.damageValue);
	setTableFloat(L,"damageX",cg.damageX);
	setTableFloat(L,"damageY",cg.damageY);
	setTableVector(L,"viewAngle",cg.refdef.viewaxis[0]);
	setTableVector(L,"viewOrigin",cg.refdef.vieworg);
	setTableFloat(L,"fov_x",cg.refdef.fov_x);
	setTableFloat(L,"fov_y",cg.refdef.fov_y);
	setTableInt(L,"itemPickup", cg.itemPickup);
	setTableInt(L,"itemPickupTime", cg.itemPickupTime);

	if(cg.snap != NULL) {
		setTableInt(L,"weapon", cg.snap->ps.weapon);

		setTableTable(L,"stats", cg.snap->ps.stats, STAT_MAX_HEALTH+1);
		setTableTable(L,"pers", cg.snap->ps.persistant, PERS_CAPTURES+1);
		setTableTable(L,"ammo", cg.snap->ps.ammo, WP_NUM_WEAPONS);
	}
	lua_setglobal(L,"_CG");
}

void CG_PushClientInfoTab(lua_State *L, clientInfo_t *ci) {
	if(ci != NULL) {
		lua_newtable(L);

		setTableString(L,"name",ci->name);
		setTableInt(L,"health",ci->health);
		setTableInt(L,"armor",ci->armor);
		setTableInt(L,"ammo",ci->ammo);
		setTableInt(L,"score",ci->score);
		setTableBoolean(L,"connected",qtrue);
		setTableInt(L,"weapon",ci->curWeapon);
		setTableInt(L,"buttons",0);
		setTableString(L,"modelName",ci->modelName);
		setTableInt(L,"modelIcon",ci->modelIcon);
		setTableString(L,"skinName",ci->skinName);
		setTableInt(L,"gender",ci->gender);
		setTableInt(L,"handicap",ci->handicap);
		setTableInt(L,"legsModel",ci->legsModel);
		setTableInt(L,"headModel",ci->headModel);
		setTableInt(L,"torsoModel",ci->torsoModel);
		setTableInt(L,"legsSkin",ci->legsSkin);
		setTableInt(L,"headSkin",ci->headSkin);
		setTableInt(L,"torsoSkin",ci->torsoSkin);
	} else {
		lua_pushstring(L,"<CLIENT WAS NIL>");
		lua_error(L);
	}
}

/*cg.refdef.*/