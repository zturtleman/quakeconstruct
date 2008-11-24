function rspeed()
    for k,v in pairs(GetAllPlayers()) do
        v:SetSpeed(1)
        v:SetHealth(v:GetHealth() + 1)
        if(v:GetHealth() > 200) then
            v:SetHealth(200)
        end
    end
end
hook.add("Think","coolspeed",rspeed)
