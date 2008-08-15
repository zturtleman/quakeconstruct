local function PlayerSpawned(cl)
	cl:SendString("awesome message")
end
hook.add("PlayerSpawned","test",PlayerSpawned)