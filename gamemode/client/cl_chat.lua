apex = apex or {}
apex.chat = apex.chat or {}

apex.chat.config = {
	timeStamps = false,
	position = 1,
	fadeTime = 16,
}

surface.CreateFont("apex_chat_18", {
	font = "Tahoma",
	size = 18,
	weight = 600,
	antialias = true,
	shadow = true,
})

surface.CreateFont("apex_chat_radio", {
	font = "Courier",
	size = 13,
	weight = 300,
	antialias = true,
	shadow = true,
})

surface.CreateFont("apex_chat_16", {
	font = "Tahoma",
	size = 13,
	weight = 600,
	antialias = true,
	shadow = true,
})

function apex.chat.Init()
	if IsValid( apex.chat.frame ) then
		apex.chat.frame:Remove()
	end

	if IsValid( apex.chat.frameSettings ) then
		apex.chat.frameSettings:Remove()
	end

	apex.chat.frame = vgui.Create("DFrame")
	apex.chat.frame:SetSize( ScrW()*0.375, ScrH()*0.25 )
	apex.chat.frame:SetTitle("")
	apex.chat.frame:ShowCloseButton( false )
	apex.chat.frame:SetDraggable( false )
	apex.chat.frame:SetPos( ScrW()*0.0116, (ScrH() - apex.chat.frame:GetTall()) - ScrH()*0.177)
	apex.chat.frame:MoveToBack()
	apex.chat.frame.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 200 ) ) -- draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 200 ) )

		draw.RoundedBox( 0, 0, 0, w, 25, Color( 80, 80, 80, 100 ) )
	end
	apex.chat.oldPaint = apex.chat.frame.Paint

	local serverName = vgui.Create("DLabel", apex.chat.frame)
	serverName:SetText( "Chatbox" )
	serverName:SetFont( "apex_chat_18")
	serverName:SizeToContents()
	serverName:SetPos( 5, 4 )


	apex.chat.entry = vgui.Create("DTextEntry", apex.chat.frame)
	apex.chat.entry:SetSize( apex.chat.frame:GetWide() - 50, 20 )
	apex.chat.entry:SetTextColor( color_white )
	apex.chat.entry:SetFont("apex_chat_18")
	apex.chat.entry:SetDrawBorder( false )
	apex.chat.entry:SetDrawBackground( false )
	apex.chat.entry:SetCursorColor( color_white )
	apex.chat.entry:SetHighlightColor( Color(52, 152, 219) )
	apex.chat.entry:SetPos( 45, apex.chat.frame:GetTall() - apex.chat.entry:GetTall() - 5 )
	apex.chat.entry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
	end

	apex.chat.entry.OnTextChanged = function( self )
		if self and self.GetText then
			gamemode.Call( "ChatTextChanged", self:GetText() or "" )
		end
	end

	apex.chat.entry.OnKeyCodeTyped = function( self, code )
		local types = {"", "teamchat", "console"}

		if code == KEY_ESCAPE then

			apex.chat.Hide()
			gui.HideGameUI()

		elseif code == KEY_TAB then

			apex.chat.TypeSelector = (apex.chat.TypeSelector and apex.chat.TypeSelector + 1) or 1

			if apex.chat.TypeSelector > 3 then apex.chat.TypeSelector = 1 end
			if apex.chat.TypeSelector < 1 then apex.chat.TypeSelector = 3 end

			apex.chat.ChatType = types[apex.chat.TypeSelector]

			timer.Simple(0.001, function() apex.chat.entry:RequestFocus() end)

		elseif code == KEY_ENTER then
			-- Replicate the client pressing enter

			if string.Trim( self:GetText() ) != "" then
				if apex.chat.ChatType == types[2] then
					LocalPlayer():ConCommand("say_team \"" .. (self:GetText() or "") .. "\"")
				elseif apex.chat.ChatType == types[3] then
					LocalPlayer():ConCommand("say /ooc "..self:GetText() or "")
				else
					LocalPlayer():ConCommand("say \"" .. self:GetText() .. "\"")
				end
			end

			apex.chat.TypeSelector = 1
			apex.chat.Hide()
		end
	end

	apex.chat.chatLog = vgui.Create("RichText", apex.chat.frame)
	apex.chat.chatLog:SetSize( apex.chat.frame:GetWide() - 10, apex.chat.frame:GetTall() - 60 )
	apex.chat.chatLog:SetPos( 5, 30 )
	apex.chat.chatLog:MoveToBack()
	apex.chat.chatLog.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
	end
	apex.chat.chatLog.Think = function( self )
		if apex.chat.lastMessage then
			if CurTime() - apex.chat.lastMessage > apex.chat.config.fadeTime then
				self:SetVisible( false )
			else
				self:SetVisible( true )
			end
		end
	end
	apex.chat.chatLog.PerformLayout = function( self )
		self:SetFontInternal("apex_chat_18")
		self:SetFGColor( color_white )
	end
	apex.chat.oldPaint2 = apex.chat.chatLog.Paint

	local text = "Say :"

	local say = vgui.Create("DLabel", apex.chat.frame)
	say:SetText("")
	surface.SetFont( "apex_chat_18")
	local w, h = surface.GetTextSize( text )
	say:SetSize( w + 5, 20 )
	say:SetPos( 5, apex.chat.frame:GetTall() - apex.chat.entry:GetTall() - 5 )

	say.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
		draw.DrawText( text, "apex_chat_18", 2, 1, color_white )
	end

	say.Think = function( self )
		local types = {"", "teamchat", "console"}
		local s = {}

		if apex.chat.ChatType == types[2] then
			text = "Say (RADIO) :"
		elseif apex.chat.ChatType == types[3] then
			text = "OOC :"
		else
			text = "Say :"
			s.pw = 45
			s.sw = apex.chat.frame:GetWide() - 50
		end

		if s then
			if not s.pw then s.pw = self:GetWide() + 10 end
			if not s.sw then s.sw = apex.chat.frame:GetWide() - self:GetWide() - 15 end
		end

		local w, h = surface.GetTextSize( text )
		self:SetSize( w + 5, 20 )
		self:SetPos( 5, apex.chat.frame:GetTall() - apex.chat.entry:GetTall() - 5 )

		apex.chat.entry:SetSize( s.sw, 20 )
		apex.chat.entry:SetPos( s.pw, apex.chat.frame:GetTall() - apex.chat.entry:GetTall() - 5 )
	end

	apex.chat.Hide()
end

--// Hides the chat box but not the messages
function apex.chat.Hide()
	apex.chat.frame.Paint = function() end
	apex.chat.chatLog.Paint = function() end

	apex.chat.chatLog:SetVerticalScrollbarEnabled( false )
	apex.chat.chatLog:GotoTextEnd()

	apex.chat.lastMessage = apex.chat.lastMessage or CurTime() - apex.chat.config.fadeTime

	-- Hide the chatbox except the log
	local children = apex.chat.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == apex.chat.frame.btnMaxim or pnl == apex.chat.frame.btnClose or pnl == apex.chat.frame.btnMinim then continue end

		if pnl != apex.chat.chatLog then
			pnl:SetVisible( false )
		end
	end

	-- Give the player control again
	apex.chat.frame:SetMouseInputEnabled( false )
	apex.chat.frame:SetKeyboardInputEnabled( false )
	gui.EnableScreenClicker( false )

	-- We are done chatting
	gamemode.Call("FinishChat")

	-- Clear the text entry
	apex.chat.entry:SetText( "" )
	gamemode.Call( "ChatTextChanged", "" )
end

--// Shows the chat box
function apex.chat.Show()
	-- Draw the chat box again
	apex.chat.frame.Paint = apex.chat.oldPaint
	apex.chat.chatLog.Paint = apex.chat.oldPaint2

	apex.chat.chatLog:SetVerticalScrollbarEnabled( true )
	apex.chat.lastMessage = nil

	-- Show any hidden children
	local children = apex.chat.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == apex.chat.frame.btnMaxim or pnl == apex.chat.frame.btnClose or pnl == apex.chat.frame.btnMinim then continue end

		pnl:SetVisible( true )
	end

	-- MakePopup calls the input functions so we don't need to call those
	apex.chat.frame:MakePopup()
	apex.chat.entry:RequestFocus()

	-- Make sure other addons know we are chatting
	gamemode.Call("StartChat")
end

--// Opens the settings panel
function apex.chat.ShowSettings()
	apex.chat.Hide()

	apex.chat.frameSettings = vgui.Create("DFrame")
	apex.chat.frameSettings:SetSize( 400, 300 )
	apex.chat.frameSettings:SetTitle("")
	apex.chat.frameSettings:MakePopup()
	apex.chat.frameSettings:SetPos( ScrW()/2 - apex.chat.frameSettings:GetWide()/2, ScrH()/2 - apex.chat.frameSettings:GetTall()/2 )
	apex.chat.frameSettings:ShowCloseButton( true )
	apex.chat.frameSettings.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 200 ) )

		draw.RoundedBox( 0, 0, 0, w, 25, Color( 80, 80, 80, 100 ) )

		draw.RoundedBox( 0, 0, 25, w, 25, Color( 50, 50, 50, 50 ) )
	end

	local serverName = vgui.Create("DLabel", apex.chat.frameSettings)
	serverName:SetText( "Settings" )
	serverName:SetFont( "apex_chat_18")
	serverName:SizeToContents()
	serverName:SetPos( 5, 4 )

	local label1 = vgui.Create("DLabel", apex.chat.frameSettings)
	label1:SetText( "Time stamps: " )
	label1:SetFont( "apex_chat_18")
	label1:SizeToContents()
	label1:SetPos( 10, 40 )

	local checkbox1 = vgui.Create("DCheckBox", apex.chat.frameSettings )
	checkbox1:SetPos(label1:GetWide() + 15, 42)
	checkbox1:SetValue( apex.chat.config.timeStamps )

	local label2 = vgui.Create("DLabel", apex.chat.frameSettings)
	label2:SetText( "Fade time: " )
	label2:SetFont( "apex_chat_18")
	label2:SizeToContents()
	label2:SetPos( 10, 70 )

	local textEntry = vgui.Create("DTextEntry", apex.chat.frameSettings)
	textEntry:SetSize( 50, 20 )
	textEntry:SetPos( label2:GetWide() + 15, 70 )
	textEntry:SetText( apex.chat.config.fadeTime )
	textEntry:SetTextColor( color_white )
	textEntry:SetFont("apex_chat_18")
	textEntry:SetDrawBorder( false )
	textEntry:SetDrawBackground( false )
	textEntry:SetCursorColor( color_white )
	textEntry:SetHighlightColor( Color(52, 152, 219) )
	textEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
	end

	local save = vgui.Create("DButton", apex.chat.frameSettings)
	save:SetText("Save")
	save:SetFont( "apex_chat_18")
	save:SetTextColor( Color( 230, 230, 230, 150 ) )
	save:SetSize( 70, 25 )
	save:SetPos( apex.chat.frameSettings:GetWide()/2 - save:GetWide()/2, apex.chat.frameSettings:GetTall() - save:GetTall() - 10)
	save.Paint = function( self, w, h )
		if self:IsDown() then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 80, 80, 80, 200 ) )
		else
			draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 200 ) )
		end
	end
	save.DoClick = function( self )
		apex.chat.frameSettings:Close()

		apex.chat.config.timeStamps = checkbox1:GetChecked()
		apex.chat.config.fadeTime = tonumber(textEntry:GetText()) or apex.chat.config.fadeTime
	end
end

chat.AddTextInternal = chat.AddTextInternal or chat.AddText
function chat.AddText(...)
	if not apex.chat.chatLog then
		apex.chat.Init()
	end

	local msg = {}

	-- Iterate through the strings and colors
	for _, obj in pairs( {...} ) do
		if type(obj) == "table" then
			apex.chat.chatLog:InsertColorChange( obj.r, obj.g, obj.b, obj.a )
			table.insert( msg, Color(obj.r, obj.g, obj.b, obj.a) )
		elseif type(obj) == "string"  then
			apex.chat.chatLog:AppendText( obj )
			table.insert( msg, obj )
		elseif obj:IsPlayer() then
			local client = obj

			if apex.chat.config.timeStampsffdtr then
				apex.chat.chatLog:InsertColorChange( 130, 130, 130, 255 )
				apex.chat.chatLog:AppendText( "["..os.date("%X").."] ")
			end

			local col = GAMEMODE:GetTeamColor( obj ) -- TESTS: local col = GAMEMODE:GetTeamColor( obj )
			apex.chat.chatLog:InsertColorChange( col.r, col.g, col.b, 255 ) -- TESTS: apex.chat.chatLog:InsertColorChange( col.r, col.g, col.b, 255 )
			apex.chat.chatLog:AppendText( obj:Nick() )
			table.insert( msg, obj:Nick() )
		end
	end
	apex.chat.chatLog:AppendText("\n")

	apex.chat.chatLog:SetVisible( true )
	apex.chat.chatLog:MoveToBack()
	apex.chat.lastMessage = CurTime()

	chat.AddTextInternal( unpack(msg) )
end

hook.Add( "ChatText", "apex_chat_joinleave", function( index, name, text, type )
	if not apex.chat.chatLog then
		apex.chat.Init()
	end

	if type != "chat" then
		apex.chat.chatLog:InsertColorChange( 0, 128, 255, 255 )
		apex.chat.chatLog:AppendText( text.."\n" )
		apex.chat.chatLog:SetVisible( true )
		apex.chat.lastMessage = CurTime()
		apex.chat.chatLog:InsertColorChange( 255, 255, 255, 255 )
		return true
	end
end)

hook.Add("PlayerBindPress", "apex_chat_hijackbind", function(client, bind, pressed)
	if string.sub( bind, 1, 11 ) == "messagemode" then
		if bind == "messagemode2" then
			apex.chat.ChatType = "teamchat"
		else
			apex.chat.ChatType = ""
		end

		if IsValid( apex.chat.frame ) then
			apex.chat.Show()
		else
			apex.chat.Init()
			apex.chat.Show()
		end

		return true
	end
end)

hook.Add("HUDShouldDraw", "apex_chat_hidedefault", function( name )
	if name == "CHudChat" then
		return false
	end
end)

hook.Add("OnReloaded", "apex_chat_Reloaded", function()
	apex.chat.Init()
end)

chat.GetChatBoxPosInternal = chat.GetChatBoxPosInternal or chat.GetChatBoxPos
function chat.GetChatBoxPos()
	if not apex.chat.frame or not apex.chat.frame:IsValid() then
		return chat.GetChatBoxPosInternal()
	end

	return apex.chat.frame:GetPos()
end