local player1 = CreateNetworkedTable(201)
local player2 = CreateNetworkedTable(202)
local game = CreateNetworkedTable(203)

local function initVar(tab,var,value)
	tab[var] = value
end

local function def(var,value)
	return var or value
end

local function calcball(b)
	local x = 0
	local y = 0
	if(b.started == 1) then
		local t = b.btime
		if(t == nil) then return 0,0 end
		
		x = b.bx + (b.bvx/1000) * (LevelTime() - t)
		y = b.by + (b.bvy/1000) * (LevelTime() - t)
	end
	return x,y
end

if(SERVER) then
	--downloader.add("lua/sh_pong.lua")

	local ball_vx = 0.6
	local ball_vy = 0.65
	local function initGame()
		initVar(game,"started",0)
		initVar(game,"bx",0)
		initVar(game,"by",0)
		initVar(game,"bvx",ball_vx)
		initVar(game,"bvy",ball_vy)
		initVar(game,"btime",LevelTime())
		initVar(game,"bsize",.04)
		initVar(player1,"ready",0)
		initVar(player2,"ready",0)
	end
	
	local function initPlayer(pl,client)
		initVar(pl,"paddle_y",0)
		initVar(pl,"paddle_size",.2)
		initVar(pl,"score",0)
		initVar(pl,"client",client)
	end
	
	local function initAllPlayers()
		initPlayer(player1,0)
		initPlayer(player2,1)
	end
	
	initAllPlayers()
	initGame()
	
	local function startGame()
		game.btime = LevelTime()
	end
	
	local function playerScored(pl)
		pl.score = pl.score + 1
		initGame()
	end
	
	local function frame()
		if(game.started == 0) then 
			if(player1.ready == 1 and player2.ready == 1) then
				initGame()
				game.started = 1
			end
			return 
		end
		local x,y = calcball(game)
		local s = game.bsize
		local p1y = player1.paddle_y / 127
		local p2y = player2.paddle_y / 127
		local p1s = player1.paddle_size
		local p2s = player2.paddle_size
		if(x-s <= -1) then
			playerScored(player2)
		end
		
		if(x+s >= 1) then
			playerScored(player1)
		end
		
		if(y+s >= 1 or y-s <= -1) then
			game.bvy = game.bvy * -1
			game.bx = x
			game.by = y
			game.btime = LevelTime()-20
		end
		
		if(x < -.85 and y < p1y + p1s and y > p1y - p1s) then
			game.bvx = game.bvx * -1
			game.bx = x
			game.by = y
			game.btime = LevelTime()-20
		end
		
		if(x > .85 and y < p2y + p2s and y > p2y - p2s) then
			game.bvx = game.bvx * -1
			game.bx = x
			game.by = y
			game.btime = LevelTime()-20
		end
	end
	hook.add("Think","sh_pong",frame)
	
	function PlayerMove(pm,walk,forward,right)
		local f,r,u = pm:GetMove()
		local index = pm:EntIndex()
		local entity = nil
		
		for k,v in pairs(GetAllPlayers()) do
			if(v:EntIndex() == index) then entity = v end
		end
		if(entity == nil) then return end
		
		local ready = 0
		if(u == 127) then ready = 1 end
		if(index == 0) then
			player1.paddle_y = f
			if(ready != 0 and game.started == 0) then player1.ready = ready end
		else
			player2.paddle_y = f
			if(ready != 0 and game.started == 0) then player2.ready = ready end
		end
	end
	hook.add("PlayerMove","sh_pong",PlayerMove)
	
	local function ready(str,v)
		if(str == "ReadyForPong") then
			game:SendVars(v)
			player1:SendVars(v)
			player2:SendVars(v)		
		end
	end
	hook.add("MessageReceived","sh_pong",ready)
else
	local mx = 0
	local my = 0
	local active = true
	local function drawPlayers()
		local p1y = ((def(player1.paddle_y,0) / 127) * 240) + 240
		local p2y = ((def(player2.paddle_y,0) / 127) * 240) + 240
		local p1size = def(player1.paddle_size,4) * 480
		local p2size = def(player1.paddle_size,4) * 480
		local cl1 = def(player1.client,-1)
		local cl2 = def(player2.client,-1)
		draw.SetColor(1,1,1,1)
		draw.Rect(20,p1y-p1size/2,20,p1size)
		draw.Rect(600,p2y-p2size/2,20,p2size)
		
		if(cl1 != -1) then
			local ptxt = GetEntityByIndex(cl1):GetInfo().name .. ": " .. player1.score
			draw.SetColor(1,1,1,1)
			draw.Text(20,0,ptxt,20,20)
			if(player1.ready == 1) then
				draw.SetColor(1,1,1,1)
				draw.Text(20,30,"Ready",20,20)			
			end
		end

		if(cl2 != -1) then
			local ptxt = GetEntityByIndex(cl2):GetInfo().name .. ": " .. player2.score
			draw.SetColor(1,1,1,1)
			draw.Text(620-string.len(ptxt)*20,0,ptxt,20,20)
			if(player2.ready == 1) then
				draw.SetColor(1,1,1,1)
				draw.Text(620-string.len("Ready")*20,30,"Ready",20,20)
			end
		end
	end
	
	local function drawPong()
		local cx,cy = calcball(game)
		local ball_x = (cx * 320) + 320
		local ball_y = (cy * 240) + 240
		local ball_sizex = def(game.bsize,.01)*640
		local ball_sizey = def(game.bsize,.01)*480
		
		draw.SetColor(1,1,1,1)
		draw.Rect(mx-1,my-1,2,2)
		draw.Rect(ball_x-ball_sizex/2,ball_y-ball_sizey/2,ball_sizex,ball_sizey)
		drawPlayers()
	end

	local function d3d()
		if(active) then
			util.LockMouse(true)
			draw.SetColor(0,0,0,1)
			draw.Rect(0,0,640,480)
		
			if(KeyIsDown(K_ENTER)) then --enterquit
				active = false
			end
			
			drawPong()
		else
			util.LockMouse(false)
		end
	end
	hook.add("Draw3D","sh_pong",d3d)
	hook.add("AllowGameSound","sh_pong",function(sound) return !active end)

	local function moused(x,y)
		mx = mx + x
		my = my + y
		
		if(mx > 640) then mx = 640 end
		if(mx < 0) then mx = 0 end
		
		if(my > 480) then my = 480 end
		if(my < 0) then my = 0 end
	end
	hook.add("MouseEvent","sh_pong",moused)
	
	local function UserCmd(pl,angle,fm,rm,um,buttons,weapon)
		if(active) then
			fm = ((my/480) * 254)-127
			rm = LocalPlayer():EntIndex()
			SetUserCommand(angle,fm,0,um,buttons,0)
			--print(fm .. "\n")
		end
	end
	hook.add("UserCommand","sh_pong",UserCmd)

	local function noNuthin(str)
		if(!active) then return true end
		if(str == "WORLD") then return false end
		if(str == "ENTITIES") then return false end
		if(str == "HUD") then return false end
		if(str == "HUD_DRAWGUN") then return false end
	end
	hook.add("ShouldDraw","sh_pong",noNuthin);
	SendString("ReadyForPong")
end