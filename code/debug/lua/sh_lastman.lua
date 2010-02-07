--H.clear = true
local deadClients = {}
local GAME_DURATION = 1.5 --minutes
local startTime = LevelTime()

local function GameMinutes()
	return GAME_DURATION*1000*60
end

local freezePlayers = true

function FiredWeapon()
	if(freezePlayers) then return -1 end
end
hook.add("FiredWeapon","sh_lastman",FiredWeapon)

function PlayerMove()
	if(freezePlayers) then return true end
end
hook.add("PlayerMove","sh_lastman",PlayerMove)


if(SERVER) then
//__DL_BLOCK
	downloader.add("lua/sh_lastman.lua")

	message.Precache("lastman_update")
	
	team.CustomScores(true)
	
	local lastKill = 0
	local surviveTimer = nil
	
	local function respawnItems()
		local it = GetEntitiesByType(ET_ITEM)
		for k,v in pairs(it) do
			if(bitAnd(v:GetFlags(),FL_DROPPED_ITEM) == 0) then
				print("^2Respawn: ^3" .. v:Classname() .. "\n")
				v:Respawn()
			else
				print("^1Must Remove: ^3" .. v:Classname() .. "\n")
				v:Remove()
			end
		end
	end
	
	local function sendPLOut(pl)
		local msg = Message()
		message.WriteShort(msg,1)
		message.WriteShort(msg,pl:EntIndex())
		SendDataMessageToAll(msg,"lastman_update")
	end
	
	local function sendReset()
		startTime = LevelTime()
		local msg = Message()
		message.WriteShort(msg,2)
		SendDataMessageToAll(msg,"lastman_update")
	end

	local function sendMessage(str,pl)
		local msg = Message()
		message.WriteShort(msg,3)
		message.WriteString(msg,str)
		if(pl ~= nil) then
			SendDataMessage(msg,pl,"lastman_update")
		else
			SendDataMessageToAll(msg,"lastman_update")
		end
	end
	
	function testStrMessage()
		sendMessage("Line #1\nLine #2")
	end
	
	local function PlayerKilled(pl,inflictor,attacker,damage,means)
		lastKill = LevelTime()
		print("Hook " .. tostring(pl) .. " | " .. tostring(inflictor) .. " | " .. tostring(attacker) .. " | " .. tostring(damage) .. " | " .. tostring(means) .. "\n")
		if(pl == nil) then return end
		print("Player Killed\n")
		sendMessage(pl:GetInfo().name .. " is out!");
		sendPLOut(pl)
		Timer(1,function()
			local t = LevelTime() + 6000000
			pl:SetRespawnTime(t)
			print("Set RespawnTime: " .. t .. "\n")
			table.insert(deadClients,pl)
			
			if(surviveTimer ~= nil) then
				StopTimer(surviveTimer)
			end
			
			surviveTimer = Timer(1,function()
				checkAndPrintSurvivor()
			end)

			if(pl:GetTable() and pl:GetTable().body) then
				pl:GetTable().body:SetNextThink(t)
			end
			--pl:SetAnim(BOTH_DEATH1,ANIM_LEGS,6000)
			--pl:SetAnim(BOTH_DEATH1,ANIM_TORSO,6000)
		end)
	end
	hook.add("PlayerKilled","sh_lastman",PlayerKilled)

	local function countLivePlayers()
		local c = 0
		local last = ""
		for k,v in pairs(GetAllPlayers()) do
			if(v:GetHealth() > 0) then
				c = c + 1
				last = v
			end
		end
		return c,last
	end

	local waitingReset = false
	function checkAndPrintSurvivor()
		local live,last = countLivePlayers()
		if(live <= 1) then
			if(waitingReset == true) then return end
			if(live == 0) then
				sendMessage("Nobody Survived!");
			else
				sendMessage(last:GetInfo().name .. " is the last survivor!\n 1 Point")
				last:SetInfo(PLAYERINFO_SCORE,last:GetInfo().score + 1)
			end
			waitingReset = true
		end
	end

	local function reset()
		waitingReset = false
		deadClients = {}
		sendReset()
		for k,v in pairs(GetAllPlayers()) do
			local body = v:Respawn()
			if(body ~= nil) then
				body:Remove()
			end
		end
		respawnItems()
		freezePlayers = true
		Timer(3,function() freezePlayers = false end)
	end
	reset()
	
	function H:Think()
		if(startTime + GameMinutes() < LevelTime() and waitingReset ~= true) then
			sendMessage("Time's Up, Restarting...")
			startTime = LevelTime()
			reset()
			return
		end
		if(lastKill < LevelTime() - 5000) then
			local live,last = countLivePlayers()
			if(live <= 1 and #deadClients > 0) then
				reset()
			end
		end
	end
	

	local function PlayerDamaged(self,inflictor,attacker,damage,meansOfDeath)
		if(self == nil) then return end
		local hp = self:GetInfo()["health"]
		if(hp <= 0) then
			damage = 0
		else
			if((hp - damage) < -40) then
				damage = hp+1
			end
		end
		return damage
	end
	hook.add("PlayerDamaged","sh_lastman",PlayerDamaged)

//__DL_UNBLOCK
else
	local svmessage = ""
	local svmessageTime = 0
	
	local MESSAGE_DURATION = 3000
	
	function H:Think()
		util.EnableCenterPrint(false)
	end
	
	local function drawTimer()
		local m = GameMinutes()
		local t = m - ((LevelTime() - startTime))
		if(t < 0) then t = 0 else t = t / 1000 end
		local s = math.floor(t % 60)
		if(s < 10) then s = "0" .. s end
		local tstr = math.floor(t/60) .. ":" .. s
		local w = draw.Text2Width(tstr)
		draw.SetColor(1,1,1,1)
		draw.Text2(320 - (w/2), 10, tstr, .8, false)
	end
	
	local function Draw2D()
		local y = 200
		draw.Text(10,y,"^2Players:",10,10)
		local tab = _CG.scores
		for k,v in pairs(tab) do
			local info = util.GetClientInfo(v.client)
			if(info != nil) then	
				if(info.connected) then
					y = y + 10
					local name = fixcolorstring(info.name)
					draw.SetColor(1,1,1,1)
					if(deadClients[v.client] == true) then
						draw.SetColor(.6,0,0,1)
						name = name .. "[OUT]"
					end
					draw.Text(10,y,name,10,10)
				end
			end
		end
		if(svmessageTime > LevelTime() - MESSAGE_DURATION) then
			local msgC = string.Explode("\n",svmessage)
			local d = (svmessageTime - (LevelTime() - MESSAGE_DURATION)) / MESSAGE_DURATION
			local s = (d/2 + .5)
			local h = 26 * s
			local y = 300
			if(_CG.stats[STAT_HEALTH] <= 0) then
				y = 400
			end
			
			y = y - (h * #msgC) / 2
			for k,v in pairs(msgC) do
				local w = draw.Text2Width(v) * s
				local x = 320 - (w/2)
				draw.SetColor(1,1,1,d)
				draw.Text2(x,y,v,s,false)
				y = y + h
			end
		end
		drawTimer()
	end
	hook.add("Draw2D","sh_lastman",Draw2D)
	
	local function HandleMessage(msgid)
		if(msgid == "lastman_update") then
			local t = message.ReadShort()
			if(t == 1) then
				local pl = message.ReadShort()
				deadClients[pl] = true
			elseif(t == 2) then
				deadClients = {}
				startTime = LevelTime()
				util.ClearMarks()
				freezePlayers = true
				Timer(3,function() freezePlayers = false end)
			elseif(t == 3) then
				local msg = message.ReadString()
				svmessage = msg
				svmessageTime = LevelTime()
			end
		end
	end
	hook.add("HandleMessage","sh_lastman",HandleMessage)
end