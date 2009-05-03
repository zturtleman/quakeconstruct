#include "cg_gui.h"

void lua_pushpanel(lua_State *L, panel_t *panel) {
	panel_t *userdata = (panel_t*) lua_newuserdata(L, sizeof(panel_t));
	*userdata = *panel;

	luaL_getmetatable(L, "Panel");
	lua_setmetatable(L, -2);
}

panel_t *lua_topanel(lua_State *L, int i) {
	panel_t	*luapanel;
	luaL_checktype(L,i,LUA_TUSERDATA);
	luapanel = (panel_t *)luaL_checkudata(L, i, "Panel");;
	if (luapanel == NULL) luaL_typerror(L, i, "Panel");

	if (luapanel->parent != NULL) {
		return luapanel->parent->children[luapanel->depth];
	} else {
		return get_base();
	}
}

panel_t *lua_topanel_fake(lua_State *L, int i) {
	panel_t	*luapanel;
	luaL_checktype(L,i,LUA_TUSERDATA);
	luapanel = (panel_t *)luaL_checkudata(L, i, "Panel");;
	if (luapanel == NULL) luaL_typerror(L, i, "Panel");
	return luapanel;
}

static int Panel_remove(lua_State *L) {
	panel_t *panel = lua_topanel_fake(L,1);

	if(panel != NULL && strcmp(panel->classname,"base") && !panel->noGC) {
		UI_RemovePanel(panel);
		CG_Printf("Remove Panel: %s[%i]\n", panel->classname, panel->persistantID);
	}

	return 0;
}

static int Panel_tostring (lua_State *L)
{
  lua_pushfstring(L, "Panel: %p", lua_touserdata(L, 1));
  return 1;
}

static int Panel_equal (lua_State *L)
{
	panel_t *p1 = lua_topanel_fake(L,1);
	panel_t *p2 = lua_topanel_fake(L,2);
	if(p1 != NULL && p2 != NULL) {
		lua_pushboolean(L, (p1->persistantID == p2->persistantID));
	} else {
		lua_pushboolean(L, 0);
	}
  return 1;
}

int	pget_localpos(lua_State *L) {
	panel_t *panel = lua_topanel_fake(L,1);

	if(panel->parent == NULL) {
		lua_pushnumber(L,panel->x);
		lua_pushnumber(L,panel->y);

		return 2;
	}

	lua_pushnumber(L,panel->x + panel->parent->x);
	lua_pushnumber(L,panel->y + panel->parent->y);

	return 2;
}

int	pget_pos(lua_State *L) {
	panel_t *panel = lua_topanel_fake(L,1);

	lua_pushnumber(L,panel->x);
	lua_pushnumber(L,panel->y);

	return 2;
}

int	pset_pos(lua_State *L) {
	panel_t *panel = lua_topanel(L,1);

	luaL_checktype(L,2,LUA_TNUMBER);
	luaL_checktype(L,3,LUA_TNUMBER);

	panel->x = lua_tonumber(L,2);
	panel->y = lua_tonumber(L,3);

	return 0;
}

int	pget_size(lua_State *L) {
	panel_t *panel = lua_topanel_fake(L,1);

	lua_pushnumber(L,panel->w);
	lua_pushnumber(L,panel->h);

	return 2;
}

int	pset_size(lua_State *L) {
	panel_t *panel = lua_topanel(L,1);

	luaL_checktype(L,2,LUA_TNUMBER);
	luaL_checktype(L,3,LUA_TNUMBER);

	panel->w = lua_tonumber(L,2);
	panel->h = lua_tonumber(L,3);

	return 0;
}

int pget_parent(lua_State *L) {
	panel_t *panel = lua_topanel_fake(L,1);

	if(panel->parent != NULL) {
		lua_pushpanel(L,panel->parent);
		return 1;
	}

	return 0;
}

int pget_classname(lua_State *L) {
	panel_t *panel = lua_topanel_fake(L,1);

	if(panel->classname != NULL) {
		lua_pushstring(L,panel->classname);
		return 1;
	}

	return 0;
}

static const luaL_reg Panel_methods[] = {
  {"GetLocalPos",	pget_localpos},
  {"GetPos",		pget_pos},
  {"SetPos",		pset_pos},
  {"GetSize",		pget_size},
  {"SetSize",		pset_size},
  {"GetParent",		pget_parent},
  {"Classname",		pget_classname},
  {0,0}
};

static const luaL_reg Panel_meta[] = {
  {"__tostring", Panel_tostring},
  {"__eq", Panel_equal},
  {"__gc", Panel_remove},
  {0, 0}
};

int Panel_register (lua_State *L) {
	luaL_openlib(L, "Panel", Panel_methods, 0);

	luaL_newmetatable(L, "Panel");

	luaL_openlib(L, 0, Panel_meta, 0);
	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);

	lua_pop(L, 1);
	return 1;
}