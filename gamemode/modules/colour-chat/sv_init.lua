util.AddNetworkString("apex.chat.data")
local meta = FindMetaTable("Player")

function meta:ApexChat(msg_data, client, msg)
    data = tostring(msg_data)

    if ( !msg ) then msg = "" end
    if ( !client ) then client = "" end

    net.Start("apex.chat.data")
        net.WriteString(msg_data)
        net.WriteString(msg)
        net.WriteEntity(client)
    net.Send(self)
end