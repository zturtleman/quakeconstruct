local function trDown(pos)
	local endpos = vAdd(pos,Vector(0,0,-10000))
	local res = TraceLine(pos,endpos,nil,1)
	return res.endpos
end

local stayTime = 10000
local fadeTime = 6000

if(SERVER) then
//__DL_BLOCK
	--A
	downloader.add("lua/longbodies.lua")

	message.Precache("bodydissolve")
	
	local function Respawn(pl,body)
		if(body) then
			body:GetTable().start = LevelTime()
			body:SetNextThink(LevelTime() + stayTime)
			body:GetTable().finish = false
			body:GetTable().sent = false
		end
	end
	hook.add("PlayerSpawned","longbodies",Respawn)

	local function Think()
		for _,body in pairs(GetEntitiesByClass("bodyque")) do
			if(body:GetTable().finish == false) then
				local dtx = (stayTime - fadeTime)
				if((LevelTime() - dtx) > body:GetTable().start) then
					if(body:GetTable().sent == false) then
						
						local msg = Message()
						message.WriteShort(msg,body:EntIndex())
						SendDataMessageToAll(msg,"bodydissolve")
						body:GetTable().sent = true
					end
				end
				if((LevelTime() - (stayTime - 100)) > body:GetTable().start) then
					body:SetPos(body:GetPos() - Vector(0,0,500))
				end
				if((LevelTime() - stayTime) > body:GetTable().start) then
					body:SetPos(body:GetPos() - Vector(0,0,1000))
					body:GetTable().finish = true
					UnlinkEntity(body)
				end
			end
		end
	end
	hook.add("Think","longbodies",Think)	
//__DL_UNBLOCK
else
	local d_ents = {}
	local function HandleMessage(msgid)
		if(msgid == "bodydissolve") then
			local ent = message.ReadShort()
			d_ents[ent] = LevelTime()
		end
	end
	hook.add("HandleMessage","longbodies",HandleMessage)
	
	local fire = LoadShader("dissolve2") --LoadShader("fireSphere")
	function d3d()
		local tab = GetEntitiesByClass("player")
		table.insert(tab,LocalPlayer())
		for k,v in pairs(tab) do
			local tx = d_ents[v:EntIndex()]
			if(tx) then
				if(LevelTime() - stayTime < tx) then
					v:CustomDraw(true)
					local dt = (tx - (LevelTime() - fadeTime))/fadeTime
					if(dt >= 0 and dt <= 1) then
						local legs,torso,head = LoadPlayerModels(v)
						legs:SetPos(v:GetPos()) --trDown(v:GetPos()) + Vector(0,0,24)
						
						util.AnimatePlayer(v,legs,torso)
						util.AnglePlayer(v,legs,torso,head)
						
						torso:PositionOnTag(legs,"tag_torso")
						head:PositionOnTag(torso,"tag_head")

						local dtx = (1-(dt*.7))
						
						legs:SetColor(.3*dt,1*dt,.5*dt,1*dtx)
						torso:SetColor(.3*dt,1*dt,.5*dt,1*dtx)
						head:SetColor(.3*dt,1*dt,.5*dt,1*dtx)
						
						legs:SetShader(fire)
						torso:SetShader(fire)
						head:SetShader(fire)
						
						for i=0,2 do
							legs:Render()
							torso:Render()
							head:Render()
						end
					end
				end
			else
				v:CustomDraw(false)
			end
		end
	end
	hook.add("Draw3D","sh_spawner",d3d)
end