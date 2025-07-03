util.AddNetworkString("apex.notify")

local meta = FindMetaTable("Player")
function meta:Notify(message)
	net.Start("apex.notify")
		net.WriteString(message)
	net.Send(self)
end