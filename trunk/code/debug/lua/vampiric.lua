if(CLIENT) then 
	local notifyt = 0;
	local val = 0
	local y = 0
	local title = 1
	
	local function draw2D()
		if(notifyt > 0) then
			draw.SetColor(0,1,0,notifyt)
			draw.Text(10,100+y,"+" .. val,20,20)
			if(val <= 0) then
				notifyt = notifyt - 0.01
				y = y + 1
			end
		else
			val = 0
		end
		if(title > 0) then
			title = title - 0.002
			local text = "Vampiric Mod"
			draw.SetColor(.4,1,.2,title)
			draw.Text(320-(20*string.len(text)),240-20,text,40,40)			
		end
	end
	hook.add("Draw2D","Vampiric",draw2D)

	local function messagetest(str)
		local args = string.Explode(" ",str)
		if(args[1] == "damagegiven") then
			val = val + tonumber(args[2])
			notifyt = 1
			y = 0
		end
		if(args[1] == "sub") then
			val = val - tonumber(args[2])
		end
	end
	hook.add("MessageReceived","Vampiric",messagetest)
	
return 
end

SendScript("lua/vampiric.lua")

local function PlayerDamaged(self,inflictor,attacker,damage,meansOfDeath)
	if(self != nil and attacker != nil) then
	if(self == attacker) then return end
	local atk_tab = GetEntityTable(attacker);
		local hp = attacker:GetInfo()["health"]
		local hp2 = self:GetInfo()["health"]
		if(hp and hp2 > 0) then
			if(damage > hp2) then damage = hp2 end
			local give = math.ceil(damage);
			atk_tab.give = atk_tab.give or 0
			atk_tab.give = atk_tab.give + give;
			attacker:SendString("damagegiven " .. give)
			atk_tab.wait = 20
		end
	end
end
hook.add("PlayerDamaged","Vampiric",PlayerDamaged)

local function plThink()
	local tab = GetAllPlayers()
	for k,v in pairs(tab) do
		local hp = v:GetInfo(v)["health"]
		local tab = GetEntityTable(v);
		if(tab) then tab.wait = tab.wait or 0 end
		if(tab and tab.give and tab.give > 0) then
			if(tab.wait > 0) then 
				tab.wait = tab.wait - 1
			else
				local giverate = 1
				if(tab.give < 10) then tab.wait = 1 end
				if(tab.give > 10) then giverate = 2 end
				if(tab.give > 30) then giverate = 3 end
				if(hp < 300) then
					v:SetInfo(PLAYERINFO_HEALTH,hp + giverate)
					hp = v:GetInfo()["health"]
					tab.give = tab.give - giverate
					v:SendString("sub " .. giverate)
					if(tab.give <= 0) then tab.wait = 10 end
				else
					v:SetInfo(PLAYERINFO_HEALTH,300)
					v:SendString("sub " .. tab.give)
					tab.give = 0
					tab.wait = 4
				end
			end
		else
			if(tab.wait > 0) then 
				tab.wait = tab.wait - 1
			else
				if(hp >= 200) then
					v:SetMaxHealth(hp) --Block pain sounds
					v:SetInfo(PLAYERINFO_HEALTH,hp-1)
				else
					v:SetMaxHealth(0) --Revert to default max health
				end
			end
		end
	end
end
hook.add("Think","Vampiric",plThink)