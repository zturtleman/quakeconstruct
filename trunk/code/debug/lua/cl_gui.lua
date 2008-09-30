if(mainpanel != nil) then
	mainpanel:Remove()
	mainpanel = nil
end

mainpanel = UI_Create("panel")
mainpanel:SetSize(640,480)
mainpanel:SetPos(0,0)
mainpanel.bgcolor = {0,0,0,.15}
mainpanel:SetVisible(false)
mainpanel:CatchMouse(true)

local template = UI_Create("button")
template:Remove()

local function MakeFrame()
	local panel = UI_Create("frame",mainpanel)
	if(panel != nil) then
		panel.name = "base"
		panel:SetPos(10,10)
		panel:SetSize(200,120)
		panel:SetTitle("A Neat ListPane")
		panel:Center()
	end

	local panel2 = UI_Create("listpane",panel)
	if(panel2 != nil) then
		panel2.name = "base->listpane"
		panel2:SetSize(100,100)
		panel2:DoLayout()
		
		template:SetPos(0,20)
		template:SetSize(100,14)
		template:SetTextSize(12)		
		template:SetText("Test1")
		panel2:AddPanel(template,true)
		
		template:SetText("Test2")
		panel2:AddPanel(template,true)

		template:SetSize(100,24)
		template:SetText("Test3")
		panel2:AddPanel(template,true)
		
		template:SetSize(100,34)
		template:SetText("Test4")
		panel2:AddPanel(template,true)
		
		--[[btn:SetSize(100,14)
		btn:SetText("Close")
		btn.DoClick = function(btn)
			panel:SetVisible(false)
		end
		panel2:AddPanel(btn,true)]]
	end
end

local btn = UI_Create("button",mainpanel)
btn:SetPos(10,10)
btn:SetSize(150,20)
btn:SetTextSize(10)
btn:SetText("Create Frame")
btn.DoClick = function(b)
	MakeFrame()
end

local function keyed(key,state)
	if(key == K_ALT) then
		if(state == true) then
			mainpanel:SetVisible(true)
		else
			mainpanel:SetVisible(false)
		end
	end
end
hook.add("KeyEvent","UImenutest",keyed)