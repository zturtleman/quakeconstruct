#include "cg_gui.h"

int nextPanelID = 0;
panel_t	*base_panel;

void create_base() {
	base_panel = malloc(sizeof(panel_t));
	memset(base_panel,0,sizeof(panel_t));
	base_panel->x = 0;
	base_panel->y = 0;
	base_panel->w = 640;//cgs.glconfig.vidWidth;
	base_panel->h = 480;//cgs.glconfig.vidHeight;
	base_panel->classname = "base";
	base_panel->enabled = qtrue;
	base_panel->visible = qtrue;
}

panel_t *get_base() {
	return base_panel;
}

int gui_panel_create(lua_State *L) {
	const char	*classname = lua_tostring(L,1);
	panel_t	*parent = NULL;
	panel_t	*panel = malloc(sizeof(panel_t));
	
	if(lua_type(L,2) == LUA_TUSERDATA) {
		parent = lua_topanel(L,2);
	}

	if(classname == NULL) {
		lua_pushstring(L,"Error: bad classname.\n");
		lua_error(L);
		return 0;
	}
	if(!strcmp(classname,"base")) {
		lua_pushstring(L,"Error: can't use classname 'base'.\n");
		lua_error(L);
		return 0;
	}
	if(parent == NULL) parent = base_panel;

	memset(panel,0,sizeof(panel_t));
	//realloc(active_panels, (num_panels+1) * sizeof(panel_t));

	if(parent->num_panels+1 > PANEL_ARRAY_SIZE) {
		return 0;
	}
	parent->num_panels++;

	parent->children[parent->num_panels-1] = panel;
	panel->depth = parent->num_panels-1;
	panel->persistantID = ++nextPanelID;
	panel->visible = qtrue;
	panel->enabled = qtrue;
	panel->classname = classname;
	panel->parent = parent;

	lua_pushpanel(L,panel);

	return 1;
}

void UI_RemovePanel(panel_t *panel) {
	panel_t *parent = panel->parent;
	panel_t *temp[PANEL_ARRAY_SIZE];
	int pi = panel->depth;
	int i;

	if(panel == NULL) return;
	if(parent == NULL) {
		CG_Printf("^1Unable to remove panel %s[%i], bad parent\n", panel->classname, panel->persistantID);
		return;
	}
	panel->removed = qtrue;

	for(i=pi; i<parent->num_panels-1; i++) {
		temp[i] = parent->children[i+1];
	}

	for(i=pi; i<parent->num_panels; i++) {
		if(temp[i] != NULL) parent->children[i] = temp[i];
	}
	parent->num_panels--;
}

int gui_panel_remove(lua_State *L) {
	UI_RemovePanel(lua_topanel(L,1));
	return 0;
}

int gui_panel_focus(lua_State *L) {
	return 0;
}

int gui_panel_get(lua_State *L) {
	return 1;
}

static const luaL_reg Gui_methods[] = {
  {"CreatePanel",	gui_panel_create},
  {"RemovePanel",	gui_panel_remove},
  {0,0}
};

void draw_panel(lua_State *L, panel_t *panel) {
	panel->noGC = qtrue;
	qlua_gethook(L,"DrawPanel");
	lua_pushpanel(L,panel);
	qlua_pcall(L,1,0,qtrue);
	panel->noGC = qfalse;
}

void recursive_panel(lua_State *L, panel_t *panel) {
	int i;
	panel_t *current;
	if(panel->num_panels > 0) {
		for(i=0; i<panel->num_panels; i++) {
			current = panel->children[i];
			if(current != NULL && current->visible) {
				draw_panel(L, current);
				if(current->num_panels > 0) {
					recursive_panel(L, current);
				}
			}
		}
	}
}

void CG_RunGui(lua_State *L) {
	if(base_panel != NULL) {
		draw_panel(L, base_panel);
		recursive_panel(L, base_panel);
	}
}

void CG_InitLuaGui(lua_State *L) {
	luaL_openlib(L, "gui", Gui_methods, 0);
	Panel_register(L);
	create_base();
}