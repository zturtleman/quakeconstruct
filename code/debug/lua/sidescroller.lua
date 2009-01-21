if(SERVER) then
	--downloader.add("lua/sidescroller")
	local function BlockAdjust(pl)
		return false
	end
	hook.add("ShouldAdjustAngle","sidescroller",BlockAdjust)
	
	local function spawn(cl)
		local wp = WP_GRENADE_LAUNCHER
		cl:GiveWeapon(wp)
		cl:SetWeapon(wp)
		cl:SetAmmo(wp,-1)	
	end
	hook.add("PlayerSpawned","sidescroller",spawn)
end

function PlayerMove(pm,walk,forward,right)
	--PM_Accelerate(Vector(0,0,1),4,10)
	if(pm:GetType() == PM_DEAD) then
		PM_Drop()
		PM_AirMove()
		
		local v = pm:GetVelocity()
		--v.x = 0
		pm:SetVelocity(v)
		
		return true
	end
	if(pm:WaterLevel() > 1) then
		PM_WaterMove()
	elseif(walk) then
		PM_WalkMove()
	else
		PM_AirMove()
	end
	
	local v = pm:GetVelocity()
	--v.x = 0
	pm:SetVelocity(v)

	if(SERVER) then
		--print(scale .. "\n")
	end
	
	return true
end
hook.add("PlayerMove","sidescroller",PlayerMove)

if(CLIENT) then
	local aim = 0
	local flip = false
	local newbits = 0
	local txt = ""
	local realyaw = 0
	local ddist = 0
	local mdelta = {0,0}
	local vdelta = {0,0}
	
	local fx = LoadShader("railCore")
	local flare = LoadShader("flareShader")
	local function getBeamRef(v1,v2,r,g,b,size)
		local st1 = RefEntity()
		st1:SetType(RT_RAIL_CORE)
		st1:SetPos(v1)
		st1:SetPos2(v2)
		st1:SetColor(r,g,b,1)
		st1:SetRadius(size or 12)
		st1:SetShader(fx)
		return st1
	end
	
	local function rpoint(pos,r,g,b,size)
		local s = RefEntity()
		s:SetType(RT_SPRITE)
		s:SetPos(pos)
		s:SetColor(r,g,b,1)
		s:SetRadius(size or 8)
		s:SetShader(flare)
		return s
	end
	
	local function ShouldDraw(id)
		if(id == "HUD_DRAWGUN") then return false end
	end
	hook.add("ShouldDraw","sidescroller",ShouldDraw)
	
	local h = 1
	local function drawPlayer(pl)
		h = h + 2*Lag()
		if(h > 360) then h = 1 end
		if(pl:GetInfo().health <= -40) then return end
		local legs,torso,head = LoadPlayerModels(pl)
		legs:SetPos(pl:GetPos())
		
		util.AnimatePlayer(pl,legs,torso)
		util.AnglePlayer(pl,legs,torso,head)

		--torso:Scale(Vector(1.2,1.2,1.2))
		
		torso:PositionOnTag(legs,"tag_torso")
		head:PositionOnTag(torso,"tag_head")
		
		util.PlayerWeapon(pl,torso)
		
		--head:Scale(Vector(2,2,2))
		
		legs:Render()
		torso:Render()
		head:Render()
		
		local brt = 1
		if(LocalPlayer() != pl) then brt = .2 end
		local r,g,b = hsv(1,1,brt)
		local forward = VectorForward(pl:GetLerpAngles())
		local pos = pl:GetPos() + Vector(0,0,25)
		local ep = pos + forward * 1000
		local tr = TraceLine(pos,ep,pl,1)
		pos.z = pos.z - 2
		pos = pos + forward*30
		getBeamRef(pos,tr.endpos,r,g,b,5):Render()
		rpoint(tr.endpos,r,g,b,10):Render()
	end
	
	local function draw3d()
		local players = GetAllPlayers()
		local pl = LocalPlayer()
		table.insert(players,pl)
		for k,v in pairs(players) do
			v:CustomDraw(true)
			drawPlayer(v)
		end
	end
	hook.add("Draw3D","sidescroller",draw3d)

	local function draw2d()
		draw.SetColor(1,1,1,1)
		draw.Text(0,150,txt,10,10)
	end
	hook.add("Draw2D","sidescroller",draw2d)
	
	local function view(pos,ang,fovx,fovy)
	
		ang = VectorToAngles(Vector(-1,0,0))
		--ang = Vector(0,90,0)
		local f,r,u = AngleVectors(ang)
		
		realyaw = ang.y
		pos = pos + f*(-400 + ddist)
		pos = pos + Vector(0,0,20)
		ang.p = ang.p + 8
		
		ang.p = ang.p + (ddist/10)
		pos.z = pos.z + (ddist/8)
		
		pos = pos + r * (mdelta[1]*-100)
		pos = pos + u * (mdelta[2]*100)
		
		vdelta[1] = (mdelta[1]*60) - 10
		vdelta[2] = (mdelta[2]*60) - 20
		
		ApplyView(pos,ang)
		
		if(LocalPlayer():GetInfo().health <= 0) then
			ddist = ddist + (300 - ddist)*(.02 * Lag())
		else
			ddist = ddist + (0 - ddist)*(.02 * Lag())
		end
	
	end
	hook.add("CalcView","sidescroller",view)

	
	local function moused(x,y)
		--aim = aim + y/2
		--if(aim > 90) then aim = 90 end
		--if(aim < -90) then aim = -90 end
	end
	hook.add("MouseEvent","sidescroller",moused)
	
	local wasmouse = false
	local function think()
		local vx,vy = unpack(vdelta)
		vx = 320 + vx
		vy = 240 + vy
		local dx,dy = vx-GetXMouse(),vy-GetYMouse()
		mdelta = {dx/320,dy/240}
		mdelta[1] = mdelta[1]
		mdelta[2] = mdelta[2]
		
		if(dx < 0) then 
			flip = true 
			dx = dx * -1
		else
			flip = false
		end
		
		aim = -math.atan2(dy,dx)*57.3
		aim = aim - 2
		
		if(aim > 90) then aim = 90 end
		if(aim < -90) then aim = -90 end
		
		
		if(MouseDown()) then
			if(!wasmouse) then
				newbits = BUTTON_ATTACK
				wasmouse = true
			end
		else
			if(wasmouse) then
				newbits = 0
				wasmouse = false
			end
		end
		
		local reset = LocalPlayer():GetInfo().health <= 0
		EnableCursor(!reset)
		if(reset) then
			flip = true
		end
	end
	hook.add("Think","sidescroller",think)
	
	local yaw = 90
	local function UserCmd(pl,angle,fm,rm,um,buttons,weapon)
		local anglex = VectorToAngles(Vector(-1,0,0))
		local qyaw = anglex.y+90
		
		if(flip) then qyaw = qyaw + 180 end
		
		--fm = 100
		local temp = rm
		rm = fm*-1
		fm = temp
		
		if(flip == false) then fm = fm * -1 end
		if(flip == false) then rm = rm * -1 end
		txt = "" .. fm
		rm = 0
		
		--buttons = newbits
		buttons = bitOr(buttons,newbits)
		angle = Vector(aim,qyaw,0)
				
		SetUserCommand(angle,fm,rm,um,buttons,weapon)
		--BUTTON_ATTACK
	end
	hook.add("UserCommand","sidescroller",UserCmd)
end

--[[if(SERVER) then
	function ClientThink(pl)
		pl:SetVelocity(pl:GetVelocity() + Vector(0,0,-50))
	end
	hook.add("ClientThink","sidescroller",ClientThink)
end]]