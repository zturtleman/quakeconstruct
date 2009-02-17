#include "cg_local.h"

void setTableRefDef(lua_State *L, char *str, refdef_t refdef) {
	int tabid;
	lua_pushstring(L, str);
	lua_createtable(L,8,0);
	tabid = lua_gettop(L);
	
	setTableFloat(L,"x",refdef.x);
	setTableFloat(L,"y",refdef.y);
	setTableFloat(L,"width",refdef.width);
	setTableFloat(L,"height",refdef.height);
	setTableFloat(L,"fov_x",refdef.fov_x);
	setTableFloat(L,"fov_y",refdef.fov_y);
	setTableVector(L,"origin",refdef.vieworg);
	setTableVector(L,"angles",refdef.viewaxis[0]);

	setTableVector(L,"forward",refdef.viewaxis[0]);
	setTableVector(L,"right",refdef.viewaxis[1]);
	setTableVector(L,"up",refdef.viewaxis[2]);
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
	setTableRefDef(L,"refdef",cg.refdef);

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
		setTableInt(L,"team",ci->team);
	} else {
		lua_pushstring(L,"<CLIENT WAS NIL>");
		lua_error(L);
	}
}

/*cg.refdef.*/