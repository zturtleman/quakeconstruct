print("Message Script\n")
KILLED = true

function MessageForPlayerKilled(self,inflictor,attacker,damage,meansOfDeath)
	if(KILLED) then
		if(attacker and attacker:IsPlayer() and self and self:IsPlayer()) then
			local selfname = self:GetInfo()["name"]
			if(selfname == "Hxrmn") then
				local str = attacker:GetInfo()["name"] .. " had better pray for his lagging ass, that I don't come back to smite him :D.\n"
				sendToAll(str,false)
				return false
			end
		end
	end
end
hook.add("PlayerKilled","KilledMessageTest",MessageForPlayerKilled)