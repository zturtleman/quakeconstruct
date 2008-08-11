local weaponKnockback = {
	[WP_GAUNTLET] = 0,
	[WP_MACHINEGUN] = 100,
	[WP_SHOTGUN] = 400,
	[WP_GRENADE_LAUNCHER] = 500,
	[WP_ROCKET_LAUNCHER] = 600,
	[WP_LIGHTNING] = 60,
	[WP_RAILGUN] = 800,
	[WP_PLASMAGUN] = 80,
	[WP_BFG] = 700,
}

--print(wname .. "\n")
--print(angle.x .. "," .. angle.y .. "," .. angle.z .. "\n")

local function FiredWeapon(player,weapon,delay,pos,angle)
	if(!player:IsBot()) then
		local angle = VectorForward(angle)
		local wname = EnumToString(weapon_t,weapon)
		
		local vec = player:GetVelocity()
		local vx = vec.x
		local vy = vec.y
		local vz = vec.z
		
		local knock = weaponKnockback[weapon]*.7
		
		if(knock) then
			vx = vx + angle.x*-knock
			vy = vy + angle.y*-knock
			vz = vz + angle.z*-knock
		end
		
		player:SetVelocity(Vector(vx,vy,vz))
	end
end
hook.add("FiredWeapon","Knockback",FiredWeapon)