local items = {}

local poses = {{x=-1,y=-1},{x=1,y=1},{x=-1,y=1},{x=1,y=-1},
			   {x=0,y=-1},{x=0,y=1},{x=-1,y=0},{x=1,y=0}}

function hud_drawPickups()
	local ps = 40
	local x = 10
	for k,v in pairs(items) do
		local pki = util.GetItemIcon(v.item)
		local dp = v.t
		if(k == 1) then v.t = v.t - .01 end
		if(k == 1 and #items > 5) then v.t = v.t - 0.02 
			if(v.t > 0.3) then v.t = 0.3 end end
		v.t2 = v.t2 - .02
		if(dp > 0) then
			local f = math.min(dp*3,1)
			local f2 = math.min((1-v.t2)*3,1)
			local addage = 1 + (1-f2)
			local addage2 = (ps*(addage-1))/2
			x = x + (ps*f)+3
			draw.SetColor(0,0,0,f/2)
			for _,p in pairs(poses) do
			draw.Rect((640-x)+p.x,100+p.y,ps,ps,pki)
			end
			draw.SetColor(1,1,1,f)
			draw.Rect(640-x,100,ps,ps,pki)
			draw.Rect(640-(x+addage2),100-addage2,ps*addage,ps*addage,pki)
			if(v.t2 == 0.98 and !v.flashed) then
				hud_flasheffect(640-(x-ps/2),100+ps/2,200,0)
				v.flashed = true
			end
		else
			v.remove = true
		end
	end
	for k,v in pairs(table.Copy(items)) do
		if(v.remove) then table.remove(items,k) end
	end
end

local function itemPickup(i)
	table.insert(items,{item=i,t=1,t2=1})
end
hook.add("ItemPickup","cl_hp",itemPickup)

local function test() itemPickup(3) end
concommand.Add("pktest",test)