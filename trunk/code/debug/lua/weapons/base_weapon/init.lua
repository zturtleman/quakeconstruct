downloader.add("lua/weapons/base_weapon/cl_init.lua")

function WEAPON:Fire(player,muzzle,angles)
	G_FireBullet(player,250,20)
	local f,r,u = AngleVectors(angles)
	player:SetVelocity(player:GetVelocity() - f * 200)
end