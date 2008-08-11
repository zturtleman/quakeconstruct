-- lua2c.lua
-- generates C code from Lua code (based on luac output from 4.0)
-- usage: luac -v -p -l myfile.lua | lua lua2c.lua
-- this code is hereby placed in the public domain by lhf@tecgraf.puc-rio.br
-- 13 Feb 02 01:01:42

-- set this according to your indentation style
INDENT=" "

-- uncomment this if you want to debug
-- DEBUG=write

-- no need to change anything below this line

SP=0
NP=0
NF=0
F={}

function stack(n)
 SP=SP+n
 DEBUG("NP=",NP,"\t")
 DEBUG("SP=",SP,"\n")
end

function NOP(op,p1,p2,c)
end

function END(op,p1,p2,c)
 SP=0
 write(INDENT,'return 0;\n')
 write("}\n\n")
end

function CANNOT(op,p1,p2,c)
 write("#error cannot handle ",op," ",p1 or ""," ",p2 or ""," ",c or "","\n")
 --write("lua2c_",op,"(",p1 or "0",",",p2 or "0",",\"",c or "","\");\n")
end

function RETURN(op,p1,p2,c)
 write(INDENT,'return ',SP-p1,';\n')
 stack(-(SP-p1))
end

function CALL(op,p1,p2,c)
 if p2==255 then
  CANNOT(op,p1,p2,c)
 else
  write(INDENT,'lua_call(L,',SP-(p1+1),',',p2,');\n')
  stack(p2-(SP-p1))
 end
end

function TAILCALL(op,p1,p2,c)
 write(INDENT,'lua_call(L,',SP-(p1+1),',LUA_MULTRET);\n')
 write(INDENT,'return lua_gettop(L);\n')
 SP=0
end

function POP(op,p1,p2,c)
 write(INDENT,'lua_pop(L,',p1,');\n')
 stack(1)
end

function PUSHNIL(op,p1,p2,c)
 for i=1,p1 do
  write(INDENT,'lua_pushnil(L);\n')
 end
 stack(p1)
end

function PUSHINT(op,p1,p2,c)
 write(INDENT,'lua_pushnumber(L,',p1,');\n')
 stack(1)
end

function PUSHSTRING(op,p1,p2,c)
 write(INDENT,'lua_pushstring(L,"',c,'");\n')
 stack(1)
end

function PUSHNUM(op,p1,p2,c)
 write(INDENT,'lua_pushnumber(L,',c,');\n')
 stack(1)
end

function PUSHNEGNUM(op,p1,p2,c)
 write(INDENT,'lua_pushnumber(L,-',c,');\n')
 stack(1)
end

function PUSHUPVALUE(op,p1,p2,c)
 write(INDENT,'lua_pushvalue(L,',p1+1,'+',NP,');\n')
 stack(1)
end

function GETLOCAL(op,p1,p2,c)
 write(INDENT,'lua_pushvalue(L,',p1+1,');\n')
 stack(1)
end

function GETGLOBAL(op,p1,p2,c)
 write(INDENT,'lua_getglobal(L,"',c,'");\n')
 stack(1)
end

function GETTABLE(op,p1,p2,c)
 write(INDENT,'lua_gettable(L,-2);\n')
 write(INDENT,'lua_remove(L,-2);\n')
 stack(-1)
end

function GETDOTTED(op,p1,p2,c)
 write(INDENT,'lua_pushstring(L,"',c,'");\n')
 write(INDENT,'lua_gettable(L,-2);\n')
 write(INDENT,'lua_remove(L,-2);\n')
 stack(0)
end

function GETINDEXED(op,p1,p2,c)
 write(INDENT,'lua_pushvalue(L,',p1+1,');\n')
 write(INDENT,'lua_gettable(L,-2);\n')
 write(INDENT,'lua_remove(L,-2);\n')
 stack(0)
end

function PUSHSELF(op,p1,p2,c)
 write(INDENT,'lua_pushstring(L,"',c,'");\n')
 write(INDENT,'lua_gettable(L,-2);\n')
 write(INDENT,'lua_insert(L,-2);\n')
 stack(1)
end

function CREATETABLE(op,p1,p2,c)
 write(INDENT,'lua_newtable(L);\n')
 stack(1)
end

function SETLOCAL(op,p1,p2,c)
 write(INDENT,'lua_insert(L,',p1,');\n')
 write(INDENT,'lua_remove(L,',p1+1,');\n')
 stack(-1)
end

function SETGLOBAL(op,p1,p2,c)
 write(INDENT,'lua_setglobal(L,"',c,'");\n')
 stack(-1)
end

function SETTABLE(op,p1,p2,c)
 write(INDENT,'lua_settable(L,-2);\n')
 write(INDENT,'lua_remove(L,-2);\n')
 stack(-1)
end

function CONCAT(op,p1,p2,c)
 write(INDENT,'lua_concat(L,',p1,');\n')
 stack(-p1+1)
end

function SETLIST(op,p1,p2,c)
 for i=p2,1,-1 do
  write(INDENT,'lua_rawseti(L,',-i-1,',',i+62*p1,');\n')
 end
 stack(-p2)
end

function SETMAP(op,p1,p2,c)
 for i=1,p1 do
  write(INDENT,'lua_settable(L,',-2*(p1-i+1)-1,');\n')
 end
 stack(-2*p1)
end

function CLOSURE(op,p1,p2,c)
 local n=F[c]
 if n==nil then NF=NF+1; F[c]=NF; n=NF end
 write(INDENT,'lua_pushcclosure(L,F',n,',',p2,');\n')
 stack(-p2+1)
end

DEBUG= DEBUG or function () end

while 1 do
 local s=read()
 if s==nil then break end
 local _,_,v=strfind(s,"^Lua (%S+)")
 if v~=nil and v~="4.0" then
  write("Sorry, this version of lua2c cannot handle Lua ",v,", only 4.0\n")
  exit(1)
 end
 if strfind(s,"^main") then write("static int MAIN(lua_State *L)\n{\n") end
 local _,_,f=strfind(s,"^function.* at (%S+)%)")
 if f~=nil then
  local n=F[f] if n==nil then NF=NF+1; F[f]=NF; n=NF end
  write("static int F",n,"(lua_State *L)\n{\n")
 end
 local _,_,n=strfind(s,"^(%d+) param")
 if n~=nil then n=tonumber(n); SP=n; NP=n end
 local p='%s*(%d+)%s+%[(%d+)%]%s+(%w+)%s+([-%w]*)%s*(%w*)%s*;?%s*"?(.-)"?%s*$'
 local _,_,pc,ln,op,p1,p2,c=strfind(s,p)
 if op~=nil then
  DEBUG(s,"\n")
  local f=getglobal(op) or CANNOT
  f(op,tonumber(p1),tonumber(p2),c)
 end
end

if NF>0 then
 write("/* function proptotypes */\n");
 for i=1,NF do
  write("static int F",i,"(lua_State *L);\n")
 end
end
