#include "cg_gui.h"

int xmouse = 0;
int ymouse = 0;
qboolean mouseon = qfalse;
qboolean mouse_right = qfalse;
qboolean mouse_left = qfalse;

int nextPanelID = 0;
panel_t	*base_panel;

void create_base() {
	base_panel = malloc(sizeof(panel_t));
	memset(base_panel,0,sizeof(panel_t));
	base_panel->x = 0;
	base_panel->y = 0;
	base_panel->w = 640;//cgs.glconfig.vidWidth;
	base_panel->h = 480;//cgs.glconfig.vidHeight;
	strcpy(base_panel->classname,"base");
	base_panel->enabled = qtrue;
	base_panel->visible = qtrue;
}

panel_t *get_base() {
	return base_panel;
}

qboolean gui_getpanelfunc(lua_State *L, panel_t* panel, char* f) {
	qlua_getstored(L,panel->lua_table);
	lua_pushstring(L,f);
	lua_gettable(L,-2);
	
	if(lua_type(L,lua_gettop(L)) == LUA_TNIL) return qfalse;
	
	lua_pushpanel(L,panel);
	return qtrue;
}

int gui_panel_create(lua_State *L) {
	const char	*classname = lua_tostring(L,1);
	panel_t	*parent = NULL;
	panel_t	*panel = malloc(sizeof(panel_t));
	int chsize = 0;

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

	//chsize = (sizeof(parent->children) / sizeof(panel_t));
	if(parent->num_panels+1 > PANEL_ARRAY_SIZE) {
		//realloc(parent->children,sizeof(panel_t) * (chsize*2));
		//CG_Printf("ReAlloc'd: %i -> %i\n",chsize,chsize*2);
		return 0;
	}
	parent->num_panels++;

	parent->children[parent->num_panels-1] = panel;
	panel->depth = parent->num_panels-1;
	panel->persistantID = ++nextPanelID;
	panel->visible = qtrue;
	panel->enabled = qtrue;
	//panel->classname = (char*) classname;
	strcpy(panel->classname, (char*)classname);

	panel->parent = parent;
	panel->fgcolor[0] = 1;
	panel->fgcolor[1] = 1;
	panel->fgcolor[2] = 1;
	panel->fgcolor[3] = 1;

	panel->bgcolor[0] = 0;
	panel->bgcolor[1] = 0;
	panel->bgcolor[2] = 0;
	panel->bgcolor[3] = .5f;

	lua_newtable(L);
	panel->lua_table = qlua_storefunc(L,lua_gettop(L),0);

	qlua_gethook(L,"PanelCreated");
	lua_pushpanel(L,panel);
	qlua_pcall(L,1,0,qtrue);

	lua_pushpanel(L,panel);

	return 1;
}

void UI_GetLocalPosition(panel_t *panel, vec3_t vec) {
	vec3_t parentPos;
	if(panel->parent) {
		UI_GetLocalPosition(panel->parent, parentPos);
		vec[0] = panel->x + parentPos[0];
		vec[1] = panel->y + parentPos[1];
	} else {
		vec[0] = panel->x;
		vec[1] = panel->y;
	}
}

qboolean UI_InsidePanel(panel_t *panel, float x, float y) {
	float w = panel->w;
	float h = panel->h;
	vec3_t pos;
	UI_GetLocalPosition(panel,pos);

	//CG_Printf("%f,%f\n",pos[0],pos[1]);

	if(x < pos[0] || x > (pos[0] + w)) return qfalse;
	if(y < pos[1] || y > (pos[1] + h)) return qfalse;

	//CG_Printf("InsidePanelTest!\n");

	return qtrue;
}

void UI_RemovePanel(panel_t *panel) {
	panel_t *parent = panel->parent;
	panel_t *temp[PANEL_ARRAY_SIZE];
	int pi = panel->depth;
	int i;

	if(panel == NULL) return;

	//free(panel->children);

	if(parent == NULL) {
		CG_Printf("^1Unable to remove panel %s[%i], bad parent\n", panel->classname, panel->persistantID);
		return;
	}
	panel->removed = qtrue;

	parent->children[pi] = NULL;
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

int gui_mouse_enable(lua_State *L) {
	mouseon = lua_toboolean(L,1);
	trap_LockMouse(mouseon);
	return 0;
}

int gui_mouse_enabled(lua_State *L) {
	lua_pushboolean(L,mouseon);
	return 1;
}

int gui_mouse_getpos(lua_State *L) {
	lua_pushinteger(L,xmouse);
	lua_pushinteger(L,ymouse);
	return 1;
}

static const luaL_reg Gui_methods[] = {
  {"CreatePanel",	gui_panel_create},
  {"RemovePanel",	gui_panel_remove},
  {"EnableMouse",	gui_mouse_enable},
  {"MouseEnabled",	gui_mouse_enabled},
  {"GetMousePos",	gui_mouse_getpos},
  {0,0}
};

void draw_panel(lua_State *L, panel_t *panel) {
	if(gui_getpanelfunc(L,panel,"Draw")) {
		qlua_pcall(L,0,0,qtrue);
	}
}

void layout_panel(lua_State *L, panel_t *panel) {
	//CG_Printf("LayoutPanel %s\n", panel->classname);
	if(gui_getpanelfunc(L,panel,"Think")) {
		qlua_pcall(L,0,0,qtrue);
	}
	if(gui_getpanelfunc(L,panel,"DoLayout")) {
		qlua_pcall(L,0,0,qtrue);
	}
}

void recursive_panel_reverse(lua_State *L, panel_t *panel) {
	int i;
	panel_t *current;
	if(panel->num_panels > 0) {
		//CG_Printf("[%s]Recurse %i panels\n",panel->classname,panel->num_panels);
		for(i=panel->num_panels; i>0; i--) {
			current = panel->children[i-1];
			if(current != NULL && current->visible) {
				if(current->num_panels > 0) {
					recursive_panel_reverse(L, current);
				}
				layout_panel(L, current);
			}
		}
	}
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

qboolean gui_mouse_quickcall(lua_State *L, panel_t *panel, char *inside, char *outside, int x, int y, int param) {
	if(UI_InsidePanel(panel,x,y)) {
		if(inside != NULL) {
			if(gui_getpanelfunc(L,panel,inside)) {
				lua_pushinteger(L,x);
				lua_pushinteger(L,y);
				lua_pushinteger(L,param);
				qlua_pcall(L,3,1,qtrue);
				if(lua_type(L,-1) != LUA_TBOOLEAN || lua_toboolean(L,-1) == qfalse) {
					return qtrue;
				}
			} else {
				return qtrue;
			}
		}
	} else {
		if(outside != NULL) {
			if(gui_getpanelfunc(L,panel,outside)) {
				lua_pushinteger(L,x);
				lua_pushinteger(L,y);
				lua_pushinteger(L,param);
				qlua_pcall(L,3,0,qtrue);
			}
		}
	}
	return qfalse;
}

qboolean gui_mouse_event_recursive(lua_State *L, panel_t *panel, int ev, int x, int y, int param, int pass) {
	int i;
	panel_t *current;
	if(panel->num_panels > 0) {
		for(i=panel->num_panels; i>0; i--) {
			current = panel->children[i-1];
			if(current != NULL && current->visible) {
				if(current->num_panels > 0) {
					if(gui_mouse_event_recursive(L, current, ev, x, y, param, pass)) {
						return qtrue;
					}
				}
				switch(ev) {
					case UIM_PRESS:
						if(UI_InsidePanel(current,x,y)) {
							current->mousedown = qtrue;
						}
						if(gui_mouse_quickcall(L,current,"MousePressed",NULL,x,y,param) && pass == 1) return qtrue;
						if(gui_mouse_quickcall(L,current,NULL,"MousePressedOutside",x,y,param) && pass == 2);
					break;
					case UIM_RELEASE:
						current->mousedown = qfalse;
						if(gui_mouse_quickcall(L,current,"MouseReleased",NULL,x,y,param) && pass == 1) return qtrue;
						if(gui_mouse_quickcall(L,current,NULL,"MouseReleasedOutside",x,y,param) && pass == 2);
					break;
					case UIM_MOVE:
						if(UI_InsidePanel(current,x,y)) {
							if(!current->mouseover && pass == 1) {
								current->mouseover = qtrue;
								CG_Printf("Mouse Enter Panel!\n");
								if(gui_mouse_quickcall(L,current,"MouseEnter",NULL,x,y,param)) {
									CG_Printf("^3Break!\n");
									return qtrue;
								}
							}
						} else {
							if(current->mouseover && pass == 2) {
								current->mouseover = qfalse;
								CG_Printf("Mouse Exit Panel!\n");
								gui_mouse_quickcall(L,current,NULL,"MouseExit",x,y,param);
							}
						}
					break;
				}
			}
		}
	}
	return qfalse;
}

qboolean gui_mouse_event(lua_State *L, panel_t *panel, int ev, int x, int y, int param, qboolean bleh) {
	qboolean ret = qfalse;

	if(gui_mouse_event_recursive(L,panel,ev,x,y,param,1)) ret = qtrue;
	if(gui_mouse_event_recursive(L,panel,ev,x,y,param,2)) ret = qtrue;
	return ret;
} 

qboolean CG_MouseGui(lua_State *L, int x, int y) {
	if(mouseon) {
		xmouse += x;
		ymouse += y;

		gui_mouse_event(L,base_panel,UIM_MOVE,xmouse,ymouse,0,qtrue);

		if(xmouse < 0) xmouse = 0;
		if(ymouse < 0) ymouse = 0;
		if(xmouse > 640) xmouse = 640;
		if(ymouse > 480) ymouse = 480;
		return qtrue;
	}
	return qfalse;
}

qboolean CG_KeyGui(lua_State *L, int key, qboolean down) {
	if(mouseon) {
		if(key == 178) {
			if(down) {
				if(!mouse_left) {
					mouse_left = qtrue;
					gui_mouse_event(L,base_panel,UIM_PRESS,xmouse,ymouse,0,qfalse);
				}
			} else {
				if(mouse_left) {
					mouse_left = qfalse;
					gui_mouse_event(L,base_panel,UIM_RELEASE,xmouse,ymouse,0,qfalse);
				}
			}
			return qtrue;
		}

		if(key == 179) {
			if(down) {
				if(!mouse_right) {
					mouse_right = qtrue;
				}
			} else {
				if(mouse_right) {
					mouse_right = qfalse;
				}
			}
			return qtrue;
		}
	}
	return qfalse;
}

void CG_RunGui(lua_State *L) {
	if(base_panel != NULL) {
		//CG_Printf("Layout Pass!\n");
		recursive_panel_reverse(L, base_panel);
		recursive_panel(L, base_panel);
	}
	if(mouseon) {
		qlua_gethook(L,"DrawCursor");
		lua_pushinteger(L,xmouse);
		lua_pushinteger(L,ymouse);
		qlua_pcall(L,2,0,qtrue);
	}
}

void CG_InitLuaGui(lua_State *L) {
	luaL_openlib(L, "gui", Gui_methods, 0);
	Panel_register(L);
	create_base();
}