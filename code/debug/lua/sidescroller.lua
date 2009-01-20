if(SERVER) then
	--downloader.add("lua/sidescroller")
	local function BlockAdjust(pl)
		return false
	end
	hook.add("ShouldAdjustAngle","sidescroller",BlockAdjust)
end

function PlayerMove(pm,walk,forward,right)
	--PM_Accelerate(Vector(0,0,1),4,10)
	if(pm:GetType() == PM_DEAD) then
		PM_Drop()
		PM_AirMove()
		
		local v = pm:GetVelocity()
		v.x = 0
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
	v.x = 0
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
	
	local function ShouldDraw(id)
		if(id == "HUD_DRAWGUN") then return false end
	end
	hook.add("ShouldDraw","sidescroller",ShouldDraw)
	
	local function draw3d()
		local pl = LocalPlayer()
		if(pl:GetInfo().health <= -40) then return end
		local legs,torso,head = LoadPlayerModels(pl)
		legs:SetPos(pl:GetPos())
		
		util.AnimatePlayer(pl,legs,torso)
		util.AnglePlayer(pl,legs,torso,head)

		torso:PositionOnTag(legs,"tag_torso")
		head:PositionOnTag(torso,"tag_head")
		
		util.PlayerWeapon(pl,torso)
		
		legs:Render()
		torso:Render()
		head:Render()
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
		local dx,dy = 320-GetXMouse(),240-GetYMouse()

		if(dx < 0) then 
			flip = true 
			dx = dx * -1
		else
			flip = false
		end
		
		aim = -math.atan2(dy,dx)*57.3
		aim = aim + 10
		
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
		fm = rm
		rm = 0
		
		if(flip == false) then fm = fm * -1 end
		txt = "" .. fm
		
		--buttons = newbits
		buttons = bitOr(buttons,newbits)
		
		SetUserCommand(Vector(aim,qyaw,0),fm,rm,um,buttons,weapon)
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