local template = UI_Create("button")
template:SetPos(0,20)
template:SetSize(100,20)
template:SetTextSize(8)		
template:SetText("<nothing here>")
template:TextAlignCenter()
template:Remove()

local panel = UI_Create("frame")
if(panel != nil) then
	local w,h = 640,480
	local pw,ph = w/2,h/2
	panel.name = "base"
	panel:SetPos((w/2) - pw/2,(h/2) - ph/2)
	panel:SetSize(pw,ph)
	panel:SetTitle("Games")
	panel:CatchMouse(true)
	panel:SetVisible(true)
end

local panel2 = UI_Create("listpane",panel)
if(panel2 != nil) then
	panel2.name = "base->listpane"
	panel2:SetSize(100,100)
	panel2:DoLayout()
end

function populate()
	local g = ListCustomGames()
	
	panel2:Clear()
	
	for i=1,#g do
		template.Think = function(btn)
			local act = "off"
			local stat = GetCustomGameStatus(g[i])
			if(stat) then act = "on" end
			btn:SetText(g[i] .. " - " .. act)
		end
		
		template:SetText("")
		template.DoClick = function(btn)
			if(GetCustomGameStatus(g[i])) then
				ConsoleCommand("EndCustomGame " .. g[i])
			else
				ConsoleCommand("StartCustomGame " .. g[i])
			end
		end
		
		panel2:AddPanel(template,true)
	end
	
	panel2:DoLayout()
end

populate()