local function ConsoleMessage(message)
	MsgC(Color(255,0,0,255), "(FAdmin) ")
	MsgC(Color(200,0,200,255), message .. "\n")
end

net.Receive("FAdmin_ConsoleMessage", function()
	local message = net.ReadString()
	if not message then return end

	ConsoleMessage(message)
end)