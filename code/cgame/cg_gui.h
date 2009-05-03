#include "cg_local.h"

#define	PANEL_ARRAY_SIZE 256

typedef struct panel_s {
	struct panel_s		*parent;
	struct panel_s		*children[PANEL_ARRAY_SIZE];
	int			num_panels;

	float		x,y,w,h;
	int			depth;
	int			persistantID;
	const char	*classname;

	/*int			lua_draw;
	int			lua_think;*/
	
	qboolean	visible;
	qboolean	enabled;
	qboolean	removed;
	qboolean	noGC;
} panel_t;

panel_t *get_base();
void lua_pushpanel(lua_State *L, panel_t *panel);
panel_t *lua_topanel(lua_State *L, int i);
int Panel_register (lua_State *L);
void UI_RemovePanel(panel_t *panel);