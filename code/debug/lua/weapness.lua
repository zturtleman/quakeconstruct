function ClientThink(cl)
	for i=WP_MACHINEGUN,WP_GRAPPLING_HOOK do
		cl:SetAmmo(i,0)
	end
end
hook.add("ClientThink","weapness.lua",ClientThink)