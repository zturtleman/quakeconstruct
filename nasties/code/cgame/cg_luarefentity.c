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

int qlua_rpositionontag(lua_State *L) {
	refEntity_t	*ent;
	refEntity_t	*other;
	char *str;
	qboolean norot = qfalse;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TUSERDATA);
	luaL_checktype(L,3,LUA_TSTRING);

	ent = lua_torefentity(L,1);
	other = lua_torefentity(L,2);
	str = (char *)lua_tostring(L,3);

	if(lua_type(L,4) == LUA_TBOOLEAN) {
		norot = lua_toboolean(L,4);
	}

	if(norot) {
		CG_PositionEntityOnTag(ent,other,other->hModel,str);
	} else {
		CG_PositionRotatedEntityOnTag(ent,other,other->hModel,str);
	}
	return 0;
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
	vec3_t		origin,vlen;
	vec3_t		temp[256];
	int			size,i,size2;
	qboolean	isNew = qfalse;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TVECTOR);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_tovector(L,2,origin);

		if( origin[0] != luaentity->origin[0] ||
			origin[1] != luaentity->origin[1] ||
			origin[2] != luaentity->origin[2]) {
			isNew = qtrue;
		}

		VectorCopy( origin, luaentity->lightingOrigin );
		VectorCopy( origin, luaentity->origin );

		if(luaentity->reType == RT_TRAIL) {
			VectorSubtract(luaentity->trailVerts[0],luaentity->origin,vlen);
			luaentity->trailCoordBump -= VectorLength(vlen) / luaentity->trailCoordLength;

			size2 = sizeof(luaentity->trailVerts) / sizeof(luaentity->trailVerts[0]);
			if(luaentity->numVerts2 > size2) luaentity->numVerts2 = size2;
			if(luaentity->numVerts2 <= 1) luaentity->numVerts2 = 2;
			size = luaentity->numVerts2; //sizeof(luaentity->trailVerts) / sizeof(luaentity->trailVerts[0]);

			//Com_Printf("Shifted: %i verts\n",size);

			for(i=0; i<size; i++) {
				VectorCopy(luaentity->trailVerts[i],temp[i]);
			}

			for(i=1; i<size; i++) {
				VectorCopy(temp[i-1],luaentity->trailVerts[i]);
			}
			VectorCopy(luaentity->origin,luaentity->trailVerts[0]);
		}
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
	vec3_t	angles;
	vec3_t	angles2;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		vectoangles(luaentity->axis[0],angles);
		vectoangles(luaentity->axis[1],angles2);
		angles[2] = angles2[0];
		lua_pushvector(L,angles);
		return 1;
		//lua_pushvector(L,luaentity->axis[0]);
		//lua_pushvector(L,luaentity->axis[1]);
		//lua_pushvector(L,luaentity->axis[2]);
		//return 3;
	}
	return 0;
}

int qlua_rgetaxis(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushvector(L,luaentity->axis[0]);
		lua_pushvector(L,luaentity->axis[1]);
		lua_pushvector(L,luaentity->axis[2]);
		return 3;
	}
	return 0;
}

int qlua_rsetaxis(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TUSERDATA);
	luaL_checktype(L,3,LUA_TUSERDATA);
	luaL_checktype(L,4,LUA_TUSERDATA);

	if(IsVector(L,2) && IsVector(L,3) && IsVector(L,4)) {
		luaentity = lua_torefentity(L,1);
		if(luaentity != NULL) {
			lua_tovector(L,2,luaentity->axis[0]);
			lua_tovector(L,3,luaentity->axis[1]);
			lua_tovector(L,4,luaentity->axis[2]);
		}
	}
	return 0;
}

int qlua_rrotatearound(lua_State *L) {
	refEntity_t	*luaentity;
	vec3_t axis[3];
	vec3_t ang;

	luaL_checktype(L,1,LUA_TUSERDATA);
	if(!lua_type(L,2) == LUA_TVECTOR) return 0;
	if(!IsVector(L,2)) return 0;

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_tovector(L,2,ang);
		VectorCopy(luaentity->axis[2],axis[0]);
		VectorCopy(luaentity->axis[0],axis[1]);
		VectorCopy(luaentity->axis[1],axis[2]);
		RotateAroundDirection(axis,ang[0]);
		VectorCopy(axis[0],luaentity->axis[2]);
		VectorCopy(axis[1],luaentity->axis[0]);
		VectorCopy(axis[2],luaentity->axis[1]);

		/*VectorCopy(luaentity->axis[0],axis[0]);
		VectorCopy(luaentity->axis[1],axis[1]);
		VectorCopy(luaentity->axis[2],axis[2]);
		RotateAroundDirection(axis,ang[2]);
		VectorCopy(axis[0],luaentity->axis[0]);
		VectorCopy(axis[1],luaentity->axis[1]);
		VectorCopy(axis[2],luaentity->axis[2]);

		VectorCopy(luaentity->axis[1],axis[0]);
		VectorCopy(luaentity->axis[2],axis[1]);
		VectorCopy(luaentity->axis[0],axis[2]);
		RotateAroundDirection(axis,ang[1]);
		VectorCopy(axis[0],luaentity->axis[1]);
		VectorCopy(axis[1],luaentity->axis[2]);
		VectorCopy(axis[2],luaentity->axis[0]);*/
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

int qlua_rsetoldframe(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL && lua_tointeger(L,2) > -1) {
		luaentity->oldframe = lua_tointeger(L,2);
	}
	return 0;
}

int qlua_rgetoldframe(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->oldframe);
		return 1;
	}
	return 0;
}

int qlua_rsetframe(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL && lua_tointeger(L,2) > -1) {
		luaentity->frame = lua_tointeger(L,2);
	}
	return 0;
}

int qlua_rgetframe(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->frame);
		return 1;
	}
	return 0;
}

int qlua_rsetlerp(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL && lua_tointeger(L,2) > -1) {
		luaentity->backlerp = lua_tonumber(L,2);
	}
	return 0;
}

int qlua_rgetlerp(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushnumber(L,luaentity->backlerp);
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
		VectorCopy(in,luaentity->lua_scale);
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
	qlua_toColor(L,2,color,qfalse);

	if(luaentity != NULL) {
		luaentity->shaderRGBA[0] = (int)(color[0]*255);
		luaentity->shaderRGBA[1] = (int)(color[1]*255);
		luaentity->shaderRGBA[2] = (int)(color[2]*255);
		luaentity->shaderRGBA[3] = (int)(color[3]*255);
	}

	return 0;
}

int qlua_rgetcolor(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaentity = lua_torefentity(L,1);

	if(luaentity != NULL) {
		lua_pushinteger(L,(int)luaentity->shaderRGBA[0]);
		lua_pushinteger(L,(int)luaentity->shaderRGBA[1]);
		lua_pushinteger(L,(int)luaentity->shaderRGBA[2]);
		lua_pushinteger(L,(int)luaentity->shaderRGBA[3]);
		return 4;
	}

	return 0;
}

int qlua_rrender(lua_State *L) {
	refEntity_t	*e;

	luaL_checktype(L,1,LUA_TUSERDATA);

	e = lua_torefentity(L,1);
	if(e != NULL) {
		trap_R_AddRefEntityToScene( e );
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

int qlua_rsetalways(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TBOOLEAN);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		luaentity->alwaysRender = lua_toboolean(L,2);
		return 1;
	}
	return 0;	
}

int qlua_rsettime(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		luaentity->shaderTime = lua_tonumber(L,2) / 1000.0f;
	}
	return 0;
}

int qlua_rsettraillength(lua_State *L) {
	refEntity_t	*luaentity;
	int count = 0;
	int size2 = 0;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		count = lua_tointeger(L,2);
		size2 = sizeof(luaentity->trailVerts) / sizeof(luaentity->trailVerts[0]);
		if(count > size2) {
			count = size2;
		} else if (count <= 1) {
			count = 2;
		}
		luaentity->numVerts2 = count;
	}
	return 0;
}

int qlua_rgettraillength(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->numVerts2);
		return 1;
	}
	return 0;
}

int qlua_rsettrailfade(lua_State *L) {
	refEntity_t	*luaentity;
	int count = 0;
	int size2 = 0;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		count = lua_tointeger(L,2);
		if(count >= FT_MAX_TRAILFADE_TYPE) {
			count = FT_MAX_TRAILFADE_TYPE-1;
		} else if (count < 0) {
			count = 0;
		}
		luaentity->tfade = count;
	}
	return 0;
}

int qlua_rgettrailfade(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushinteger(L,luaentity->tfade);
		return 1;
	}
	return 0;
}

int qlua_rsettrailstaticmap(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TBOOLEAN);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		luaentity->staticMap = lua_toboolean(L,2);
	}
	return 0;
}

int qlua_rsettrailmaplength(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		luaentity->trailCoordLength = lua_tonumber(L,2);
		if(luaentity->trailCoordLength <= 0) {
			luaentity->trailCoordLength = .1f;
		}
		return 1;
	}
	return 0;
}

int qlua_rgettrailstaticmap(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushboolean(L,luaentity->staticMap);
		return 1;
	}
	return 0;
}

int qlua_rgettrailmaplength(lua_State *L) {
	refEntity_t	*luaentity;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		lua_pushnumber(L,luaentity->trailCoordLength);
		return 1;
	}
	return 0;
}

int qlua_rgetinfo(lua_State *L) {
	refEntity_t	*luaentity;
	md3Info_t	info;
	int			i;

	luaL_checktype(L,1,LUA_TUSERDATA);

	luaentity = lua_torefentity(L,1);
	if(luaentity != NULL) {
		trap_R_ModelInfo(luaentity->hModel, &info);
		lua_newtable(L);
		for(i=0; i<info.numSurfaces; i++) {
			lua_pushinteger(L, i+1);
			lua_pushinteger(L, info.numTriangles[i]);
			lua_rawset(L, -3);
		}
		return 1;
	}
	return 0;
}

int qlua_rlerptriangle(lua_State *L) {
	refEntity_t	*luaentity;
	refTri_t	tris;
	vec3_t		v1,v2,normal,temp;
	int			i, x, surfID, id;
	qboolean	raw = qfalse;

	luaL_checktype(L,1,LUA_TUSERDATA);
	luaL_checktype(L,2,LUA_TNUMBER);
	luaL_checktype(L,3,LUA_TNUMBER);

	luaentity = lua_torefentity(L,1);
	surfID = lua_tointeger(L,2)-1;
	if(surfID < 0) return 0;

	id = lua_tointeger(L,3)-1;
	if(id < 0) return 0;

	if(lua_gettop(L) > 3) raw = lua_toboolean(L,4);
	if(luaentity != NULL) {
		if(trap_R_LerpTriangle( luaentity->hModel, surfID, id, &tris, luaentity->oldframe, luaentity->frame, 1.0 - luaentity->backlerp )) {
			lua_newtable(L);
			for(i=0; i<3; i++) {
				lua_pushinteger(L, i+1);

				if(!raw) {
					VectorCopy(luaentity->origin,temp);
					for (x=0; x<3; x++ ) {
						VectorMA( temp, tris.verts[i][x], luaentity->axis[x], temp );
					}
					VectorCopy(temp,tris.verts[i]);
				}
				lua_pushvector(L, temp);
				lua_rawset(L, -3);
			}

			VectorSubtract(tris.verts[1],tris.verts[0],v1);
			VectorSubtract(tris.verts[2],tris.verts[0],v2);
			VectorNormalize(v1);
			VectorNormalize(v2);
			CrossProduct(v2,v1,normal);

			lua_pushvector(L,normal);

			return 2;
		}
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
  {"AddRenderFx",		qlua_rrenderfx},
  {"GetPos",			qlua_rgetpos},
  {"SetPos",			qlua_rsetpos},
  {"GetPos2",			qlua_rgetpos2},
  {"SetPos2",			qlua_rsetpos2},
  {"GetAxis",			qlua_rgetaxis},
  {"SetAxis",			qlua_rsetaxis},
  {"RotateAroundAxis",	qlua_rrotatearound},
  {"GetAngles",			qlua_rgetangles},
  {"SetAngles",			qlua_rsetangles},
  {"SetShader",			qlua_rsetshader},
  {"GetShader",			qlua_rgetshader},
  {"SetModel",			qlua_rsetmodel},
  {"GetModel",			qlua_rgetmodel},
  {"SetSkin",			qlua_rsetskin},
  {"GetSkin",			qlua_rgetskin},
  {"SetType",			qlua_rsettype},
  {"GetType",			qlua_rgettype},
  {"SetRadius",			qlua_rsetradius},
  {"GetRadius",			qlua_rgetradius},
  {"SetFrame",			qlua_rsetframe},
  {"GetFrame",			qlua_rgetframe},
  {"SetOldFrame",		qlua_rsetoldframe},
  {"GetOldFrame",		qlua_rgetoldframe},
  {"SetLerp",			qlua_rsetlerp},
  {"GetLerp",			qlua_rgetlerp},
  {"SetColor",			qlua_rsetcolor},
  {"GetColor",			qlua_rgetcolor},
  {"SetRotation",		qlua_rsetrotation},
  {"SetTime",			qlua_rsettime},
  {"Scale",				qlua_rsetscale},
  {"Render",			qlua_rrender},
  {"AlwaysRender",		qlua_rsetalways},
  {"PositionOnTag",		qlua_rpositionontag},
  {"SetTrailLength",	qlua_rsettraillength},
  {"GetTrailLength",	qlua_rgettraillength},
  {"SetTrailFade",		qlua_rsettrailfade},
  {"GetTrailFade",		qlua_rgettrailfade},
  {"SetTrailStaticMap", qlua_rsettrailstaticmap},
  {"SetTrailMapLength",	qlua_rsettrailmaplength},
  {"GetTrailStaticMap", qlua_rgettrailstaticmap},
  {"GetTrailMapLength",	qlua_rgettrailmaplength},
  {"GetInfo",			qlua_rgetinfo},
  {"LerpTriangle",		qlua_rlerptriangle},
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

	lua_setglobal(L,"M_RefEntity");

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
	ent.lua_scale[0] = 1;
	ent.lua_scale[1] = 1;
	ent.lua_scale[2] = 1;

	ent.trailCoordLength = 1000;

	lua_pushrefentity(L,&ent);
	return 1;
}

void CG_InitLuaREnts(lua_State *L) {
	REntity_register(L);
	//lua_register(L,"GetEntitiesByClass",qlua_getentitiesbyclass);
	//lua_register(L,"GetAllPlayers",qlua_getallplayers);
	lua_register(L,"RefEntity",qlua_createrefentity);
}